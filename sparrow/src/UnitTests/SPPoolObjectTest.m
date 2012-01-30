//
//  SPPoolObjectTest.m
//  Sparrow
//
//  Created by Daniel Sperl on 15.01.11.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Availability.h>
#ifdef __IPHONE_3_0

#import <SenTestingKit/SenTestingKit.h>

#import "SPPoint.h"

// -------------------------------------------------------------------------------------------------

@interface SPPoolObjectTest : SenTestCase 

@end

// -------------------------------------------------------------------------------------------------

@implementation SPPoolObjectTest

- (void)testObjectPooling
{
    [SPPoint purgePool]; // clean existing pool
    
    SPPoint *p1 = [[SPPoint alloc] initWithX:1.0f y:2.0f];
    SPPoint *p2 = [[SPPoint alloc] initWithX:3.0f y:4.0f];
    SPPoint *p3 = [[SPPoint alloc] initWithX:5.0f y:6.0f];
    
    [p3 release];
#ifndef DISABLE_MEMORY_POOLING
    // object should still exist after release
    STAssertEquals(5.0f, p3.x, @"object no longer accessible or wrong contents");
    STAssertEquals(6.0f, p3.y, @"object no longer accessible or wrong contents");
#endif

    SPPoint *p4 = [[SPPoint alloc] initWithX:15.0f y:16.0f];
#ifndef DISABLE_MEMORY_POOLING
    // p4 should be the recycled p3
    STAssertEquals((int)p3, (int)p4, @"object not taken from pool");
    STAssertEquals(15.0f, p3.x, @"object not taken from pool");
    STAssertEquals(16.0f, p3.y, @"object not taken from pool");
#endif

    [p4 release];
    [p2 release];
    [p1 release];
    
    SPPoint *p5 = [[SPPoint alloc] initWithX:11.0f y:22.0f];
#ifndef DISABLE_MEMORY_POOLING
    STAssertEquals((int)p5, (int)p1, @"object not taken from pool");
#endif
    
    int numPurgedPoints = [SPPoint purgePool];
#ifndef DISABLE_MEMORY_POOLING
    STAssertEquals(2, numPurgedPoints, @"wrong number of objects released on purge"); 
#endif
    
    [p5 release];
    numPurgedPoints = [SPPoint purgePool];
#ifndef DISABLE_MEMORY_POOLING
    STAssertEquals(1, numPurgedPoints, @"wrong number of objects released on purge"); 
#endif
}

@end

#endif