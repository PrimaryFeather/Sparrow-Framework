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

#import <sys/stat.h>

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
                           idiom:(UIUserInterfaceIdiom)idiom
{
    // iOS image resource naming conventions:
    // SD: <ImageName><device_modifier>.<filename_extension>
    // HD: <ImageName>@2x<device_modifier>.<filename_extension>
    
    NSString *originalPath = path;
 
    if (factor != 1.0f)
    {
        NSString *scaleSuffix = [NSString stringWithFormat:@"@%@x", [NSNumber numberWithFloat:factor]];
        path = [path stringByReplacingOccurrencesOfString:scaleSuffix withString:@""];
        path = [path stringByAppendingSuffixToFilename:scaleSuffix];
    }

    NSString *idiomSuffix = (idiom == UIUserInterfaceIdiomPad) ? @"~ipad" : @"~iphone";
    NSString *pathWithIdiom = [path stringByAppendingSuffixToFilename:idiomSuffix];
    
    BOOL isAbsolute = [path isAbsolutePath];
    NSBundle *appBundle = [NSBundle appBundle];
    NSString *absolutePath = isAbsolute ? path : [appBundle pathForResource:path];
    NSString *absolutePathWithIdiom = isAbsolute ? pathWithIdiom : [appBundle pathForResource:pathWithIdiom];
    
    if ([SPUtils fileExistsAtPath:absolutePathWithIdiom])
        return absolutePathWithIdiom;
    else if ([SPUtils fileExistsAtPath:absolutePath])
        return absolutePath;
    else if (factor != 1.0f)
        return [SPUtils absolutePathToFile:originalPath withScaleFactor:1.0f idiom:idiom];
    else
        return nil;
}

+ (NSString *)absolutePathToFile:(NSString *)path withScaleFactor:(float)factor
{
    return [SPUtils absolutePathToFile:path withScaleFactor:factor idiom:UI_USER_INTERFACE_IDIOM()];
}

+ (NSString *)absolutePathToFile:(NSString *)path
{
    return [SPUtils absolutePathToFile:path withScaleFactor:1.0f];
}

@end
