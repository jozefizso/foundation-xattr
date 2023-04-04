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

import XCTest

class XCExtendedAttributeTestCase: XCTestCase {
    static let ResourcesBundleName = "XAttr_XAttrTests"

    internal private(set) var xctestBundle = Bundle(for: XCExtendedAttributeTestCase.self)
    internal private(set) var resourcesBundle = Bundle()
    internal private(set) var tempPath = URL(string: "/tmp/xattr_tests")

    override func setUp() async throws {
        // if running inside Xcode there will be special `XAttr_XAttrTests.bundle` inside xctest bundle:
        let innerBundlePath = self.xctestBundle.path(forResource: XCExtendedAttributeTestCase.ResourcesBundleName, ofType: ".bundle")
        if innerBundlePath == nil {
            // we are running from `swift test`, we must find the bundle near xctest
            let bundleUrl = xctestBundle.bundleURL.deletingLastPathComponent().appendingPathComponent(XCExtendedAttributeTestCase.ResourcesBundleName + ".bundle")

            self.resourcesBundle = Bundle(url: bundleUrl)!
        }
        else if let innerBundle = Bundle(path: innerBundlePath!) {
            self.resourcesBundle = innerBundle
        }

        let uuid = URL(fileURLWithPath: "xattr_tests")

        self.tempPath = try FileManager.default.url(
            for: .itemReplacementDirectory,
            in: .userDomainMask,
            appropriateFor: uuid,
            create: true
        )
    }
}
