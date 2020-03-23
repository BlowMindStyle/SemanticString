import Foundation

extension SemanticString: ExpressibleByStringLiteral, ExpressibleByStringInterpolation {
    public struct StringInterpolation: StringInterpolationProtocol {
        var components: [SemanticString.StringComponent] = []

        public init(literalCapacity: Int, interpolationCount: Int) {
            components.reserveCapacity(interpolationCount)
        }

        public mutating func appendLiteral(_ literal: String) {
            components.append(.init(styles: [], content: .plain(literal)))
        }

        public mutating func appendInterpolation(resource: StringResourceType, args: CVarArg..., styles: [TextStyle] = []) {
            components.append(.init(styles: styles, content: .localizable(resource, args)))
        }

        public mutating func appendInterpolation(resource: StringResourceType, argsArray: [CVarArg], styles: [TextStyle] = []) {
            components.append(.init(styles: styles, content: .localizable(resource, argsArray)))
        }

        public mutating func appendInterpolation(_ string: SemanticString) {
            components.append(contentsOf: string.components)
        }

        public mutating func appendInterpolation(_ string: NSAttributedString, styles: [TextStyle] = []) {
            components.append(.init(styles: styles, content: .attributed(string)))
        }

        public mutating func appendInterpolation(style: TextStyle, _ string: SemanticString) {
            for component in string.components {
                components.append(.init(styles: [style] + component.styles, content: component.content))
            }
        }

        public mutating func appendInterpolation(styles: [TextStyle], _ string: SemanticString) {
            for component in string.components {
                components.append(.init(styles: styles + component.styles, content: component.content))
            }
        }

        public mutating func appendInterpolation<Value: CustomStringConvertible>(_ value: Value, styles: [TextStyle] = []) {
            components.append(.init(styles: styles, content: .plain(value.description)))
        }

        public mutating func appendInterpolation(dynamic provider: @escaping (Locale) -> SemanticString, styles: [TextStyle] = []) {
            components.append(.init(styles: styles, content: .dynamic(provider)))
        }
    }

    public init(stringLiteral value: String) {
        components = [.init(styles: [], content: .plain(value))]
    }

    public init(stringInterpolation: StringInterpolation) {
        components = stringInterpolation.components
    }

    public init(resource: StringResourceType, args: CVarArg..., styles: [TextStyle] = []) {
        components = [.init(styles: styles, content: .localizable(resource, args))]
    }

    public init(resource: StringResourceType, argsArray: [CVarArg], styles: [TextStyle] = []) {
        components = [.init(styles: styles, content: .localizable(resource, argsArray))]
    }

    public init(_ string: SemanticString) {
        components = string.components
    }

    public init(string: String) {
        components = [.init(styles: [], content: .plain(string))]
    }

    public init(dynamic provider: @escaping (Locale) -> SemanticString, styles: [TextStyle] = []) {
        components = [.init(styles: styles, content: .dynamic(provider))]
    }

    public init(_ attributedString: NSAttributedString, styles: [TextStyle] = []) {
        components = [.init(styles: styles, content: .attributed(attributedString))]
    }
}
