//
//  SPNSExtensionsTests.m
//  Sparrow
//
//  Created by Daniel Sperl on 10.07.10.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Availability.h>
#ifdef __IPHONE_3_0

#import <SenTestingKit/SenTestingKit.h>

#import "SPNSExtensions.h"

// -------------------------------------------------------------------------------------------------

@interface SPNSExtensionsTest : SenTestCase 

@end

// -------------------------------------------------------------------------------------------------

@implementation SPNSExtensionsTest

- (void)testStringByAppendingSuffixToFilename
{    
    NSString *filename = @"path/file.ext";
    NSString *expandedFilename = [filename stringByAppendingSuffixToFilename:@"@2x"];
    STAssertEqualObjects(@"path/file@2x.ext", expandedFilename, @"Appending suffix did not work!");    
    
    filename = @"path/file.ext.gz";
    expandedFilename = [filename stringByAppendingSuffixToFilename:@"@2x"];
    STAssertEqualObjects(@"path/file@2x.ext.gz", expandedFilename, @"Appending suffix did not work!");    
}

- (void)testFullPathExtension
{
    NSString *filename = @"test.png";
    NSString *extension = [filename fullPathExtension];
    STAssertEqualObjects(@"png", extension, @"wrong path extension on standard filename");
    
    filename = @"test.pvr.gz";
    extension = [filename fullPathExtension];
    STAssertEqualObjects(@"pvr.gz", extension, @"wrong path extension on double extension");
    
    filename = @"/tmp/scratch.tiff";
    extension = [filename fullPathExtension];
    STAssertEqualObjects(@"tiff", extension, @"wrong path extension on path with folders");

    filename = @"/tmp/scratch";
    extension = [filename fullPathExtension];
    STAssertEqualObjects(@"", extension, @"wrong path extension on path without extension");
    
    filename = @"/tmp/";
    extension = [filename fullPathExtension];
    STAssertEqualObjects(@"", extension, @"wrong path extension on path that contains a folder");
    
    filename = @".tmp";
    extension = [filename fullPathExtension];
    STAssertEqualObjects(@"", extension, @"wrong path extension on hidden file");
}

- (void)testStringByDeletingFullPathExtension
{
    NSString *filename = @"/tmp/scratch.tiff";
    NSString *basename = [filename stringByDeletingFullPathExtension];
    STAssertEqualObjects(@"/tmp/scratch", basename, @"wrong base name on standard path");

    filename = @"/tmp/test.pvr.gz";
    basename = [filename stringByDeletingFullPathExtension];
    STAssertEqualObjects(@"/tmp/test", basename, @"wrong base name on double extension");
    
    filename = @"/tmp/";
    basename = [filename stringByDeletingFullPathExtension];
    STAssertEqualObjects(@"/tmp", basename, @"wrong base name on path that contains a folder");
    
    filename = @"scratch.bundle/";
    basename = [filename stringByDeletingFullPathExtension];
    STAssertEqualObjects(@"scratch", basename, @"wrong base name on standard path with terminating slash");

    filename = @".tiff";
    basename = [filename stringByDeletingFullPathExtension];
    STAssertEqualObjects(@".tiff", basename, @"wrong base name on hidden file");

    filename = @"/";
    basename = [filename stringByDeletingFullPathExtension];
    STAssertEqualObjects(@"/", basename, @"wrong base name on standard path");
}

- (void)testAppBundle
{
    NSString *absolutePath = [[NSBundle appBundle] pathForResource:@"pvrtc_image.pvr"];
    STAssertNotNil(absolutePath, @"path to resource not found");
}

- (void)testContentScaleFactor
{
    NSString *filename = @"/some/folders/filename@2x.png";
    STAssertEquals(2.0f, [filename contentScaleFactor], @"wrong scale factor");
    
    filename = @"/some/folders/filename.png";
    STAssertEquals(1.0f, [filename contentScaleFactor], @"wrong scale factor");
    
    filename = @"/some/folders/filename@4x~ipad.png";
    STAssertEquals(4.0f, [filename contentScaleFactor], @"wrong scale factor");
    
    filename = @"/some/folders/filename@20x~whatever.png";
    STAssertEquals(20.0f, [filename contentScaleFactor], @"wrong scale factor");

    filename = @"/some/folders/filename@4x_and_more.png";
    STAssertEquals(1.0f, [filename contentScaleFactor], @"wrong scale factor");
    
    filename = @"not a filename";
    STAssertEquals(1.0f, [filename contentScaleFactor], @"wrong scale factor");
}

@end

#endif