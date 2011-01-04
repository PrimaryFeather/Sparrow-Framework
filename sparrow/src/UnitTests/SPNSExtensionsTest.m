//
//  SPNSExtensionsTests.m
//  Sparrow
//
//  Created by Daniel Sperl on 10.07.10.
//  Copyright 2010 Incognitek. All rights reserved.
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
}

@end

#endif