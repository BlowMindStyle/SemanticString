import Foundation

struct AttributedStringBuilder {
    static func build(components: [NSAttributedString], attributes: [NSAttributedString.Key: Any]) -> NSAttributedString {
        let result = NSMutableAttributedString()

        for component in components {
            let mutableCopy = NSMutableAttributedString(attributedString: component)
            var attributesToRestore: [(NSMutableAttributedString.Key, Any, NSRange)] = []
            for attr in attributes.keys {
                component.enumerateAttribute(attr, in: NSMakeRange(0, component.length), options: []) { (value, range, _) in
                    guard let value = value else { return }
                    attributesToRestore.append((attr, value, range))
                }
            }

            mutableCopy.addAttributes(attributes, range: NSMakeRange(0, component.length))
            for (key, value, range) in attributesToRestore {
                mutableCopy.addAttribute(key, value: value, range: range)
            }
            result.append(mutableCopy)
        }

        return result
    }

    static func join(components: [NSAttributedString]) -> NSAttributedString {
        let result = NSMutableAttributedString()
        for component in components {
            result.append(component)
        }

        return result
    }
}
