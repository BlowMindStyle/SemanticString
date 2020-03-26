import Foundation

extension SemanticString {
    /**
     Returns an uppercase version of the string.
     */
    public func uppercased() -> SemanticString {
        mapText(transformString: { $0.uppercased() }, transformAttributedString: { $0.uppercased() })
    }

    /**
     Returns a lowercase version of the string.
     */
    public func lowercased() -> SemanticString {
        mapText(transformString: { $0.lowercased() }, transformAttributedString: { $0.lowercased() })
    }
}

extension SemanticString {
    func mapContent(_ transform: (Content) -> Content) -> SemanticString {
        SemanticString(components: components.map { $0.mapContent(transform) })
    }

    func mapText(
        transformString: @escaping (String) -> String,
        transformAttributedString: @escaping (NSAttributedString) -> NSAttributedString)
        -> SemanticString {
            mapContent { component in
                switch component {
                case let .plain(string):
                    return .plain(transformString(string))

                case let .attributed(string):
                    return .attributed(transformAttributedString(string))

                case let .localizable(resource, args):
                    return .dynamic { locale in
                        let format = resource.localize(with: locale)
                        let string = transformString(String(format: format, arguments: args))
                        return SemanticString(string: string)
                    }

                case let .dynamic(provider):
                    return .dynamic { localeInfo in
                        provider(localeInfo)
                            .mapText(
                                transformString: transformString,
                                transformAttributedString: transformAttributedString)
                    }

                }
            }
    }
}

extension SemanticString.StringComponent {
    func mapContent(_ transform: (SemanticString.Content) -> SemanticString.Content) -> Self {
        .init(styles: styles, content: transform(content))
    }
}

extension NSAttributedString {
    func uppercased() -> NSAttributedString {
        transformString { $0.uppercased() }
    }

    func lowercased() -> NSAttributedString {
        transformString { $0.lowercased() }
    }

    func transformString(_ transform: @escaping (String) -> String) -> NSAttributedString {
        let result = NSMutableAttributedString(attributedString: self)

        result.enumerateAttributes(in: NSRange(location: 0, length: length), options: []) { _, range, _ in
            result.replaceCharacters(in: range, with: transform((string as NSString).substring(with: range)))
        }

        return result
    }
}
