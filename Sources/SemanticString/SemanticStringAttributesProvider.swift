import Foundation

/**
 default implementation of `SemanticStringAttributesProviderType`
 */
public struct SemanticStringAttributesProvider: SemanticStringAttributesProviderType {

    public typealias TextStyle = SemanticString.TextStyle
    public typealias SetAttributes = (TextStyle, inout TextAttributes, [TextStyle]) -> Void

    private let _getAttributes: () -> TextAttributes
    private let _setAttributes: (SemanticString.TextStyle, inout TextAttributes, [SemanticString.TextStyle]) -> Void
    
    public let locale: Locale?

    /**
     - Parameters:
        - locale: the locale for localizing `SemanticString`
        - getAttributes: the function that returns text attributes for whole string
        - setAttributes: the function that updates text attributes for specified text style.
                         See comment to `SemanticStringAttributesProviderType.setAttributes(for:attributes:surroundingStyles)`
     */
    public init(locale: Locale? = nil,
                getAttributes: @escaping () -> TextAttributes,
                setAttributes: @escaping SetAttributes) {
        self.locale = locale
        _getAttributes = getAttributes
        _setAttributes = setAttributes
    }

    /**
     - Parameters:
        - locale: the locale for localizing `SemanticString`
        - getAttributes: the function that returns text attributes for a whole string (if the argument is nil) or new text attributes for text style.
     */
    public init(locale: Locale? = nil, getAttributes: @escaping (SemanticString.TextStyle?) -> TextAttributes) {
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
}

extension SemanticStringAttributesProvider {
    /**
     creates `SemanticStringAttributesProvider` using specified locale and text attributes.

     - Parameters:
        - locale: the locale for localizing `SemanticString`
        - commonAttributes: the text attributes for whole string
        - styleAttributes: the dictionary that specifies attributes for text styles

     ```
     let provider = SemanticStringAttributesProvider(
         commonAttributes: [.font: UIFont.systemFont(ofSize: UIFont.systemFontSize)],
         styleAttributes: [
             .bold: [.font: UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)]
         ]
     )
     ```
     */
    public init(
        locale: Locale? = nil,
        commonAttributes: TextAttributes,
        styleAttributes: [SemanticString.TextStyle: TextAttributes]
    ) {
        self.locale = locale
        _getAttributes = { commonAttributes }
        _setAttributes = { style, attributes, _ in
            guard let attributesForStyle = styleAttributes[style]
                else { return }

            attributes.merge(with: attributesForStyle)
        }
    }
}
