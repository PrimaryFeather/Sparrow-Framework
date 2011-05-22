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

static int dummyDeallocCount = 0;

@interface DummyClass : NSObject

@end

@implementation DummyClass

- (void)dealloc
{
    ++dummyDeallocCount;
    [super dealloc];
}

@end

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
    dummyDeallocCount = 0;
}

- (void)simpleMethod
{
    ++mCallCount;
}

- (void)methodWithArgument:(DummyClass *)dummy
{
    [dummy description]; // just to check that dummy has not been released
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
    
    [delayedInv release];
}

- (void)testDelayWithArguments
{
    SP_CREATE_POOL(pool);
    
    // test dummy mechanism
    
    DummyClass *dummy = [[DummyClass alloc] init];
    [dummy release];
    STAssertEquals(1, dummyDeallocCount, @"dummy release not counted");
    
    // now test if retain/release cycle of delayed invocation works
    
    dummy = [[DummyClass alloc] init];
    id delayedInv = [[SPDelayedInvocation alloc] initWithTarget:self delay:1.0f];
    [delayedInv methodWithArgument:dummy];
    
    STAssertEquals(0, mCallCount, @"Delayed Invocation triggered too soon");
    
    [dummy release];
    STAssertEquals(1, dummyDeallocCount, @"Argument not retained");
    
    [delayedInv advanceTime:1.0f];
    STAssertEquals(1, mCallCount, @"Delayed Invocation did not trigger");
    
    SP_RELEASE_POOL(pool);
    
    [delayedInv release];
    STAssertEquals(2, dummyDeallocCount, @"Argument not released");
}

@end

#endif