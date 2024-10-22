// SPDX-License-Identifier: ISC
// ISC License
//
// Copyright (c) 2016, Justin Pawela and contributors
// Copyright © 2023 Cisco Systems, Inc.
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

/// Provides `FileHandle` with the ability to manipulate extended attributes associated with file descriptors.
extension FileHandle: ExtendedAttributeHandler {

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
    public func extendedAttributeNames(options: XAttrOptions = []) throws -> [String] {
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
    public func extendedAttributeValue(forName name: String, options: XAttrOptions = []) throws -> Data {
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
    public func setExtendedAttribute(name: String, value: Data, options: XAttrOptions = []) throws {
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
