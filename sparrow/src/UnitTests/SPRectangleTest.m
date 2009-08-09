//
//  SPRectangleTest.m
//  Sparrow
//
//  Created by Daniel Sperl on 25.04.09.
//  Copyright 2009 Incognitek. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <UIKit/UIKit.h>

#import "SPMakros.h"
#import "SPPoint.h"
#import "SPRectangle.h"

// -------------------------------------------------------------------------------------------------

@interface SPRectangleTest : SenTestCase 

@end

// -------------------------------------------------------------------------------------------------

@implementation SPRectangleTest

- (void) setUp
{
}

- (void) tearDown
{
}

#pragma mark -

- (void)testInit
{
    SPRectangle *rect = [[SPRectangle alloc] initWithX:10 y:20 width:30 height:40];
    STAssertTrue(SP_IS_FLOAT_EQUAL(10, rect.x), @"wrong x");
    STAssertTrue(SP_IS_FLOAT_EQUAL(20, rect.y), @"wrong y");
    STAssertTrue(SP_IS_FLOAT_EQUAL(30, rect.width), @"wrong width");
    STAssertTrue(SP_IS_FLOAT_EQUAL(40, rect.height), @"wrong height");    
    [rect release];
}

- (void)testContainsPoint
{
    SPRectangle *rect = [SPRectangle rectangleWithX:10 y:20 width:30 height:40];
    STAssertFalse([rect containsPoint:[SPPoint pointWithX:0 y:0]], @"point inside");
    STAssertTrue([rect containsPoint:[SPPoint pointWithX:15 y:25]], @"point not inside");
    STAssertTrue([rect containsPoint:[SPPoint pointWithX:10 y:20]], @"point not inside");
    STAssertTrue([rect containsPoint:[SPPoint pointWithX:40 y:60]], @"point not inside");
}

@end