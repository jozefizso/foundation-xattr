import XCTest

class XCExtendedAttributeTestCase: XCTestCase {
    internal private(set) var xctestBundle = Bundle(for: XCExtendedAttributeTestCase.self)
    internal private(set) var resourcesBundle = Bundle()
    internal private(set) var tempPath = URL(string: "/tmp/xattr_tests")

    override func setUp() async throws {
        let innerBundlePath = self.xctestBundle.path(forResource: "XAttr_XAttrTests", ofType: ".bundle")
        if let innerBundle = Bundle(path: innerBundlePath!) {
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
