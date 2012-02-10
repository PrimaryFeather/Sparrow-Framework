//
//  SPUtils.m
//  Sparrow
//
//  Created by Daniel Sperl on 04.01.11.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPUtils.h"
#import "SPNSExtensions.h"

#include <sys/stat.h>

@implementation SPUtils

+ (int)nextPowerOfTwo:(int)number
{    
    int result = 1; 
    while (result < number) result *= 2;
    return result;    
}

+ (int)randomIntBetweenMin:(int)minValue andMax:(int)maxValue
{
    return (int)(minValue + [self randomFloat] * (maxValue - minValue));
}

+ (float)randomFloat
{
    return (float) arc4random() / UINT_MAX;
}

+ (BOOL)fileExistsAtPath:(NSString *)path
{
    struct stat buffer;   
    return stat([path UTF8String], &buffer) == 0;
}

+ (NSString *)absolutePathToFile:(NSString *)path withScaleFactor:(float)factor
{
    NSString *originalPath = path;
    
    if (factor != 1.0f)
    {
        NSString *suffix = [NSString stringWithFormat:@"@%@x", [NSNumber numberWithFloat:factor]];
        path = [path stringByReplacingOccurrencesOfString:suffix withString:@""];
        path = [path stringByAppendingSuffixToFilename:suffix];
    }
    
    NSString *absolutePath = [path isAbsolutePath] ? path : [[NSBundle appBundle] pathForResource:path];
    
    if ([SPUtils fileExistsAtPath:absolutePath])
        return absolutePath;
    else if (factor != 1.0f)
        return [SPUtils absolutePathToFile:originalPath];
    else
        return nil;
}

+ (NSString *)absolutePathToFile:(NSString *)path
{
    return [SPUtils absolutePathToFile:path withScaleFactor:1.0f];
}

@end
