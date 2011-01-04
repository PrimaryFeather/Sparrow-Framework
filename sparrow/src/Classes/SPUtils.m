//
//  SPUtils.m
//  Sparrow
//
//  Created by Daniel Sperl on 04.01.11.
//  Copyright 2011 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPUtils.h"


@implementation SPUtils

+ (int)nextPowerOfTwo:(int)number
{    
    int result = 1; 
    while (result < number) result *= 2;
    return result;    
}

+ (int)randomIntBetween:(int)minValue and:(int)maxValue
{
    return (int)(minValue + [self randomFloat] * (maxValue - minValue));
}

+ (float)randomFloat
{
    return (float) arc4random() / UINT_MAX;
}

@end
