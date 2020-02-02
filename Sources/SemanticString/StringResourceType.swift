import Foundation

public protocol StringResourceType {
    /// Key for the string
    var key: String { get }

    /// File in containing the string
    var tableName: String { get }

    /// Bundle this string is in
    var bundle: Bundle { get }
}

extension StringResourceType {
    public func localize(with locale: Locale?) -> String {
        let localeIdentifier: String = {
            guard let locale = locale, locale.identifier != "" else {
                return Bundle.main.preferredLocalizations.first ?? Locale.current.identifier
            }

            return locale.identifier
        }()

        let bundle = getFromCacheOrFindBundle(for: localeIdentifier, in: self.bundle) ?? self.bundle

        return bundle.localizedString(forKey: key, value: nil, table: tableName)
    }

    private func getFromCacheOrFindBundle(for localeIdentifier: String, in resourceBundle: Bundle) -> Bundle? {
            let result = LanguageBundleCache.shared.getBundle(for: localeIdentifier, in: resourceBundle)
            switch result {
            case .notExists: return nil
            case let .exists(bundle): return bundle
            case .missing:
                let bundle = findBundle(for: localeIdentifier, in: resourceBundle)
                LanguageBundleCache.shared.saveLanguageBundle(bundle, for: localeIdentifier, resourceBundle: resourceBundle)
                return bundle
            }
        }

    // https://developer.apple.com/library/archive/qa/qa1828/_index.html
    private func findBundle(for localeIdentifier: String, in resourceBundle: Bundle) -> Bundle? {
        let localeIdentifier = localeIdentifier.replacingOccurrences(of: "_", with: "-")
        let lprojBundlePaths = resourceBundle.paths(forResourcesOfType: "lproj", inDirectory: nil)

        if let localizationPath = getLprojPath(with: localeIdentifier, from: lprojBundlePaths) ??
            getLprojPath(with: localeIdentifier.replacingOccurrences(of: "-", with: "_"), from: lprojBundlePaths) {
            return Bundle(path: localizationPath)
        }

        let parts = localeIdentifier.split(separator: "-")
        guard parts.count >= 2 else { return nil }
        let genericLanguage = parts[0]
        guard let path = getLprojPath(with: String(genericLanguage), from: lprojBundlePaths) else { return nil }
        return Bundle(path: path)
    }

    private func getLprojPath(with name: String, from paths: [String]) -> String? {
        let lastComponent = "/\(name).lproj"

        return paths.first { path in
            guard let index = path.index(path.endIndex, offsetBy: -lastComponent.count, limitedBy: path.startIndex) else { return false }
            return lastComponent.caseInsensitiveCompare(path[index...]) == .orderedSame
        }
    }
}

private final class LanguageBundleCache {
    struct BundleLocaleIdKey: Hashable {
        let localeIdentifier: String
        let resourceBundle: Bundle
    }

    enum CacheResult<Value> {
        case notExists
        case missing
        case exists(Value)

        init(_ storedResult: StoredResult<Value>?) {
            switch storedResult {
            case .none:                 self = .missing
            case .notExists:            self = .notExists
            case let .exists(value):    self = .exists(value)
            }
        }
    }

    enum StoredResult<Value> {
        case notExists
        case exists(Value)
    }

    static let shared = LanguageBundleCache()

    private let queue = DispatchQueue(label: "BlowMindStyle.LanguageBundleCache.Queue", qos: .userInitiated, attributes: .concurrent)
    private var bundleCache: [BundleLocaleIdKey: StoredResult<Bundle>] = [:]

    func getBundle(for localeIdentifier: String, in resourceBundle: Bundle) -> CacheResult<Bundle> {
        let key = BundleLocaleIdKey(localeIdentifier: localeIdentifier.uppercased(), resourceBundle: resourceBundle)
        return queue.sync {
            CacheResult(bundleCache[key])
        }
    }

    func saveLanguageBundle(_ bundle: Bundle?, for localeIdentifier: String, resourceBundle: Bundle) {
        let result = bundle.map(StoredResult.exists) ?? .notExists
        let key = BundleLocaleIdKey(localeIdentifier: localeIdentifier.uppercased(), resourceBundle: resourceBundle)
        queue.async(flags: .barrier) {
            self.bundleCache[key] = result
        }
    }
}
