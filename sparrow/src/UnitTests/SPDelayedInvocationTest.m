//
//  SPDelayedInvocationTest.m
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
#import "SPDelayedInvocation.h"
#import "SPMacros.h"

// -------------------------------------------------------------------------------------------------

@interface SPDelayedInvocationTest : SenTestCase 
{
    int mCallCount;
}

@end

// -------------------------------------------------------------------------------------------------

@implementation SPDelayedInvocationTest

- (void)setUp
{
    mCallCount = 0;
}

- (void)simpleMethod
{
    ++mCallCount;
}

- (void)testSimpleDelay
{    
    id delayedInv = [[SPDelayedInvocation alloc] initWithTarget:self delay:1.0f];
    [delayedInv simpleMethod];
    
    STAssertEquals(0, mCallCount, @"Delayed Invocation triggered too soon");
    [delayedInv advanceTime:0.5f];
    
    STAssertEquals(0, mCallCount, @"Delayed Invocation triggered too soon");
    [delayedInv advanceTime:0.49f];
    
    STAssertEquals(0, mCallCount, @"Delayed Invocation triggered too soon");
    
    [delayedInv advanceTime:0.1f];
    STAssertEquals(1, mCallCount, @"Delayed Invocation did not trigger");
    
    [delayedInv advanceTime:0.1f];
    STAssertEquals(1, mCallCount, @"Delayed Invocation triggered too often");
    
}

@end

#endif