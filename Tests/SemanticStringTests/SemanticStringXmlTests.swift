import XCTest
@testable import SemanticString

final class SemanticStringXmlTests: XCTestCase {
    func testParseSemanticStringWithTags() {
        let semanticString = SemanticString(xml: "hello <bold>world</bold>!")

        XCTAssertEqual(semanticString.description, "hello world!")

        let font = UIFont.boldSystemFont(ofSize: 14)
        let provider = SemanticStringAttributesProvider(commonAttributes: [:], styleAttributes: [.bold: [.font: font]])

        let attributedString = semanticString.getAttributedString(provider: provider)

        let expectedAttributedString = NSMutableAttributedString(string: "hello world!")
        expectedAttributedString.addAttribute(.font, value: font, range: NSRange(location: 6, length: 5))
        XCTAssertEqual(attributedString, expectedAttributedString)
    }

    func testParseSemanticStringWithNestedTags() {
        let semanticString = SemanticString(xml: "Lorem <_>ipsum <bold>dolor</bold> sit</_> amet")

        XCTAssertEqual(semanticString.description, "Lorem ipsum dolor sit amet")

        let font = UIFont.boldSystemFont(ofSize: 14)

        let provider = SemanticStringAttributesProvider(
            commonAttributes: [:],
            styleAttributes: [
                .bold: [.font: font],
                "_": [
                    .underlineStyle: NSUnderlineStyle.single.rawValue
                ]
        ])

        let attributedString = semanticString.getAttributedString(provider: provider)

        let expectedAttributedString = NSMutableAttributedString(string: "Lorem ipsum dolor sit amet")
        expectedAttributedString.addAttribute(.font, value: font, range: NSRange(location: 12, length: 5))
        expectedAttributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 6, length: 15))

        XCTAssertEqual(attributedString, expectedAttributedString)
    }

    func testParseSemanticString_nestedTagsShouldOverrideAttributesFromOuterTags() {
        let semanticString = SemanticString(xml: "Lorem <boldRed>ipsum <blue>dolor</blue> sit</boldRed> amet")

        XCTAssertEqual(semanticString.description, "Lorem ipsum dolor sit amet")

        let font = UIFont.boldSystemFont(ofSize: 14)

        let provider = SemanticStringAttributesProvider(
            commonAttributes: [:],
            styleAttributes: [
                "blue": [.foregroundColor: UIColor.blue],
                "boldRed": [
                    .foregroundColor: UIColor.red,
                    .font: font
                ]
            ]
        )

        let attributedString = semanticString.getAttributedString(provider: provider)

        let expectedAttributedString = NSMutableAttributedString(string: "Lorem ipsum dolor sit amet")
        expectedAttributedString.addAttributes([.foregroundColor: UIColor.red, .font: font], range: NSRange(location: 6, length: 15))
        expectedAttributedString.setAttributes([.foregroundColor: UIColor.blue, .font: font], range: NSRange(location: 12, length: 5))

        XCTAssertEqual(attributedString, expectedAttributedString)
    }

    static var allTests = [
        ("testParseSemanticStringWithTags", testParseSemanticStringWithTags),
        ("testParseSemanticStringWithNestedTags", testParseSemanticStringWithNestedTags),
        ("testParseSemanticString_nestedTagsShouldOverrideAttributesFromOuterTags", testParseSemanticString_nestedTagsShouldOverrideAttributesFromOuterTags)
    ]
}
