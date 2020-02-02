import Foundation

public struct SemanticStringAttributesProvider: SemanticStringAttributesProviderType {

    public typealias TextStyle = SemanticString.TextStyle
    public typealias SetAttributes = (TextStyle, inout TextAttributes, [TextStyle]) -> Void

    private let _getAttributes: () -> TextAttributes
    private let _setAttributes: (SemanticString.TextStyle, inout TextAttributes, [SemanticString.TextStyle]) -> Void
    public let locale: Locale

    public init(locale: Locale,
                getAttributes: @escaping () -> TextAttributes,
                setAttributes: @escaping SetAttributes) {
        self.locale = locale
        _getAttributes = getAttributes
        _setAttributes = setAttributes
    }

    public init(locale: Locale, getAttributes: @escaping (SemanticString.TextStyle?) -> TextAttributes) {
        self.locale = locale
        _getAttributes = { getAttributes(nil) }
        _setAttributes = { textStyle, attributes, _ in
            attributes.merge(with: getAttributes(textStyle))
        }
    }

    public func getAttributes() -> TextAttributes {
        _getAttributes()
    }

    public func setAttributes(
        for textStyle: SemanticString.TextStyle,
        attributes: inout TextAttributes,
        surroundingStyles: [SemanticString.TextStyle]) {
        _setAttributes(textStyle, &attributes, surroundingStyles)
    }

    public static var `default`: SemanticStringAttributesProvider {
        SemanticStringAttributesProvider(
            locale: Locale.current,
            getAttributes: { TextAttributes() },
            setAttributes: { _, _, _ in }
        )
    }
}
