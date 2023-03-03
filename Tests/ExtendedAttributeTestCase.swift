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
