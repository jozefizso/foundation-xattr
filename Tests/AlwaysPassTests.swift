import XCTest

/// Ensures at least one unit test will pass.
final class AlwaysPassTests: XCTestCase {
    func test_alwaysPass() throws {
        XCTAssertTrue(true, "This test will always pass.")
    }
}
