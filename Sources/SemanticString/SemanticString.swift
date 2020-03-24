import Foundation

/**
 String abstraction that includes information about structural semantics for text.
 This information allows applying stylization to the text, forming a result of the `NSAttributedString` type.

 For example we want to make "hello **world**!" text with highlighted word "world".

 To create `NSAttributedString` from `SemanticString` we need instance of `SemanticStringAttributesProviderType`.
 ```
 let text = SemanticString("Hello \("world", styles: [.bold])!")

 let provider = SemanticStringAttributesProvider(
     commonAttributes: [.font: UIFont.systemFont(ofSize: UIFont.systemFontSize)],
     styleAttributes: [
         .bold: [.font: UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)]
     ]
 )

 let attributedText: NSAttributedString = text.getAttributedString(provider: provider)
 ```

 For applications that support changing language at runtime, `SemanticString` lets create locale agnostic strings.
 Next example assumes that project contains `Localizable.strings` for English and Russian localization with `helloWorld` key
 ```
 let resource = StringResource(key: "helloWorld", tableName: "Localizable", bundle: .main)
 let string = SemanticString(resource: resource)

 print(string)
 // printed: "Hello world!"

 SemanticString.setCurrentLocale(Locale(identifier: "ru-RU"))

 print(string)
 // printed: "Привет мир!"
 ```

 - SeeAlso: `SemanticStringAttributesProviderType`
 - SeeAlso: `setCurrentLocale(_:)`
 */
public struct SemanticString {

    private static var _currentLocale: Locale = .autoupdatingCurrent
    private static let currentLocaleLock = ReadWriteLock()

    public static let currentLocaleKey = "currentLocale"

    /**
     Default locale that used for string localization.
     */
    public static var currentLocale: Locale {
        currentLocaleLock.lockRead()
        defer { currentLocaleLock.unlock() }
        return _currentLocale
    }

    /**
     Set default locale.

     After setting new locale `SemanticString` posts `.semanticStringCurrentLocaleDidChange` notification.
     To observe it:
     ```
     let observation = NotificationCenter.default
         .addObserver(forName: .semanticStringCurrentLocaleDidChange, object: nil, queue: nil) { notification in
             let currentLocale = notification.userInfo[SemanticString.currentLocaleKey] as! Locale
     }
     ```
     */
    public static func setCurrentLocale(_ locale: Locale) {
        currentLocaleLock.lockWrite()
        let prevLocale = _currentLocale
        _currentLocale = locale
        currentLocaleLock.unlock()

        guard prevLocale != locale else { return }

        NotificationCenter.default.post(
            name: .semanticStringCurrentLocaleDidChange,
            object: nil,
            userInfo: [currentLocaleKey: locale]
        )
    }

    public let components: [StringComponent]
}

extension SemanticString: CustomStringConvertible {
    public var description: String {
        getString()
    }
}

extension SemanticString {
    /**
     Converts a `SemanticString` to `String` using a specified locale.
     */
    public func getString(_ locale: Locale = SemanticString.currentLocale) -> String {
        let strings = components.map { component in
            getString(component: component, locale: locale)
        }

        return strings.joined()
    }

    private func getString(component: StringComponent, locale: Locale) -> String {
        switch component.content {
        case let .plain(string):
            return string

        case let .attributed(attributedString):
            return attributedString.string

        case let .localizable(resource, args):
            let format = resource.localize(with: locale)
            return String(format: format, arguments: args)

        case let .dynamic(provider):
            return provider(locale).getString(locale)
        }
    }
}

extension SemanticString {
    /**
     Converts a `SemanticString` to `NSAttributedString` using a specified provider.

     - Parameters:
        - provider: an object that provides text attributes for the whole text and specific text styles.

     - Returns: formatted string.

     - SeeAlso: `SemanticString.TextStyle`
     */
    public func getAttributedString(provider: SemanticStringAttributesProviderType) -> NSAttributedString {
        let commonAttributes = provider.getAttributes()

        let locale = provider.locale

        let strings = components.map { component in
            getAttributedString(
                component: component,
                locale: locale ?? SemanticString.currentLocale,
                commonAttributes: commonAttributes,
                setAttributes: provider.setAttributes(for:attributes:surroundingStyles:))
        }

        let resultString = AttributedStringBuilder.build(components: strings, attributes: commonAttributes.dictionary)
        return resultString
    }

    private func getAttributedString(
        component: StringComponent,
        locale: Locale,
        commonAttributes: TextAttributes,
        setAttributes: (TextStyle, inout TextAttributes, [TextStyle]) -> Void)
        -> NSAttributedString {
            let attributedString = getAttributedString(
                content: component.content,
                locale: locale,
                commonAttributes: commonAttributes,
                setAttributes: setAttributes
            )

            var attributes = commonAttributes
            var appliedStyles: [TextStyle] = []
            for style in component.styles {
                setAttributes(style, &attributes, appliedStyles)
                appliedStyles.insert(style, at: 0)
            }

            guard !attributes.dictionary.isEmpty else { return attributedString }
            let attributedStringWithAppliedStyles = AttributedStringBuilder.build(
                components: [attributedString], attributes: attributes.dictionary)

            return attributedStringWithAppliedStyles
    }

    private func getAttributedString(
        content: Content,
        locale: Locale,
        commonAttributes: TextAttributes,
        setAttributes: (TextStyle, inout TextAttributes, [TextStyle]) -> Void)
        -> NSAttributedString {

            switch content {
            case let .plain(string):
                return NSAttributedString(string: string)

            case let .attributed(string):
                return string

            case let .localizable(resource, args):
                let format = resource.localize(with: locale)
                let string = String(format: format, arguments: args)
                return NSAttributedString(string: string)

            case let .dynamic(provider):
                let semanticString = provider(locale)
                let strings = semanticString.components.map { component in
                    getAttributedString(
                        component: component,
                        locale: locale,
                        commonAttributes: commonAttributes,
                        setAttributes: setAttributes
                    )
                }

                return AttributedStringBuilder.build(components: strings, attributes: [:])
            }
    }
}

public func +(lhs: SemanticString, rhs: SemanticString) -> SemanticString {
    SemanticString(components: lhs.components + rhs.components)
}

public func +(lhs: SemanticString, rhs: String) -> SemanticString {
    SemanticString(components: lhs.components + [.init(styles: [], content: .plain(rhs))])
}

public func +(lhs: SemanticString, rhs: NSAttributedString) -> SemanticString {
    SemanticString(components: lhs.components + [.init(styles: [], content: .attributed(rhs))])
}

public func +(lhs: String, rhs: SemanticString) -> SemanticString {
    SemanticString(components: [SemanticString.StringComponent(styles: [], content: .plain(lhs))] + rhs.components)
}

public func +=(lhs: inout SemanticString, rhs: SemanticString) {
    lhs = lhs + rhs
}

public func +=(lhs: inout SemanticString, rhs: String) {
    lhs = lhs + rhs
}

public func +=(lhs: inout SemanticString, rhs: NSAttributedString) {
    lhs = lhs + rhs
}

extension Sequence where Element == SemanticString {
    public func joined() -> SemanticString {
        SemanticString(components: flatMap { $0.components })
    }

    public func joined(separator: SemanticString) -> SemanticString {
        var iterator = makeIterator()
        var components = iterator.next()?.components ?? []
        while let next = iterator.next() {
            components += separator.components
            components += next.components
        }

        return SemanticString(components: components)
    }
}
