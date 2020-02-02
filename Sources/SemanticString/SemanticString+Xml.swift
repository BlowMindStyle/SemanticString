import Foundation

extension SemanticString {
    public init(xml string: SemanticString) {
        let content: Content = .dynamic { locale in
            SemanticString.parseXmlSemanticString(string, locale: locale)
        }

        self.components = [StringComponent(styles: [], content: content)]
    }

    private static func parseXmlSemanticString(_ semanticString: SemanticString, locale: Locale) -> SemanticString {
        let flatStringComponents = semanticString.components.flatMap { $0.mapToFlatStringComponent(locale: locale) }
        let tagMatches = flatStringComponents.enumerated()
            .flatMap { (index, component) in component.content.getTags(componentIndex: index) }

        var openedTags: [TagMatch] = []
        var balandedTags: [(opening: TagMatch, closing: TagMatch)] = []
        for tagMatch in tagMatches {
            if tagMatch.isOpening {
                openedTags.append(tagMatch)
            } else {
                if let openingTagIndex = openedTags.lastIndex(where: { $0.name == tagMatch.name }) {
                    balandedTags.append((openedTags[openingTagIndex], tagMatch))
                    openedTags.removeSubrange(openingTagIndex...)
                }
            }
        }

        let orderedTags = balandedTags.flatMap { [$0.opening, $0.closing] }.sorted()
        var orderedTagsIterator = orderedTags.makeIterator()
        var lastTagMatch: TagMatch? = nil
        var currentTextStyles: [TextStyle] = []
        var components: [StringComponent] = []
        for (index, component) in flatStringComponents.enumerated() {
            var matches: [TagMatch] = []
            if let match = lastTagMatch, match.componentIndex == index {
                matches.append(match)
                lastTagMatch = nil
            }

            while let match = orderedTagsIterator.next() {
                if match.componentIndex == index {
                    matches.append(match)
                } else {
                    lastTagMatch = match
                }
            }

            let newComponents = component.split(matches, currentTextStyles: &currentTextStyles)
            components.append(contentsOf: newComponents)
        }

        return SemanticString(components: components)
    }
}

extension SemanticString {
    public init(xmlResource: StringResourceType, args: CVarArg..., styles: [TextStyle] = []) {
        self.init(xml: SemanticString(resource: xmlResource, argsArray: args, styles: styles))
    }
}

extension SemanticString.StringInterpolation {
    public mutating func appendInterpolation(xml string: SemanticString) {
        appendInterpolation(SemanticString(xml: string))
    }
}

private struct TagMatch {
    let name: String
    let range: NSRange
    let isOpening: Bool
    let componentIndex: Int
}

extension TagMatch: Comparable {
    static func < (lhs: TagMatch, rhs: TagMatch) -> Bool {
        (lhs.componentIndex, lhs.range.location) < (rhs.componentIndex, rhs.range.location)
    }
}

private let tagRegex = try! NSRegularExpression(pattern: "<\\/?([^<>\\s/]*)>", options: [])

extension SemanticString {
    struct FlatStringComponent {
        var styles: [TextStyle]
        var content: FlatContent
    }

    enum FlatContent {
        case plain(String)
        case attributed(NSAttributedString)
    }
}

extension SemanticString.FlatContent {
    fileprivate func getTags(componentIndex: Int) -> [TagMatch] {
        let string: String
        switch self {
        case let .plain(plainString):
            string = plainString

        case let .attributed(attributedString):
            string = attributedString.string
        }

        let nsString = string as NSString

        let range = NSRange(location: 0, length: nsString.length)
        let matches = tagRegex.matches(in: string, options: [], range: range)
        let tagMatches: [TagMatch] = matches.map { match in
            let nameRange = match.range(at: 1)
            return TagMatch(name: nsString.substring(with: nameRange),
                            range: match.range,
                            isOpening: nameRange.length + 2 == match.range.length,
                            componentIndex: componentIndex)
        }

        return tagMatches
    }
}

extension SemanticString.StringComponent {
    fileprivate func mapToFlatStringComponent(locale: Locale) -> [SemanticString.FlatStringComponent] {
        let content: SemanticString.FlatContent
        switch self.content {
        case let .plain(string):
            content = .plain(string)

        case let .attributed(string):
            content = .attributed(string)

        case let .localizable(resource, args):
            let format = resource.localize(with: locale)
            content = .plain(String(format: format, arguments: args))

        case let .dynamic(provider):
            let components = provider(locale).components
            var flatComponents = components.flatMap { component in component.mapToFlatStringComponent(locale: locale) }
            for index in flatComponents.startIndex..<flatComponents.endIndex {
                flatComponents[index].styles = styles + flatComponents[index].styles
            }

            return flatComponents
        }

        return [SemanticString.FlatStringComponent(styles: styles, content: content)]
    }
}

extension SemanticString.FlatStringComponent {
    fileprivate func split(_ tagMatches: [TagMatch], currentTextStyles: inout [SemanticString.TextStyle]) -> [SemanticString.StringComponent] {
        switch content {
        case let .plain(string):
            return splitString(string, tagMatches, &currentTextStyles)

        case let .attributed(string):
            return splitAttributedString(string, tagMatches, &currentTextStyles)
        }
    }

    private func splitString(
        _ string: String,
        _ tagMatches: [TagMatch],
        _ currentTextStyles: inout [SemanticString.TextStyle])
        -> [SemanticString.StringComponent] {

            var components: [SemanticString.StringComponent] = []

            let nsString = string as NSString
            var beginIndex = 0

            for match in tagMatches {
                let textStyle = SemanticString.TextStyle(rawValue: match.name)
                let substring = nsString.substring(with: NSRange(location: beginIndex, length: match.range.location - beginIndex))
                if !substring.isEmpty {
                    components.append(.init(styles: currentTextStyles + self.styles, content: .plain(substring)))
                }
                if match.isOpening {
                    currentTextStyles.append(textStyle)
                } else if let index = currentTextStyles.lastIndex(of: textStyle) {
                    currentTextStyles.remove(at: index)
                }

                beginIndex = match.range.upperBound
            }

            let lastSubstring = nsString.substring(with: NSRange(location: beginIndex, length: nsString.length - beginIndex))
            if !lastSubstring.isEmpty {
                components.append(.init(styles: currentTextStyles + self.styles, content: .plain(lastSubstring)))
            }

            return components
    }

    private func splitAttributedString(
        _ attributedString: NSAttributedString,
        _ tagMatches: [TagMatch],
        _ currentTextStyles: inout [SemanticString.TextStyle])
        -> [SemanticString.StringComponent] {

            var components: [SemanticString.StringComponent] = []

            let nsString = attributedString.string as NSString
            var beginIndex = 0

            for match in tagMatches {
                let textStyle = SemanticString.TextStyle(rawValue: match.name)
                let substring = attributedString.attributedSubstring(
                    from: NSRange(location: beginIndex, length: match.range.location - beginIndex))
                if substring.length > 0 {
                    components.append(.init(styles: currentTextStyles + self.styles, content: .attributed(substring)))
                }

                if match.isOpening {
                    currentTextStyles.append(textStyle)
                } else if let index = currentTextStyles.lastIndex(of: textStyle) {
                    currentTextStyles.remove(at: index)
                }

                beginIndex = match.range.upperBound
            }

            let lastSubstring = attributedString.attributedSubstring(from: NSRange(location: beginIndex, length: nsString.length - beginIndex))
            if lastSubstring.length > 0 {
                components.append(.init(styles: currentTextStyles + self.styles, content: .attributed(lastSubstring)))
            }

            return components
    }
}
