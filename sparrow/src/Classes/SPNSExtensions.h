//
//  SPNSAdditions.h
//  Sparrow
//
//  Created by Daniel Sperl on 13.05.09.
//  Copyright 2009 Incognitek. All rights reserved.
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

/// Creates a string by appending a suffix to a filename in front of its extension.
- (NSString *)stringByAppendingSuffixToFilename:(NSString *)suffix;

@end

/** Sparrow extensions for the NSBundle class. */
@interface NSBundle (SPNSExtensions)

/// Finds the path for a resource. 'name' may include directories and the file extension.
- (NSString *)pathForResource:(NSString *)name;

/// Finds the path for a resource with a certain scale factor (a file with a prefix like '@2x').
/// 
/// @return Returns the path to the scaled resource if it exists; otherwise, the path to the
///         unscaled resource - or nil if that does not exist, either.
- (NSString *)pathForResource:(NSString *)name withScaleFactor:(float)factor;

@end