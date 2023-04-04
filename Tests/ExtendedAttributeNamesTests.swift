// ISC License
//
// Copyright 2023 Cisco Systems, Inc.
// Copyright (c) 2023, Jozef Izso and contributors
//
// Permission to use, copy, modify, and/or distribute this software for any
// purpose with or without fee is hereby granted, provided that the above
// copyright notice and this permission notice appear in all copies.
//
// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
// WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
// ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
// WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
// ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
// OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

@testable import XAttr
import XCTest

final class ExtendedAttributeNamesTests: XCExtendedAttributeTestCase {
    func test_fileWithoutAttributes_returnsEmptyArray() throws {
        let testFilePath = resourcesBundle.path(forResource: "01-SimpleFile", ofType: ".txt")!
        let testFile = URL(fileURLWithPath: testFilePath)

        let names = try testFile.extendedAttributeNames()

        XCTAssertIsEmpty(collection: names)
    }

    func test_nonExistingFile_throwsError() throws {
        let testFile = URL(fileURLWithPath: "file-does-not-exists.png", relativeTo: self.tempPath)
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
