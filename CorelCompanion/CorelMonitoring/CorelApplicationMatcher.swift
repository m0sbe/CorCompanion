import Foundation

enum CorelApplicationMatcher {
    static let supportedBundleIdentifiers: Set<String> = [
        "com.corel.coreldrawsuite.2026.coreldraw"
    ]

    static func matches(bundleIdentifier: String?) -> Bool {
        guard let bundleIdentifier else { return false }
        if supportedBundleIdentifiers.contains(bundleIdentifier) { return true }
        return bundleIdentifier.hasPrefix("com.corel.coreldrawsuite.") && bundleIdentifier.hasSuffix(".coreldraw")
    }
}
