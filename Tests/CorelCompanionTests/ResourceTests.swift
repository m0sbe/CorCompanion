import AppKit
import XCTest
@testable import CorelCompanion

final class ResourceTests: XCTestCase {
    func testBrandLogoIsBundledAndReadable() throws {
        let url = try XCTUnwrap(
            ResourceBundle.current.url(forResource: "M0sbeeLogo", withExtension: "svg")
        )
        XCTAssertNotNil(NSImage(contentsOf: url))
    }
}
