import Foundation

extension SemanticString {
    /**
     Text part of `SemanticString`. `SemanticString` can contain multiple `Content`-s

     */
    public enum Content {
        /**
         Localized string.

         ```
         let text: SemanticString = "hello world!"
         ```
         */
        case plain(String)

        /**
         Localized attributed string.

         Used to provide existing `NSAttributedString` via `SemanticString`.
         `NSAttributedString` attributes would not be overridden by `SemanticString.getAttributedString(provider:)`, but new ones can be added:
         ```
         let attributedString = NSAttributedString(string: "world", attributes: [.foregroundColor: UIColor.green])

         let text: SemanticString = "hello \(attributedString)"

         let provider = SemanticStringAttributesProvider(
             commonAttributes: [.foregroundColor: UIColor.blue, .backgroundColor: UIColor.yellow],
             styleAttributes: [:]
         )

         let result = text.getAttributedString(provider: provider)
         ```

         The `result` will be text on yellow background `hello` (blue) + `world` (green)
         */
        case attributed(NSAttributedString)

        /**
         localizable string.

         `StringResourceType` describe info required to find specific string (key + table + bundle).
         Array contains arguments to substitute into format.

         ```
         let resource = StringResource(key: "helloWorld", tableName: "Localizable", bundle: .main)
         let string = SemanticString(resource: resource)
         print(string)
         ```
         Localizable strings can be used in apps that support changing language at runtime.
         See how to use `SemanticString` with `R.swift` library
         */
        case localizable(StringResourceType, [CVarArg])

        /**
         dynamic localizable string.

         Designated to provide localized string depending on locale.
         ```
        let text = SemanticString(dynamic: { locale -> SemanticString in
             let formatter = NumberFormatter()
             formatter.locale = locale
             formatter.numberStyle = .spellOut

             return "\(formatter.string(from: 1)!)"
         })

         print(text.getString(Locale(identifier: "es")))
         ```
         */
        case dynamic((Locale) -> SemanticString)
    }
}
