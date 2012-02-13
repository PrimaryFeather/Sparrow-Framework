//
//  SPRectangleTest.m
//  Sparrow
//
//  Created by Daniel Sperl on 25.04.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Availability.h>
#ifdef __IPHONE_3_0

#import <SenTestingKit/SenTestingKit.h>
#import <UIKit/UIKit.h>

#import "SPMacros.h"
#import "SPPoint.h"
#import "SPRectangle.h"

#define E 0.0001f

// -------------------------------------------------------------------------------------------------

@interface SPRectangleTest : SenTestCase 

@end

// -------------------------------------------------------------------------------------------------

@implementation SPRectangleTest

- (void)testInit
{
    SPRectangle *rect = [[SPRectangle alloc] initWithX:10 y:20 width:30 height:40];
    STAssertTrue(SP_IS_FLOAT_EQUAL(10, rect.x), @"wrong x");
    STAssertTrue(SP_IS_FLOAT_EQUAL(20, rect.y), @"wrong y");
    STAssertTrue(SP_IS_FLOAT_EQUAL(30, rect.width), @"wrong width");
    STAssertTrue(SP_IS_FLOAT_EQUAL(40, rect.height), @"wrong height");    
    [rect release];
}

- (void)testSides
{
    SPRectangle *rect = [SPRectangle rectangleWithX:5 y:10 width:5 height:2];
    STAssertEqualsWithAccuracy(rect.x, rect.left, E, @"wrong left property");
    STAssertEqualsWithAccuracy(rect.y, rect.top, E, @"wrong top property");
    STAssertEqualsWithAccuracy(rect.x + rect.width, rect.right, E, @"wrong right property");
    STAssertEqualsWithAccuracy(rect.y + rect.height, rect.bottom, E, @"wrong bottom property");
}

- (void)testChangeSides
{
    SPRectangle *rect = [SPRectangle rectangleWithX:5 y:10 width:5 height:2];
    
    rect.right = 11.0f;
    STAssertEqualsWithAccuracy(11.0f, rect.right, E, @"wrong right property");
    STAssertEqualsWithAccuracy( 6.0f, rect.width, E, @"wrong width");
    
    rect.bottom = 11.0f;
    STAssertEqualsWithAccuracy(11.0f, rect.bottom, E, @"wrong bottom property");
    STAssertEqualsWithAccuracy( 1.0f, rect.height, E, @"wrong height");
}

- (void)testBorderPoints
{
    SPRectangle *rect = [SPRectangle rectangleWithX:5 y:10 width:5 height:2];
    
    SPPoint *topLeft = rect.topLeft;
    STAssertEqualsWithAccuracy(rect.x, topLeft.x, E, @"wrong topLeft.x property");
    STAssertEqualsWithAccuracy(rect.y, topLeft.y, E, @"wrong topLeft.y property");
    
    SPPoint *bottomRight = rect.bottomRight;
    STAssertEqualsWithAccuracy(rect.right, bottomRight.x,  E, @"wrong bottomRight.x property");
    STAssertEqualsWithAccuracy(rect.bottom, bottomRight.y, E, @"wrong bottomRight.y property");

    SPPoint *size = rect.size;
    STAssertEqualsWithAccuracy(rect.width, size.x,  E, @"wrong size.x property");
    STAssertEqualsWithAccuracy(rect.height, size.y, E, @"wrong size.y property");
}

- (void)testContainsPoint
{
    SPRectangle *rect = [SPRectangle rectangleWithX:10 y:20 width:30 height:40];
    STAssertFalse([rect containsPoint:[SPPoint pointWithX:0 y:0]], @"point inside");
    STAssertTrue([rect containsPoint:[SPPoint pointWithX:15 y:25]], @"point not inside");
    STAssertTrue([rect containsPoint:[SPPoint pointWithX:10 y:20]], @"point not inside");
    STAssertTrue([rect containsPoint:[SPPoint pointWithX:40 y:60]], @"point not inside");
}

- (void)testContainsRect
{
    SPRectangle *rect = [SPRectangle rectangleWithX:-5 y:-10 width:10 height:20];
    
    SPRectangle *overlapRect = [SPRectangle rectangleWithX:-10 y:-15 width:10 height:10];
    SPRectangle *identRect = [SPRectangle rectangleWithX:-5 y:-10 width:10 height:20];
    SPRectangle *outsideRect = [SPRectangle rectangleWithX:10 y:10 width:10 height:10];
    SPRectangle *touchingRect = [SPRectangle rectangleWithX:5 y:0 width:10 height:10];
    SPRectangle *insideRect = [SPRectangle rectangleWithX:0 y:0 width:1 height:2];
    
    STAssertFalse([rect containsRectangle:overlapRect], @"overlapping, not inside");
    STAssertTrue([rect containsRectangle:identRect], @"identical, should be inside");
    STAssertFalse([rect containsRectangle:outsideRect], @"should be outside");
    STAssertFalse([rect containsRectangle:touchingRect], @"touching, should be outside");
    STAssertTrue([rect containsRectangle:insideRect], @"should be inside");    
}

- (void)testIntersectionWithRectangle
{
    SPRectangle *rect = [SPRectangle rectangleWithX:-5 y:-10 width:10 height:20];

    SPRectangle *overlapRect = [SPRectangle rectangleWithX:-10 y:-15 width:10 height:10];
    SPRectangle *identRect = [SPRectangle rectangleWithX:-5 y:-10 width:10 height:20];
    SPRectangle *outsideRect = [SPRectangle rectangleWithX:10 y:10 width:10 height:10];
    SPRectangle *touchingRect = [SPRectangle rectangleWithX:5 y:0 width:10 height:10];
    SPRectangle *insideRect = [SPRectangle rectangleWithX:0 y:0 width:1 height:2];
    
    STAssertEqualObjects([SPRectangle rectangleWithX:-5 y:-10 width:5 height:5],
                         [rect intersectionWithRectangle:overlapRect], @"wrong intersection shape");
    STAssertEqualObjects(rect, [rect intersectionWithRectangle:identRect], @"wrong intersection shape");
    STAssertEqualObjects([SPRectangle rectangleWithX:0 y:0 width:0 height:0], 
                         [rect intersectionWithRectangle:outsideRect], @"intersection should be empty");
    STAssertEqualObjects([SPRectangle rectangleWithX:5 y:0 width:0 height:10],
                         [rect intersectionWithRectangle:touchingRect], @"wrong intersection shape");
    STAssertEqualObjects(insideRect, [rect intersectionWithRectangle:insideRect],
                         @"wrong intersection shape");
}

- (void)testUniteWithRectangle
{
    SPRectangle *rect = [SPRectangle rectangleWithX:-5 y:-10 width:10 height:20];
    
    SPRectangle *topLeftRect = [SPRectangle rectangleWithX:-15 y:-20 width:5 height:5];
    SPRectangle *innerRect = [SPRectangle rectangleWithX:-5 y:-5 width:10 height:10];
    
    STAssertEqualObjects([SPRectangle rectangleWithX:-15 y:-20 width:20 height:30],
                         [rect uniteWithRectangle:topLeftRect], @"wrong union");
    STAssertEqualObjects(rect, [rect uniteWithRectangle:innerRect], @"wrong union");    
}

- (void)testNilArguments
{
    SPRectangle *rect = [SPRectangle rectangleWithX:0 y:0 width:10 height:20];
    STAssertFalse([rect intersectsRectangle:nil], @"could not deal with nil argument");
    STAssertNil([rect intersectionWithRectangle:nil], @"could not deal with nil argument");
    STAssertEqualObjects(rect, [rect uniteWithRectangle:nil], @"could not deal with nil argument");
}

@end

#endif