import Foundation

public protocol SemanticStringAttributesProviderType {
    var locale: Locale? { get }
    func getAttributes() -> TextAttributes
    func setAttributes(
        for textStyle: SemanticString.TextStyle,
        attributes: inout TextAttributes,
        surroundingStyles: [SemanticString.TextStyle]
    )
}
