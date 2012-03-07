//
//  SPUtils.h
//  Sparrow
//
//  Created by Daniel Sperl on 04.01.11.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIDevice.h>

/// The SPUtils class contains utility methods for different purposes.

@interface SPUtils : NSObject 

/// Finds the next power of two equal to or above the specified number.
+ (int)nextPowerOfTwo:(int)number;

/// Returns a random integer number between `minValue` (inclusive) and `maxValue` (exclusive).
+ (int)randomIntBetweenMin:(int)minValue andMax:(int)maxValue;

/// Returns a random float number between 0.0 and 1.0
+ (float)randomFloat;

/// Returns a Boolean value that indicates whether a file or directory exists at a specified path.
+ (BOOL)fileExistsAtPath:(NSString *)path;

/// Finds the full path for a file with a certain scale factor (a file with a suffix like '@2x')
/// and user interface idiom ('~ipad' or '~iphone'). Relative paths are searched in the application
/// bundle.
/// 
/// @return The path to the scaled resource with idiom suffix; if that does not exist, the path
/// to the scaled resource without idiom suffix; if that does not exist either, the path
/// to the unscaled resource (first with, then without idiom). If none of those exist, nil.
+ (NSString *)absolutePathToFile:(NSString *)path withScaleFactor:(float)factor 
                           idiom:(UIUserInterfaceIdiom)idiom;

/// Finds the full path for a file with a certain scale factor (a file with a suffix like '@2x'),
/// adhering the current user interface idiom. Relative paths are searched in the application bundle.
+ (NSString *)absolutePathToFile:(NSString *)path withScaleFactor:(float)factor;

/// Returns the absolute path to a file, or nil if it does not exist.
+ (NSString *)absolutePathToFile:(NSString *)path;

@end
