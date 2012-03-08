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

/// Expects the string to be a filename/path and returns the scale factor ('@<factor>x').
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
