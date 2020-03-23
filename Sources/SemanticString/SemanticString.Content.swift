import Foundation

extension SemanticString {
    public enum Content {
        case plain(String)
        case attributed(NSAttributedString)
        case localizable(StringResourceType, [CVarArg])
        case dynamic((Locale) -> SemanticString)
    }
}
