import XCTest
@testable import CorelCompanion

final class CorelApplicationMatcherTests: XCTestCase {
    func testVerified2026IdentifierMatches() {
        XCTAssertTrue(CorelApplicationMatcher.matches(bundleIdentifier: "com.corel.coreldrawsuite.2026.coreldraw"))
    }

    func testNearbyCorelReleasePatternMatches() {
        XCTAssertTrue(CorelApplicationMatcher.matches(bundleIdentifier: "com.corel.coreldrawsuite.2027.coreldraw"))
    }

    func testPhotoPaintAndUnrelatedAppsDoNotMatch() {
        XCTAssertFalse(CorelApplicationMatcher.matches(bundleIdentifier: "com.corel.coreldrawsuite.2026.photopaint"))
        XCTAssertFalse(CorelApplicationMatcher.matches(bundleIdentifier: "com.example.coreldraw"))
        XCTAssertFalse(CorelApplicationMatcher.matches(bundleIdentifier: nil))
    }
}
