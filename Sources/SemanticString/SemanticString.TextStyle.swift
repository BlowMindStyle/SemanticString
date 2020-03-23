extension SemanticString {
    public struct TextStyle: Hashable, Equatable, RawRepresentable {
        public var rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
}

extension SemanticString.TextStyle {
    public static let body          = Self.init(rawValue: "body")
    public static let callout       = Self.init(rawValue: "callout")
    public static let caption       = Self.init(rawValue: "caption")
    public static let footnote      = Self.init(rawValue: "footnote")
    public static let headline      = Self.init(rawValue: "headline")
    public static let largeTitle    = Self.init(rawValue: "largeTitle")
    public static let subheadline   = Self.init(rawValue: "subheadline")
    public static let title         = Self.init(rawValue: "title")
    public static let bold          = Self.init(rawValue: "bold")
}
