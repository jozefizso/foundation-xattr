# XAttr

XAttr makes working with [Extended Attributes][wiki-xattr] a natural part of Foundation. Both `NSURL` and `NSFileHandle` objects gain the ability to read and write extended attributes using an API that fits right in with Cocoa. Add the power of metadata to your app!

Works with iOS, macOS, watchOS and tvOS.

For more info on Darwin's extended attribute APIs – which underlie this module – see Apple's man pages for [listxattr][man-listxattr], [getxattr][man-getxattr], [setxattr][man-setxattr], and [removexattr][man-removexattr].


## Example

Here's a simple example of working with extended attributes using a file URL:

```swift
let myURL = NSURL(fileURLWithPath: "/path/to/file")

let data = "value".dataUsingEncoding(NSUTF8StringEncoding)!

// Set an attribute
try myURL.setExtendedAttribute(name: "com.example.attribute", value: data)
// List attributes
let names = try myURL.extendedAttributeNames()
// Get an attribute's value
let value = try myURL.extendedAttributeValue(forName: "com.example.attribute")
// Remove an attribute
try myURL.removeExtendedAttribute(forName: "com.example.attribute")

// Set multiple attributes
try myURL.setExtendedAttributes(["com.example.attribute1": data, "com.example.attribute2": data])
// Get multiple attributes' values (all available)
let attrs = try myURL.extendedAttributeValues(forNames: nil)
// Remove multiple attributes (all)
try myURL.removeExtendedAttributes(forNames: nil)
```


## Installation

Requires Swift 5.3.

### Swift Package Manager

Add XAttr as a dependency to your project:

```swift
// Package.swift

import PackageDescription

let package = Package(
    name: "YourProjectName",
    dependencies: [
        .package(url: "https://github.com/jozefizso/swift-xattr", majorVersion: 1),
    ]
)
```

### Source

If you cannot use the Swift Package Manager, just copy the `Sources/XAttr.swift` file into your project.


## Usage

XAttr is easy to use. This section contains the all the basic information required. Be sure to check out the Quick Help in Xcode for more detail.

### Methods

The following methods are available to both `NSURL` and `NSFileHandle` objects:

#### Retrieving an Attribute's Value

```swift
extendedAttributeValue(forName: String, options: XAttrOptions = []) throws -> NSData
```

#### Retrieving Multiple Attributes' Values

```swift
extendedAttributeValues(forNames: [String]?, options: XAttrOptions = []) throws -> [String: NSData]
```

Supply a list of names to retrieve, or `nil` to retrieve all available attributes.

#### Setting an Attribute's Value

```swift
setExtendedAttribute(name: String, value: NSData, options: XAttrOptions = []) throws
```

#### Setting Multiple Attributes' Values

```swift
setExtendedAttributes(_: [String: NSData], options: XAttrOptions = []) throws
```

Supply a dictionary of _name_:_value_ pairs to be set on the target.

#### Listing Attribute Names

```swift
extendedAttributeNames(options: XAttrOptions = []) throws -> [String]
```

#### Removing an Extended Attribute

```swift
removeExtendedAttribute(forName: String, options: XAttrOptions = []) throws
```

#### Removing Multiple Extended Attributes

```swift
removeExtendedAttributes(forNames: [String]?, options: XAttrOptions = []) throws
```

Supply a list of names to remove, or `nil` to remove all existing attributes.

### Options

`XAttrOptions` provides the following options:

| Option            | Description                                          | Get | Set | List | Remove |
| ----------------- | ---------------------------------------------------- | :-: | :-: | :--: | :----: |
| `NoFollow`        | Do not follow symbolic links.                        |  x  |  x  |   x  |    x   |
| `CreateOnly`      | Fail if the named attribute already exists.          |     |  x  |      |        |
| `ReplaceOnly`     | Fail if the named attribute does not already exist.  |     |  x  |      |        |
| `ShowCompression` | Show or remove HFS+ compression extended attributes. |  x  |     |   x  |    x   |

**Note:** If neither `CreateOnly` nor `ReplaceOnly` are specified, the attribute will be created/updated regardless of its current status.

### Errors

An `NSError` will be thrown if the system is not able to get/set/list/remove an extended attribute. The error will have the Foundation built-in _domain_ `NSPOSIXErrorDomain`. The error's _code_ property will represent the POSIX error code reported by the system, and the error's _localizedDescription_ property will contain an explanation of the error.

Additionally, if the system was able to retrieve an attribute's name, but was not able to decode it, an `NSError` with the Foundation built-in _domain_ `NSCocoaErrorDomain` and _code_ `NSFileReadInapplicableStringEncodingError` will be thrown.

Finally, if an error is encountered while getting/setting/removing multiple extended attributes, the specific attribute that caused the error will be named in the error's _userInfo_ dictionary, at the key `ExtendedAttributeNameKey`.


## License

XAttr is licensed under the permissive [ISC License][license].  
XAttr is a fork of [Foundation-XAttr][upstream] repository.


[wiki-xattr]: https://en.wikipedia.org/wiki/Extended_file_attributes
[man-listxattr]: https://developer.apple.com/library/ios/documentation/System/Conceptual/ManPages_iPhoneOS/man2/listxattr.2.html
[man-getxattr]: https://developer.apple.com/library/ios/documentation/System/Conceptual/ManPages_iPhoneOS/man2/getxattr.2.html
[man-setxattr]: https://developer.apple.com/library/ios/documentation/System/Conceptual/ManPages_iPhoneOS/man2/setxattr.2.html
[man-removexattr]: https://developer.apple.com/library/ios/documentation/System/Conceptual/ManPages_iPhoneOS/man2/removexattr.2.html
[license]: LICENSE.txt
[upstream]: https://github.com/overbuilt/foundation-xattr
