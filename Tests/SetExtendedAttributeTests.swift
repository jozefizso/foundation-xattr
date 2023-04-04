@testable import XAttr
import XCTest

final class SetExtendedAttributeTests: XCTestCase {
    func test_URL_setExtendedAttribute() throws {
        // Arrange
        let file = URL(fileURLWithPath: "/Users/jozef/Developer/foundation-xattr/tmp/myfile.txt")
        let attributeValue = "value".data(using: .utf8)!

        // Act
        try file.setExtendedAttribute(name: "com.example.attribute", value: attributeValue)

        // Assert
        XCTAssertTrue(true)
    }
}
