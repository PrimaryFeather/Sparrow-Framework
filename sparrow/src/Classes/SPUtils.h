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


@interface SPUtils : NSObject 

+ (int)nextPowerOfTwo:(int)number;
+ (int)randomIntBetween:(int)minValue and:(int)maxValue;
+ (float)randomFloat;

@end
