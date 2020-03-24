import Foundation

/**
 Provides text attributes for whole string and specific styles.
 `SemanticStringAttributesProviderType` used to convert `SemanticString` into `NSAttributedString`.

 - SeeAlso: `SemanticString.getAttributedString(provider:)`
 - SeeAlso: `SemanticStringTextAttributesProvider`
 */
public protocol SemanticStringAttributesProviderType {
    var locale: Locale? { get }

    /**
     returns attributes for whole string.
     */
    func getAttributes() -> TextAttributes

    /**
     updates attributes for specified `textStyle`.
     - Parameters:
        - textStyle: text style for which need to provide attributes
        - attributes: mutable text attributes. The method receives attributes that will be applied to text and can update it.
        - surroundingStyles: surrounding text styles. Styles are sorted from inner to outer.

     Example. Providing attributes for "bold" and "italic" text styles:
     ```
     public func getAttributes() -> TextAttributes {
         [.font: UIFont.systemFont(ofSize: UIFont.systemFontSize)]
     }

     public func setAttributes(
         for textStyle: SemanticString.TextStyle,
         attributes: inout TextAttributes,
         surroundingStyles: [SemanticString.TextStyle]
     ) {
         guard let font = attributes.font else { return }

         var traits = font.fontDescriptor.symbolicTraits

         switch textStyle {
         case "bold":
             traits.insert(.traitBold)

         case "italic":
             traits.insert(.traitItalic)

         default:
             return
         }

         guard let descriptor = font.fontDescriptor.withSymbolicTraits(traits) else { return }

         attributes.font = UIFont(descriptor: descriptor, size: font.pointSize)
     }
     ```

     "Lorem" in the next code will have the bold-italic font:
     ```
     let xmlString = SemanticString(xml: "<italic><bold>Lorem</bold> ipsum dolor sit amet consectetur</italic> adipisicing.")
     let provider = TestAttributesProvider()
     let attributedString = xmlString.getAttributedString(provider: provider)
     ```
     */
    func setAttributes(
        for textStyle: SemanticString.TextStyle,
        attributes: inout TextAttributes,
        surroundingStyles: [SemanticString.TextStyle]
    )
}
