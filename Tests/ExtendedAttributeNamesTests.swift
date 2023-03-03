@testable import XAttr
import XCTest

final class ExtendedAttributeNamesTests: XCExtendedAttributeTestCase {
    func test_fileWithoutAttributes_returnsEmptyArray() throws {
        let testFilePath = resourcesBundle.path(forResource: "01-SimpleFile", ofType: ".txt")!
        let testFile = NSURL(fileURLWithPath: testFilePath)

        let names = try testFile.extendedAttributeNames()

        XCTAssertIsEmpty(collection: names)
    }

    func test_nonExistingFile_throwsError() throws {
        let testFile = NSURL(fileURLWithPath: "file-does-not-exists.png", relativeTo: self.tempPath)
        XCTAssertThrowsError(try testFile.extendedAttributeNames()) { error in
            XCTAssertEqual(error.localizedDescription, "No such file or directory")
        }
    }

    func XCTAssert<T>(
        collection: any Collection<T>,
        contains value: T,
        message: (T) -> String = { "Collection must contain item '\($0)'." },
        file: StaticString = #filePath,
        line: UInt = #line
    ) where T: Equatable {
        guard !collection.contains(value) else { return }

        XCTFail(message(value), file: file, line: line)
    }

    func XCTAssertIsEmpty<T>(
        collection: T,
        message: (T) -> String = { "Collection contains \($0.count) items and is not empty." },
        file: StaticString = #filePath,
        line: UInt = #line
    ) where T: Collection {
        guard !collection.isEmpty else { return }

        XCTFail(message(collection), file: file, line: line)
    }
}
