import Foundation

extension NSNotification.Name {
    /**
     Posted when `SemanticString.currentLocale` did change.

     - SeeAlso: `SemanticString.setCurrentLocale(_:)`
     */
    public static let semanticStringCurrentLocaleDidChange =
        NSNotification.Name("SemanticStringCurrentLocaleDidChange")
}
