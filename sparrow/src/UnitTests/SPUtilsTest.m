//
//  SPUtilsTest.m
//  Sparrow
//
//  Created by Daniel Sperl on 04.01.11.
//  Copyright 2011 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Availability.h>
#ifdef __IPHONE_3_0

#import <SenTestingKit/SenTestingKit.h>

#import "SPUtils.h"

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
        int rnd = [SPUtils randomIntBetween:5 and:10];
        STAssertTrue(rnd >= 5, @"random number too small");
        STAssertTrue(rnd < 10, @"random number too big");        
    }    
}

@end

#endif