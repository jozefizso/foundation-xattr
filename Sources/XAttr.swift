// ISC License
//
// Copyright (c) 2016, Justin Pawela and contributors
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

import Foundation


// ===========================================================================
// MARK: Constants
// ===========================================================================

/// The corresponding value is the extended attribute name that caused the error.
public let ExtendedAttributeNameKey: String = "tech.overbuilt.userInfoKey.extendedAttributeName"


// ===========================================================================
// MARK: Options
// ===========================================================================

/// Options that control how extended attributes are accessed.
///
/// - important: Options `.CreateOnly` and `.ReplaceOnly` are mutually exclusive. However, neither option is required,
///              and supplying neither when setting an extended attribute allows for both creation and replacement.
public struct XAttrOptions: OptionSet {
    public let rawValue: CInt

    public init(rawValue: CInt) { self.rawValue = rawValue }

    /// Do not follow symbolic links. Honored when listing, getting, setting, and removing.
    public static let NoFollow        = XAttrOptions(rawValue: XATTR_NOFOLLOW)
    /// Fail if the named attribute already exists. Honored when setting.
    public static let CreateOnly      = XAttrOptions(rawValue: XATTR_CREATE)
    /// Fail if the named attribute does not already exist. Honored when setting.
    public static let ReplaceOnly     = XAttrOptions(rawValue: XATTR_REPLACE)
    /// Show or remove HFS+ compression extended attributes. Honored when listing, getting, and removing.
    public static let ShowCompression = XAttrOptions(rawValue: XATTR_SHOWCOMPRESSION)
//    public static let NoSecurity      = XAttrOptions(rawValue: XATTR_NOSECURITY)   //TODO: Investigate this option
//    public static let NoDefault       = XAttrOptions(rawValue: XATTR_NODEFAULT)    //TODO: Investigate this option

}


// ===========================================================================
// MARK: Protocol ExtendedAttributeHandler
// ===========================================================================

/// Has the ability to manipulate extended attributes associated with file system objects.
///
/// Implementations of the following methods are required:
/// - requires: `extendedAttributeNames(options:)`
/// - requires: `extendedAttributeValue(forName:options:)`
/// - requires: `setExtendedAttribute(name:value:options:)`
/// - requires: `removeExtendedAttribute(forName:options:)`
public protocol ExtendedAttributeHandler {
    /// Retrieve a list of extended attribute names associated with a file system object.
    func extendedAttributeNames(options options: XAttrOptions) throws -> [String]
    /// Retrieve the value for the extended attribute specified by _name_ associated with a file system object.
    func extendedAttributeValue(forName name: String, options: XAttrOptions) throws -> NSData
    /// Set a _name_:_value_ extended attribute on a file system object.
    func setExtendedAttribute(name name: String, value: NSData, options: XAttrOptions) throws
    /// Remove the extended attribute specified by _name_ associated with a file system object.
    func removeExtendedAttribute(forName name: String, options: XAttrOptions) throws
    /// Retrieve the values for multiple extended attributes. A default implementation of this method is provided.
    func extendedAttributeValues(forNames names: [String]?, options: XAttrOptions) throws -> [String: NSData]
    /// Set multiple extended attributes. A default implementation of this method is provided.
    func setExtendedAttributes(attrs: [String: NSData], options: XAttrOptions) throws
    /// Remove multiple extended attributes. A default implementation of this method is provided.
    func removeExtendedAttributes(forNames names: [String]?, options: XAttrOptions) throws

}


// ===========================================================================
// MARK: ExtendedAttributeManager Default Implementations
// ===========================================================================

/// Provides default implementations of convenience `ExtendedAttributeHandler` methods.
extension ExtendedAttributeHandler {

    /// Retrieve the values for multiple extended attributes of a file system object.
    ///
    /// Any names that do not match existing extended attributes will be ignored. If `forNames` is `nil`, all
    /// existing extended attributes will be returned.
    ///
    /// - complexity: O(n)
    ///
    /// - parameter forNames: A list of names of extended attributes to retrieve. Defaults to `nil`.
    /// - parameter options:  An array of `XAttrOption` values that control how the extended attributes are retrieved.
    ///                       Defaults to no options.
    ///
    /// - throws: `NSError` with Foundation built-in domain `NSPOSIXErrorDomain`. Check the _code_ property for the
    ///           error's POSIX error code, and the _localizedDescription_ property for a description of the error.
    ///           The name of the specific extended attribute that caused the error can be found in the _userInfo_
    ///           dictionary at the key `ExtendedAttributeNameKey`.
    public func extendedAttributeValues(forNames names: [String]? = nil, options: XAttrOptions = []) throws -> [String: NSData] {
        let targetNames = try names ?? self.extendedAttributeNames(options: options)
        var attrs: [String: NSData] = Dictionary(minimumCapacity: targetNames.count)
        try targetNames.forEach({ name in
            do { attrs[name] = try self.extendedAttributeValue(forName: name, options: options) }
            catch let error as NSError where error.errno == ENOATTR { /* Skip this name that does not exist */ }
        })
        return attrs
    }

    /// Set multiple extended attributes on a file system object.
    ///
    /// - complexity:    O(n)
    /// - postcondition: Each extended attribute will be set unless its name is a zero-length string or a string
    ///                  containing only NUL characters, in which case that attribute will not be set
    ///                  and *no error will be thrown*.
    ///
    /// - parameter attrs:   The name:value extended attribute pairs to be set.
    /// - parameter options: An array of `XAttrOption` values that control how the extended attributes are set.
    ///                      Defaults to no options.
    ///
    /// - throws: `NSError` with Foundation built-in domain `NSPOSIXErrorDomain`. Check the _code_ property for the
    ///           error's POSIX error code, and the _localizedDescription_ property for a description of the error.
    ///           The name of the specific extended attribute that caused the error can be found in the _userInfo_
    ///           dictionary at the key `ExtendedAttributeNameKey`.
    public func setExtendedAttributes(attrs: [String: NSData], options: XAttrOptions = []) throws {
        try attrs.forEach({ name, value in try self.setExtendedAttribute(name: name, value: value, options: options) })
    }

    /// Remove multiple extended attributes from a file system object.
    ///
    /// Any names that do not match existing extended attributes will be ignored. If `forNames` is `nil`, all
    /// existing extended attributes will be removed.
    ///
    /// - complexity: O(n)
    ///
    /// - parameter forNames: A list of names of extended attributes to remove. Defaults to `nil`.
    /// - parameter options:  An array of `XAttrOption` values that control how the extended attributes are removed.
    ///                       Defaults to no options.
    ///
    /// - throws: `NSError` with Foundation built-in domain `NSPOSIXErrorDomain`. Check the _code_ property for the
    ///           error's POSIX error code, and the _localizedDescription_ property for a description of the error.
    ///           The name of the specific extended attribute that caused the error can be found in the _userInfo_
    ///           dictionary at the key `ExtendedAttributeNameKey`.
    public func removeExtendedAttributes(forNames names: [String]? = nil, options: XAttrOptions = []) throws {
        let targetNames = try names ?? self.extendedAttributeNames(options: options)
        try targetNames.forEach({ name in
            do { try self.removeExtendedAttribute(forName: name, options: options) }
            catch let error as NSError where error.errno == ENOATTR { /* Skip this name that does not exist */ }
        })
    }

}


// ===========================================================================
// MARK: Wrappers
// ===========================================================================

/// Lists the extended attribute names associated with a file system object.
///
/// This private generic wrapper function facilitates listing extended attribute names of a file identified via
/// either file descriptor or path.
///
/// - important: The type of the `target` parameter must match the type of the first parameter in `listFunc`. For
///              example, if `listFunc` is Darwin's `listxattr`, then `target` must be a file system path.
/// - seealso:   The [Darwin `listxattr` man page][man] for more detail on the options this function honors, and the
///              errors it may produce.
///
/// - parameter target:   The file system object from which to retrieve the extended attribute names.
/// - parameter options:  An array of `XAttrOption` values that control how the extended attribute names are retrieved.
/// - parameter listFunc: Accepts either of Darwin's built-in `listxattr` or `flistxattr` functions.
///
/// - returns: A list of extended attribute names associated with the file system object. If no extended attributes
///            exist, an empty list is returned.
///
/// - throws: If the system cannot retrieve the extended attribute names, an `NSError` with Foundation built-in
///           domain `NSPOSIXErrorDomain` is thrown. Check the _code_ property for the error's POSIX error code,
///           and the _localizedDescription_ property for a description of the error. If the attribute names are
///           retrieved, but cannot be read due to bad encoding, an `NSError` with Foundation built-in domain
///           `NSCocoaErrorDomain` and error code `NSFileReadInapplicableStringEncodingError` is thrown.
///
/// [man]: https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man2/listxattr.2.html
private func listXAttr<T>(target target: T, options: XAttrOptions, listFunc: (T, UnsafeMutablePointer<CChar>, size_t, CInt) -> ssize_t) throws -> [String] {
    assert(options.isSubsetOf([.NoFollow, .ShowCompression]),
        "Extended attribute lister only supports the following XAttrOptions: .NoFollow, .ShowCompression")

    let size = listFunc(target, nil, 0, options.rawValue)               // Get the size of the attributes' names.
    switch size {
        case  0: return []                                              // Size 0 means no data, so we short circuit.
        case -1: throw NSError.POSIX(errno: errno)                      // Error reading the attributes' names.
        default: break                                                  // Got the size, continue on.
    }

    let data = NSMutableData(length: size)!                             // This allocation should never fail.
    guard listFunc(target, UnsafeMutablePointer<CChar>(data.mutableBytes), data.length, options.rawValue) != -1 else {
        throw NSError.POSIX(errno: errno)
    }

    guard let list = String(data: data, encoding: .utf8) else {
        throw NSError(domain: NSCocoaErrorDomain, code: NSFileReadInapplicableStringEncodingError, userInfo: [
            NSLocalizedDescriptionKey: "Could not decode extended attribute names.",
            NSStringEncodingErrorKey: NSNumber(value: NSUTF8StringEncoding),
        ])
    }
    return list.componentsSeparatedByString("\0").filter({ !$0.isEmpty })
}

/// Gets an extended attribute value from a file system object.
///
/// This private generic wrapper function facilitates reading extended attribute values of a file identified via
/// either file descriptor or path.
///
/// - important: The type of the `target` parameter must match the type of the first parameter in `getFunc`. For
///              example, if `getFunc` is Darwin's `fgetxattr`, then `target` must be a file descriptor.
/// - seealso:   The [Darwin `getxattr` man page][man] for more detail on the options this function honors, and the
///              errors it may produce.
///
/// - parameter target:  The file system object from which to retrieve the extended attribute value.
/// - parameter name:    The name of extended attribute to retrieve data from.
/// - parameter options: An array of `XAttrOption` values that control how the extended attribute value is retrieved.
/// - parameter getFunc: Accepts either of Darwin's built-in `getxattr` or `fgetxattr` functions.
///
/// - returns: The value retrieved from a file system object's extended attribute associated with _name_. If the
///            extended attribute _name_ exists, but holds no data, an empty data object is returned.
///
/// - throws: `NSError` with Foundation built-in domain `NSPOSIXErrorDomain`. Check the _code_ property for the
///           error's POSIX error code, and the _localizedDescription_ property for a description of the error.
///
/// [man]: https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man2/getxattr.2.html
private func getXAttr<T>(target target: T, name: String, options: XAttrOptions, getFunc: (T, UnsafePointer<CChar>, UnsafeMutablePointer<Void>, size_t, CUnsignedInt, CInt) -> ssize_t) throws -> NSData {
    assert(options.isSubsetOf([.NoFollow, .ShowCompression]),
        "Extended attribute getter only supports the following XAttrOptions: .NoFollow, .ShowCompression")

    let size = getFunc(target, name, nil, 0, 0, options.rawValue)       // Get the size of the attribute's value.
    switch size {
        case  0: return NSData()                                        // Size 0 means no data, so we short circuit.
        case -1: throw NSError.POSIX(errno: errno, userInfo: [ExtendedAttributeNameKey: name]) // Error reading.
        default: break                                                  // Got the size, continue on.
    }

    let data = NSMutableData(length: size)!                             // This allocation should never fail.
    guard getFunc(target, name, data.mutableBytes, data.length, 0, options.rawValue) != -1 else {
        throw NSError.POSIX(errno: errno, userInfo: [ExtendedAttributeNameKey: name]) // Error decoding value.
    }
    return data
}

/// Sets an extended attribute on a file system object.
///
/// This private generic wrapper function facilitates setting extended attributes on a file identified via
/// either file descriptor or path.
///
/// - postcondition: The extended attribute name:value pair will be set on the file system object unless _name_ is a
///                  zero-length string or a string containing only NUL characters, in which case no attribute will
///                  be set and *no error will be thrown*.
/// - important: The type of the `target` parameter must match the type of the first parameter in `setFunc`. For
///              example, if `setFunc` is Darwin's `setxattr`, then `target` must be a file system path.
/// - seealso:   The [Darwin `setxattr` man page][man] for more detail on the options this function honors, and the
///              errors it may produce.
///
/// - parameter target:  The file system object on which to set the extended attribute.
/// - parameter name:    The name of extended attribute to be set.
/// - parameter value:   The value for the extended attribute to be set at _name_.
/// - parameter options: An array of `XAttrOption` values that control how the extended attribute is set.
/// - parameter setFunc: Accepts either of Darwin's built-in `setxattr` or `fsetxattr` functions.
///
/// - throws: `NSError` with Foundation built-in domain `NSPOSIXErrorDomain`. Check the _code_ property for the
///           error's POSIX error code, and the _localizedDescription_ property for a description of the error.
///
/// [man]: https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man2/setxattr.2.html
private func setXAttr<T>(target target: T, name: String, value: NSData, options: XAttrOptions, setFunc: (T, UnsafePointer<CChar>, UnsafePointer<Void>, size_t, CUnsignedInt, CInt) -> CInt) throws {
    assert(options.isSubsetOf([.NoFollow, .CreateOnly, .ReplaceOnly]),
        "Extended attribute setter only supports the following XAttrOptions: .NoFollow, .CreateOnly, .ReplaceOnly")

    guard setFunc(target, name, value.bytes, value.length, 0, options.rawValue) == 0 else {
        throw NSError.POSIX(errno: errno, userInfo: [ExtendedAttributeNameKey: name])
    }
}

/// Removes an extended attribute from a file system object.
///
/// This private generic wrapper function facilitates removing extended attributes from a file identified via
/// either file descriptor or path.
///
/// - important: The type of the `target` parameter must match the type of the first parameter in `delFunc`. For
///              example, if `delFunc` is Darwin's `fremovexattr`, then `target` must be a file descriptor.
/// - seealso:   The [Darwin `removexattr` man page][man] for more detail on the options this function honors, and the
///              errors it may produce.
///
/// - parameter target:  The file system object from which to remove the extended attribute.
/// - parameter name:    The name of extended attribute to be removed.
/// - parameter options: An array of `XAttrOption` values that control how the extended attribute is removed.
/// - parameter delFunc: Accepts either of Darwin's built-in `removexattr` or `fremovexattr` functions.
///
/// - throws: `NSError` with Foundation built-in domain `NSPOSIXErrorDomain`. Check the _code_ property for the
///           error's POSIX error code, and the _localizedDescription_ property for a description of the error.
///
/// [man]: https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man2/removexattr.2.html
private func removeXAttr<T>(target target: T, name: String, options: XAttrOptions, delFunc: (T, UnsafePointer<CChar>, CInt) -> CInt) throws {
    assert(options.isSubsetOf([.NoFollow, .ShowCompression]),
        "Extended attribute remover only supports the following XAttrOptions: .NoFollow, .ShowCompression")

    guard delFunc(target, name, options.rawValue) == 0 else {
        throw NSError.POSIX(errno: errno, userInfo: [ExtendedAttributeNameKey: name])
    }
}


// ===========================================================================
// MARK: ExtendedAttributeHandler Conformance
// ===========================================================================

/// Provides `NSURL` with the ability to manipulate extended attributes associated with file system URLs.
extension NSURL: ExtendedAttributeHandler {

    /// Retrieves the extended attribute names associated with this URL.
    ///
    /// - precondition: This method only applies to file system object URLs (`self.fileURL == true`).
    ///
    /// - parameter options: An array of `XAttrOption` values that control how the extended attribute names are
    ///                      retrieved. Defaults to no options.
    ///
    /// - returns: A list of extended attribute names associated with the URL. If no extended attributes
    ///            exist, an empty list is returned.
    ///
    /// - throws: If the system cannot retrieve the extended attribute names, an `NSError` with Foundation built-in
    ///           domain `NSPOSIXErrorDomain` is thrown. Check the _code_ property for the error's POSIX error code,
    ///           and the _localizedDescription_ property for a description of the error. If the attribute names are
    ///           retrieved, but cannot be read due to bad encoding, an `NSError` with Foundation built-in domain
    ///           `NSCocoaErrorDomain` and error code `NSFileReadInapplicableStringEncodingError` is thrown.
    public func extendedAttributeNames(options options: XAttrOptions = []) throws -> [String] {
        assert(self.isFileURL, "Extended attributes are only available for file URLs")
        return try listXAttr(target: self.fileSystemRepresentation, options: options, listFunc: listxattr)
    }

    /// Retrieves the value of the extended attribute specified by _name_.
    ///
    /// - precondition: The extended attribute with _name_ exists. Otherwise, an error will be thrown.
    /// - precondition: This method only applies to file system object URLs (`self.fileURL == true`).
    ///
    /// - parameter forName: The name of one of the URL's extended attributes.
    /// - parameter options: An array of `XAttrOption` values that control how the extended attribute value is
    ///                      retrieved. Defaults to no options.
    ///
    /// - returns: The value retrieved from the extended attribute. If the extended attribute exists, but holds no
    ///            data, an empty data object is returned.
    ///
    /// - throws: `NSError` with Foundation built-in domain `NSPOSIXErrorDomain`. Check the _code_ property for the
    ///           error's POSIX error code, and the _localizedDescription_ property for a description of the error.
    public func extendedAttributeValue(forName name: String, options: XAttrOptions = []) throws -> NSData {
        assert(self.isFileURL, "Extended attributes are only available for file URLs")
        return try getXAttr(target: self.fileSystemRepresentation, name: name, options: options, getFunc: getxattr)
    }

    /// Sets the value for an extended attribute specified by _name_.
    ///
    /// - precondition:  This method only applies to file system object URLs (`self.fileURL == true`).
    /// - postcondition: The extended attribute will be set unless _name_ is a zero-length string or a string
    ///                  containing only NUL characters, in which case no attribute will be set
    ///                  and *no error will be thrown*.
    ///
    /// - parameter name:    The name for the extended attribute to be set.
    /// - parameter value:   The value for the extended attribute to be set.
    /// - parameter options: An array of `XAttrOption` values that control how the extended attribute is
    ///                      set. Defaults to no options.
    ///
    /// - throws: `NSError` with Foundation built-in domain `NSPOSIXErrorDomain`. Check the _code_ property for the
    ///           error's POSIX error code, and the _localizedDescription_ property for a description of the error.
    public func setExtendedAttribute(name name: String, value: NSData, options: XAttrOptions = []) throws {
        assert(self.isFileURL, "Extended attributes are only available for file URLs")
        try setXAttr(target: self.fileSystemRepresentation, name: name, value: value, options: options, setFunc: setxattr)
    }

    /// Removes the extended attribute specified by _name_.
    ///
    /// - precondition: The extended attribute with _name_ exists. Otherwise, an error will be thrown.
    /// - precondition: This method only applies to file system object URLs (`self.fileURL == true`).
    ///
    /// - parameter forName: The name of one of the URL's extended attributes.
    /// - parameter options: An array of `XAttrOption` values that control how the extended attribute is removed.
    ///                      Defaults to no options.
    ///
    /// - throws: `NSError` with Foundation built-in domain `NSPOSIXErrorDomain`. Check the _code_ property for the
    ///           error's POSIX error code, and the _localizedDescription_ property for a description of the error.
    public func removeExtendedAttribute(forName name: String, options: XAttrOptions = []) throws {
        assert(self.isFileURL, "Extended attributes are only available for file URLs")
        try removeXAttr(target: self.fileSystemRepresentation, name: name, options: options, delFunc: removexattr)
    }

}


/// Provides `NSFileHandle` with the ability to manipulate extended attributes associated with file descriptors.
extension NSFileHandle: ExtendedAttributeHandler {

    /// Retrieves the extended attribute names associated with this file.
    ///
    /// - precondition: This method only applies to file system object file descriptors (files, directories, symlinks).
    ///
    /// - parameter options: An array of `XAttrOption` values that control how the extended attribute names are
    ///                      retrieved. Defaults to no options.
    ///
    /// - returns: A list of extended attribute names associated with the file. If no extended attributes
    ///            exist, an empty list is returned.
    ///
    /// - throws: If the system cannot retrieve the extended attribute names, an `NSError` with Foundation built-in
    ///           domain `NSPOSIXErrorDomain` is thrown. Check the _code_ property for the error's POSIX error code,
    ///           and the _localizedDescription_ property for a description of the error. If the attribute names are
    ///           retrieved, but cannot be read due to bad encoding, an `NSError` with Foundation built-in domain
    ///           `NSCocoaErrorDomain` and error code `NSFileReadInapplicableStringEncodingError` is thrown.
    public func extendedAttributeNames(options options: XAttrOptions = []) throws -> [String] {
        //TODO: Update this ugly assertion with better FileHandle code.
        assert({ var statbuf: stat = stat(); guard fstat(self.fileDescriptor, &statbuf) == 0 else { return false }
            return Set([S_IFDIR, S_IFREG, S_IFLNK]).contains(statbuf.st_mode & S_IFMT)
        }(), "Extended attributes are only available for file system objects (files, directories, symlinks)")
        return try listXAttr(target: self.fileDescriptor, options: options, listFunc: flistxattr)
    }

    /// Retrieves the value of the extended attribute specified by _name_.
    ///
    /// - precondition: The extended attribute with _name_ exists. Otherwise, an error will be thrown.
    /// - precondition: This method only applies to file system object file descriptors (files, directories, symlinks).
    ///
    /// - parameter forName: The name of one of the file's extended attributes.
    /// - parameter options: An array of `XAttrOption` values that control how the extended attribute value is
    ///                      retrieved. Defaults to no options.
    ///
    /// - returns: The value retrieved from the extended attribute. If the extended attribute exists, but holds no
    ///            data, an empty data object is returned.
    ///
    /// - throws: `NSError` with Foundation built-in domain `NSPOSIXErrorDomain`. Check the _code_ property for the
    ///           error's POSIX error code, and the _localizedDescription_ property for a description of the error.
    public func extendedAttributeValue(forName name: String, options: XAttrOptions = []) throws -> NSData {
        //TODO: Update this ugly assertion with better FileHandle code.
        assert({ var statbuf: stat = stat(); guard fstat(self.fileDescriptor, &statbuf) == 0 else { return false }
            return Set([S_IFDIR, S_IFREG, S_IFLNK]).contains(statbuf.st_mode & S_IFMT)
        }(), "Extended attributes are only available for file system objects (files, directories, symlinks)")
        return try getXAttr(target: self.fileDescriptor, name: name, options: options, getFunc: fgetxattr)
    }

    /// Sets the value for an extended attribute specified by _name_.
    ///
    /// - precondition:  This method only applies to file system object file descriptors (files, directories, symlinks).
    /// - postcondition: The extended attribute will be set unless _name_ is a zero-length string or a string
    ///                  containing only NUL characters, in which case no attribute will be set
    ///                  and *no error will be thrown*.
    ///
    /// - parameter name:    The name for the extended attribute to be set.
    /// - parameter value:   The value for the extended attribute to be set.
    /// - parameter options: An array of `XAttrOption` values that control how the extended attribute is
    ///                      set. Defaults to no options.
    ///
    /// - throws: `NSError` with Foundation built-in domain `NSPOSIXErrorDomain`. Check the _code_ property for the
    ///           error's POSIX error code, and the _localizedDescription_ property for a description of the error.
    public func setExtendedAttribute(name name: String, value: NSData, options: XAttrOptions = []) throws {
        //TODO: Update this ugly assertion with better FileHandle code.
        assert({ var statbuf: stat = stat(); guard fstat(self.fileDescriptor, &statbuf) == 0 else { return false }
            return Set([S_IFDIR, S_IFREG, S_IFLNK]).contains(statbuf.st_mode & S_IFMT)
        }(), "Extended attributes are only available for file system objects (files, directories, symlinks)")
        try setXAttr(target: self.fileDescriptor, name: name, value: value, options: options, setFunc: fsetxattr)
    }

    /// Removes the extended attribute specified by _name_.
    ///
    /// - precondition: The extended attribute with _name_ exists. Otherwise, an error will be thrown.
    /// - precondition: This method only applies to file system object file descriptors (files, directories, symlinks).
    ///
    /// - parameter forName: The name of one of the file's extended attributes.
    /// - parameter options: An array of `XAttrOption` values that control how the extended attribute is removed.
    ///                      Defaults to no options.
    ///
    /// - throws: `NSError` with Foundation built-in domain `NSPOSIXErrorDomain`. Check the _code_ property for the
    ///           error's POSIX error code, and the _localizedDescription_ property for a description of the error.
    public func removeExtendedAttribute(forName name: String, options: XAttrOptions = []) throws {
        //TODO: Update this ugly assertion with better FileHandle code.
        assert({ var statbuf: stat = stat(); guard fstat(self.fileDescriptor, &statbuf) == 0 else { return false }
            return Set([S_IFDIR, S_IFREG, S_IFLNK]).contains(statbuf.st_mode & S_IFMT)
        }(), "Extended attributes are only available for file system objects (files, directories, symlinks)")
        try removeXAttr(target: self.fileDescriptor, name: name, options: options, delFunc: fremovexattr)
    }

}


// ===========================================================================
// MARK: NSError POSIX Helpers
// ===========================================================================

/// These helpers make it easier to create POSIX errors.
extension NSError {

    /// Makes an `NSError` object with the Foundation built-in error domain `NSPOSIXErrorDomain`.
    ///
    /// If no `NSLocalizedDescriptionKey` is provided in _userInfo_ (or if _userInfo_ is `nil`), the POSIX error
    /// description corresponding to _errno_ will automatically be added to _userInfo_ (creating the dictionary
    /// if necessary) at this key.
    ///
    /// - note: See `NSError.init(domain:code:userInfo:)` for more information about _domain_ and _userInfo_ objects.
    ///
    /// - parameter errno:    Please supply the error code the system placed in the `errno` global variable.
    /// - parameter userInfo: Any additional data to include with the error.
    ///
    /// - returns: An `NSError` object with the domain `NSPOSIXErrorDomain`.
    fileprivate class func POSIX(errno errNo: errno_t, userInfo: [NSObject: AnyObject]? = nil) -> Self {
        return self.init(domain: NSPOSIXErrorDomain, code: Int(errNo), userInfo: {
            if userInfo?[NSLocalizedDescriptionKey] == nil, let description = String(UTF8String: strerror(errNo)) {
                var mutableUserInfo = userInfo ?? [:]
                mutableUserInfo[NSLocalizedDescriptionKey] = description
                return mutableUserInfo
            } else {
                return userInfo
            }
        }())
    }

    /// The system _errno_ as captured when the `NSError` object was created.
    ///
    /// - important: This attribute is only available for errors with the domain `NSPOSIXErrorDomain`.
    fileprivate var errno: errno_t {
        assert(self.domain == NSPOSIXErrorDomain, "errno is only available for POSIX errors")
        return errno_t(self.code)
    }

}
