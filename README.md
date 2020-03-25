![Cocoapods platforms](https://img.shields.io/cocoapods/p/SemanticString.svg)
[![pod](https://img.shields.io/cocoapods/v/SemanticString.svg)](https://cocoapods.org/pods/SemanticString)
[![Swift Package Manager compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)

# SemanticString

 `SemanticString` is string abstraction that includes information about structural semantics for text.
 This information allows applying stylization to the text, forming a result of the `NSAttributedString` type.


#### Basic usage.
In the example we make "hello **world**!" text with highlighted word "world":
 ```swift
let text = SemanticString("Hello \(style: .bold, "world")!")
// or let text = SemanticString(xml: "Hello <bold>world</bold>!")

// object that provides text attributes
let provider = SemanticStringAttributesProvider(
    commonAttributes: [.font: UIFont.systemFont(ofSize: 14)],
    styleAttributes: [
        .bold: [.font: UIFont.boldSystemFont(ofSize: 14)]
    ]
)

let attributedText = text.getAttributedString(provider: provider)
 ```

 ## Requirements

* Swift 5.1

 ## Installation

 ### [CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html)

 ```ruby
# Podfile
use_frameworks!

target 'YOUR_TARGET_NAME' do
    pod 'SemanticString'
end
```

### [Swift Package Manager](https://github.com/apple/swift-package-manager)

In XCode select File/Swift Packages/Add Package Dependency. Type 'SemanticString', select `SemanticString` project and click 'Next', 'Next'


## Using with [R.swift](https://github.com/mac-cain13/R.swift)

If your app should support changing language at runtime, R.swift can be used to provide convenient access to string resources. `SemanticString` created from string resource not depends on the locale and can be used to update text on the screen. This lets you provide language-agnostic strings from services, which can be used to refresh UI without needing to recalculate data.

Code to add `Rswift.StringResource` conforming to `SemanticString.StringResourceType`:
```swift
import Rswift
import protocol SemanticString.StringResourceType

extension Rswift.StringResource: StringResourceType { }
```

Example of usage:
```swift
let string = SemanticString(resource: R.string.localizable.helloWorld)
print(string)
SemanticString.setCurrentLocale(Locale(identifier: "ru-RU"))
print(string)
```

Tip:
Use `typealias` to shorten string resource paths.
```swift
typealias Strings = R.string.localizable
```