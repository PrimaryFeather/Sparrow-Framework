//
//  SPUtils.h
//  Sparrow
//
//  Created by Daniel Sperl on 04.01.11.
//  Copyright 2011 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>

/// The SPUtils class contains utility methods for different purposes.

@interface SPUtils : NSObject 

/// Finds the next power of two equal to or above the specified number.
+ (int)nextPowerOfTwo:(int)number;

/// Returns a random integer number between `minValue` (inclusive) and `maxValue` (exclusive).
+ (int)randomIntBetween:(int)minValue and:(int)maxValue;

/// Returns a random float number between 0.0 and 1.0
+ (float)randomFloat;

@end
