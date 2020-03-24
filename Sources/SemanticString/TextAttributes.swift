import Foundation
import UIKit

/**
 Wrapper for `NSAttributedString` attributes with type-safe access to values.
 */
public struct TextAttributes {
    /// attributes dictionary that can be used with `NSAttributedString`
    public var dictionary: [NSAttributedString.Key : Any]

    public init(dictionary: [NSAttributedString.Key : Any] = [:]) {
        self.dictionary = dictionary
    }
}

extension TextAttributes {
    public subscript<Value>(key: NSAttributedString.Key) -> Value? {
        get {
            dictionary[key] as? Value
        }
        set {
            dictionary[key] = newValue
        }
    }
}

extension TextAttributes: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (NSAttributedString.Key, Any)...) {
        dictionary = Dictionary(uniqueKeysWithValues: elements)
    }
}

extension TextAttributes {
    /**
     copies text attributes from `other` to `self`
     */
    public mutating func merge(with other: TextAttributes) {
        for (key, value) in other.dictionary {
            dictionary[key] = value
        }
    }
}

extension TextAttributes {
    public var attachment: NSTextAttachment? {
        get { dictionary[.attachment] as? NSTextAttachment }
        set { dictionary[.attachment] = newValue }
    }

    public var backgroundColor: UIColor? {
        get { dictionary[.backgroundColor] as? UIColor }
        set { dictionary[.backgroundColor] = newValue }
    }

    public var baselineOffset: NSNumber? {
        get { dictionary[.baselineOffset] as? NSNumber }
        set { dictionary[.baselineOffset] = newValue }
    }

    public var font: UIFont? {
        get { dictionary[.font] as? UIFont }
        set { dictionary[.font] = newValue }
    }

    public var foregroundColor: UIColor? {
        get { dictionary[.foregroundColor] as? UIColor }
        set { dictionary[.foregroundColor] = newValue }
    }

    public var kern: NSNumber? {
        get { dictionary[.kern] as? NSNumber }
        set { dictionary[.kern] = newValue }
    }

    public var link: URL? {
        get { dictionary[.link] as? URL }
        set { dictionary[.link] = newValue }
    }

    public var paragraphStyle: NSParagraphStyle? {
        get { dictionary[.paragraphStyle] as? NSParagraphStyle }
        set { dictionary[.paragraphStyle] = newValue }
    }

    public var shadow: NSShadow? {
        get { dictionary[.shadow] as? NSShadow }
        set { dictionary[.shadow] = newValue }
    }

    public var strokeColor: UIColor? {
        get { dictionary[.strokeColor] as? UIColor }
        set { dictionary[.strokeColor] = newValue }
    }

    public var strokeWidth: NSNumber? {
        get { dictionary[.strokeWidth] as? NSNumber }
        set { dictionary[.strokeWidth] = newValue }
    }

    public var textEffect: NSAttributedString.TextEffectStyle? {
        get { dictionary[.textEffect] as? NSAttributedString.TextEffectStyle }
        set { dictionary[.textEffect] = newValue }
    }

    public var underlineColor: UIColor? {
        get { dictionary[.underlineColor] as? UIColor }
        set { dictionary[.underlineColor] = newValue }
    }

    public var underlineStyle: NSUnderlineStyle? {
        get { dictionary[.underlineStyle] as? NSUnderlineStyle }
        set { dictionary[.underlineStyle] = newValue }
    }
}
