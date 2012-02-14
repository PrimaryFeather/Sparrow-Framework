//
//  SPUtilsTest.m
//  Sparrow
//
//  Created by Daniel Sperl on 04.01.11.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Availability.h>
#ifdef __IPHONE_3_0

#import <SenTestingKit/SenTestingKit.h>

#import "SPUtils.h"
#import "SPNSExtensions.h"

// -------------------------------------------------------------------------------------------------

@interface SPUtilsTest : SenTestCase 

@end

// -------------------------------------------------------------------------------------------------

@implementation SPUtilsTest

- (void)testGetNextPowerOfTwo
{   
    STAssertEquals(1, [SPUtils nextPowerOfTwo:0], @"wrong power of two");
    STAssertEquals(1, [SPUtils nextPowerOfTwo:1], @"wrong power of two");
    STAssertEquals(2, [SPUtils nextPowerOfTwo:2], @"wrong power of two");
    STAssertEquals(4, [SPUtils nextPowerOfTwo:3], @"wrong power of two");
    STAssertEquals(4, [SPUtils nextPowerOfTwo:4], @"wrong power of two");
    STAssertEquals(8, [SPUtils nextPowerOfTwo:5], @"wrong power of two");
    STAssertEquals(8, [SPUtils nextPowerOfTwo:6], @"wrong power of two");
    STAssertEquals(256, [SPUtils nextPowerOfTwo:129], @"wrong power of two");
    STAssertEquals(256, [SPUtils nextPowerOfTwo:255], @"wrong power of two");
    STAssertEquals(256, [SPUtils nextPowerOfTwo:256], @"wrong power of two");    
}

- (void)testGetRandomFloat
{
    for (int i=0; i<20; ++i)
    {
        float rnd = [SPUtils randomFloat];
        STAssertTrue(rnd >= 0.0f, @"random number too small");
        STAssertTrue(rnd < 1.0f,  @"random number too big");        
    }    
}

- (void)testGetRandomInt
{
    for (int i=0; i<20; ++i)
    {
        int rnd = [SPUtils randomIntBetweenMin:5 andMax:10];
        STAssertTrue(rnd >= 5, @"random number too small");
        STAssertTrue(rnd < 10, @"random number too big");        
    }    
}

- (void)testFileExistsAtPath
{
    NSString *absolutePath = [[NSBundle appBundle] pathForResource:@"pvrtc_image.pvr"];
    
    BOOL fileExists = [SPUtils fileExistsAtPath:absolutePath];
    STAssertTrue(fileExists, @"resource file not found");
    
    fileExists = [SPUtils fileExistsAtPath:@"/tmp/some_non_existing_file.foo"];
    STAssertFalse(fileExists, @"found non-existing file");
    
    NSString *folder = [absolutePath stringByDeletingLastPathComponent];
    BOOL folderExists = [SPUtils fileExistsAtPath:folder];
    STAssertTrue(folderExists, @"folder not found");
}

- (void)testAbsolutePathToFile
{
    NSString *absolutePath1x = [SPUtils absolutePathToFile:@"pvrtc_image.pvr"];
    NSString *absolutePath2x = [SPUtils absolutePathToFile:@"pvrtc_image.pvr" withScaleFactor:2.0f];
    
    STAssertNotNil(absolutePath1x, @"resource not found (1x)");
    STAssertNotNil(absolutePath2x, @"resource not found (2x)");
    
    uint suffixLoc = [absolutePath2x rangeOfString:@"@2x.pvr"].location;
    STAssertEquals(suffixLoc, absolutePath2x.length - 7, @"did not find correct resource (2x)");
    
    NSString *nonexistingPath = [SPUtils absolutePathToFile:@"does_not_exist.foo"];
    STAssertNil(nonexistingPath, @"found non-existing file");
    
    nonexistingPath = [SPUtils absolutePathToFile:@"does_not_exist@2x.foo"];
    STAssertNil(nonexistingPath, @"found non-existing file");
    
    NSString *nilPath = [SPUtils absolutePathToFile:nil];
    STAssertNil(nilPath, @"found nil-path");
    
    nilPath = [SPUtils absolutePathToFile:nil withScaleFactor:2.0f];
    STAssertNil(nilPath, @"found nil-path (2x)");
}

- (void)testIdiom
{
    NSString *filename = @"image_idiom.png";
    
    NSString *absolutePath = [SPUtils absolutePathToFile:filename withScaleFactor:1.0f 
                                                   idiom:UIUserInterfaceIdiomPhone];
    STAssertTrue([absolutePath hasSuffix:@"image_idiom~iphone.png"], @"idiom image not found");
}

- (void)testScaledIdiom
{
    NSString *filename = @"image_idiom.png";
    
    NSString *absolutePath = [SPUtils absolutePathToFile:filename withScaleFactor:2.0f 
                                                   idiom:UIUserInterfaceIdiomPhone];
    STAssertTrue([absolutePath hasSuffix:@"image_idiom@2x~iphone.png"], @"idiom image not found");
}

- (void)testGetSdTextureFallback
{
    NSString *filename = @"image_only_sd.png";
    
    NSString *absolutePath = [SPUtils absolutePathToFile:filename withScaleFactor:2.0f];
    STAssertTrue([absolutePath hasSuffix:filename], @"1x fallback resource not found");
}

- (void)testOnlyHdTextureAvailable
{
    NSString *filename = @"image_only_hd.png";
    NSString *fullFilename = [filename stringByAppendingSuffixToFilename:@"@2x"];
    
    NSString *absolutePath = [SPUtils absolutePathToFile:filename withScaleFactor:2.0f];
    STAssertTrue([absolutePath hasSuffix:fullFilename], @"2x resource not found");
}

@end

#endif