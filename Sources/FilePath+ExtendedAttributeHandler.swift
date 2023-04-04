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

import Foundation
import System


/// Extends `FilePath` with the ability to manipulate extended attributes associated with files.
extension FilePath: ExtendedAttributeHandler {

    /// Retrieves the extended attribute names associated with this file path.
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
    public func extendedAttributeNames(options: XAttrOptions = []) throws -> [String] {
        if #available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *) {
            assert(!self.isEmpty, "File path must not be empty")
            return try self.withPlatformString { path in
                return try listXAttr(target: path, options: options, listFunc: listxattr)
            }
        } else {
            return try self.withCString { path in
                return try listXAttr(target: path, options: options, listFunc: listxattr)
            }
        }
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
    public func extendedAttributeValue(forName name: String, options: XAttrOptions = []) throws -> Data {
        if #available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *) {
            assert(!self.isEmpty, "File path must not be empty")
            return try self.withPlatformString { path in
                return try getXAttr(target: path, name: name, options: options, getFunc: getxattr)
            }
        } else {
            return try self.withCString { path in
                return try getXAttr(target: path, name: name, options: options, getFunc: getxattr)
            }
        }
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
    public func setExtendedAttribute(name: String, value: Data, options: XAttrOptions = []) throws {
        if #available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *) {
            assert(!self.isEmpty, "File path must not be empty")
            return try self.withPlatformString { path in
                try setXAttr(target: path, name: name, value: value, options: options, setFunc: setxattr)
            }
        } else {
            return try self.withCString { path in
                try setXAttr(target: path, name: name, value: value, options: options, setFunc: setxattr)
            }
        }
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
        if #available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *) {
            assert(!self.isEmpty, "File path must not be empty")
            return try self.withPlatformString { path in
                try removeXAttr(target: path, name: name, options: options, delFunc: removexattr)
            }
        } else {
            return try self.withCString { path in
                try removeXAttr(target: path, name: name, options: options, delFunc: removexattr)
            }
        }
    }

}
