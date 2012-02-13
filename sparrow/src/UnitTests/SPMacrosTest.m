//
//  SPMacrosTest.m
//  Sparrow
//
//  Created by Daniel Sperl on 13.02.12.
//  Copyright 2012 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Availability.h>
#ifdef __IPHONE_3_0

#import <SenTestingKit/SenTestingKit.h>
#import "SPMacros.h"

// -------------------------------------------------------------------------------------------------

@interface SPMacrosTest : SenTestCase 

@end

// -------------------------------------------------------------------------------------------------

@implementation SPMacrosTest

- (void)testClamp
{
    STAssertEquals( 4, SP_CLAMP(1, 4, 6), @"wrong clamp result");
    STAssertEquals(-3, SP_CLAMP(-3, -10, -1), @"wrong clamp result");
    STAssertEquals( 5, SP_CLAMP(10, 0, 5), @"wrong clamp result");
}

@end

#endif