//
//  SPNSExtensions.h
//  Sparrow
//
//  Created by Daniel Sperl on 13.05.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>

/** Sparrow extensions for the NSInvocation class. */
@interface NSInvocation (SPNSExtensions)

/// Creates an invocation with a specified target and selector.
+ (NSInvocation *)invocationWithTarget:(id)target selector:(SEL)selector;

@end


/** Sparrow extensions for the NSString class. */
@interface NSString (SPNSExtensions)

/// Interprets the receiver as a path and returns its extension, if any (not including the extension
/// divider). Supports multiple extensions, like 'file.tar.gz'.
- (NSString *)fullPathExtension;

/// Returns a new string made by deleting the full extension (if any) from the receiver.
- (NSString *)stringByDeletingFullPathExtension;

/// Creates a string by appending a suffix to a filename in front of its extension.
- (NSString *)stringByAppendingSuffixToFilename:(NSString *)suffix;

/// Creates a string by appending a scale suffix (e.g. `@2x`) to a filename in front of its extension.
- (NSString *)stringByAppendingScaleSuffixToFilename:(float)scale;

/// Expects the string to be a filename/path and returns the scale factor ('@2x' -> 2).
- (float)contentScaleFactor;

@end


/** Sparrow extensions for the NSBundle class. */
@interface NSBundle (SPNSExtensions)

/// Finds the path for a resource. 'name' may include directories and the file extension.
- (NSString *)pathForResource:(NSString *)name;

/// Finds the path for a resource with a certain scale factor (a file with a suffix like '@2x').
/// 
/// @return Returns the path to the scaled resource if it exists; otherwise, the path to the
/// unscaled resource - or nil if that does not exist, either.
- (NSString *)pathForResource:(NSString *)name withScaleFactor:(float)factor;

/// Returns the NSBundle object of the current application. Different to `[NSBundle mainBundle]`,
/// this works in unit tests, as well.
+ (NSBundle *)appBundle;

@end


/** ------------------------------------------------------------------------------------------------
 
 Additions to the NSData class supporting Base64 and GZip en- and decoding. These methods are based
 on work of other authors; links to the origins are provided.
 
 ------------------------------------------------------------------------------------------------- */

/** Sparrow extensions for the NSData class. */
@interface NSData (SXNSDataExtensions)

// -------------------------------------------------------------------------------------------------
// Base64 code copyright 2008 Kaliware, LLC. All rights reserved.
// Found here: http://idevkit.com/forums/tutorials-code-samples-sdk/8-nsdata-base64-extension.html
// -------------------------------------------------------------------------------------------------

/// Creates an NSData object by parsing a Base64 encoded String.
+ (NSData *)dataWithBase64EncodedString:(NSString *)string;

/// Creates an NSData object by parsing a Base64 encoded String.
- (id)initWithBase64EncodedString:(NSString *)string;

/// Returns the Base64 representation of the NSData object.
- (NSString *)base64Encoding;

/// Returns the Base64 representation of the NSData object, separated into lines.
- (NSString *)base64EncodingWithLineLength:(uint)lineLength;

// -------------------------------------------------------------------------------------------------
// Gzip code copyright 2007 theidiotproject. All rights reserved.
// Found here: http://code.google.com/p/drop-osx/source/browse/trunk/Source/NSData%2Bgzip.h
// Also Check: http://deusty.blogspot.com/2007/07/gzip-compressiondecompression.html
// -------------------------------------------------------------------------------------------------

/// If the file has the extension '.gz', returns the uncompressed contents of the GZip-compressed
/// file; otherwise, returns the unprocessed contents.
+ (NSData *)dataWithUncompressedContentsOfFile:(NSString *)file;

/// Uncompresses the GZip-compressed contents of this NSData object into a new NSData instance.
- (NSData *)gzipDeflate;

/// Gzip-compresses the contents of this NSData object into a new NSData instance.
- (NSData *)gzipInflate;

@end

