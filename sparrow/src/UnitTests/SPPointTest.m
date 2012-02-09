//
//  SPPointTest.m
//  Sparrow
//
//  Created by Daniel Sperl on 25.03.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Availability.h>
#ifdef __IPHONE_3_0

#import <SenTestingKit/SenTestingKit.h>
#import <UIKit/UIKit.h>

#import "SPPoint.h"
#import "SPMacros.h"

#define E 0.0001f

// -------------------------------------------------------------------------------------------------

@interface SPPointTest :  SenTestCase  
{
    SPPoint *mP1;
    SPPoint *mP2;
}

@end

// -------------------------------------------------------------------------------------------------

@implementation SPPointTest

- (void) setUp
{
    mP1 = [[SPPoint alloc] initWithX:2 y:3];
    mP2 = [[SPPoint alloc] initWithX:4 y:1];    
}

- (void) tearDown
{
    [mP1 release];
    [mP2 release];
}

- (void)testInit
{
    SPPoint *point = [[SPPoint alloc] init];
    STAssertEquals(0.0f, point.x, @"x is not zero");
    STAssertEquals(0.0f, point.y, @"y is not zero");
    [point release];
}

- (void)testInitWithXandY
{
    SPPoint *point = [[SPPoint alloc] initWithX:3 y:4];
    STAssertEquals(3.0f, point.x, @"wrong x value");
    STAssertEquals(4.0f, point.y, @"wrong y value");
    [point release];
}

- (void)testLength
{
    SPPoint *point = [[SPPoint alloc] initWithX:-4 y:3];
    STAssertTrue(SP_IS_FLOAT_EQUAL(5.0f, point.length), @"wrong length");
    point.x = 0;
    point.y = 0;
    STAssertEquals(0.0f, point.length, @"wrong length");
    [point release];    
}

- (void)testLengthSquared
{
    SPPoint *point = [[SPPoint alloc] initWithX:-4 y:3];
    STAssertEqualsWithAccuracy(25.0f, point.lengthSquared, E, @"wrong squared length");
}

- (void)testAngle
{    
    SPPoint *point = [[SPPoint alloc] initWithX:10 y:0];
    STAssertTrue(SP_IS_FLOAT_EQUAL(0.0f, point.angle), @"wrong angle: %f", point.angle);
    point.y = 10;
    STAssertTrue(SP_IS_FLOAT_EQUAL(PI/4.0f, point.angle), @"wrong angle: %f", point.angle);
    point.x = 0;
    STAssertTrue(SP_IS_FLOAT_EQUAL(PI/2.0f, point.angle), @"wrong angle: %f", point.angle);
    point.x = -10;
    STAssertTrue(SP_IS_FLOAT_EQUAL(3*PI/4.0f, point.angle), @"wrong angle: %f", point.angle);
    point.y = 0;
    STAssertTrue(SP_IS_FLOAT_EQUAL(PI, point.angle), @"wrong angle: %f", point.angle);
    point.y = -10;
    STAssertTrue(SP_IS_FLOAT_EQUAL(-3*PI/4.0f, point.angle), @"wrong angle: %f", point.angle);
    point.x = 0;
    STAssertTrue(SP_IS_FLOAT_EQUAL(-PI/2.0f, point.angle), @"wrong angle: %f", point.angle);
    point.x = 10;
    STAssertTrue(SP_IS_FLOAT_EQUAL(-PI/4.0f, point.angle), @"wrong angle: %f", point.angle);
    [point release];    
}

- (void)testAddPoint
{
    SPPoint *result = [mP1 addPoint:mP2];
    STAssertTrue(SP_IS_FLOAT_EQUAL(6.0f, result.x), @"wrong x value");
    STAssertTrue(SP_IS_FLOAT_EQUAL(4.0f, result.y), @"wrong y value");
}

- (void)testSubtractPoint
{
    SPPoint *result = [mP1 subtractPoint:mP2];
    STAssertTrue(SP_IS_FLOAT_EQUAL(-2.0f, result.x), @"wrong x value");
    STAssertTrue(SP_IS_FLOAT_EQUAL(2.0f, result.y), @"wrong y value");
}

- (void)testScale
{
    SPPoint *point = [SPPoint pointWithX:0.0f y:0.0f];
    point = [point scaleBy:100.0f];
    STAssertEqualsWithAccuracy(point.x, 0.0f, E, @"wrong x value");
    STAssertEqualsWithAccuracy(point.y, 0.0f, E, @"wrong y value");
    
    point = [SPPoint pointWithX:1.0f y:2.0f];
    float origLength = point.length;
    point = [point scaleBy:2.0f];
    float scaledLength = point.length;
    STAssertEqualsWithAccuracy(point.x, 2.0f, E, @"wrong x value");
    STAssertEqualsWithAccuracy(point.y, 4.0f, E, @"wrong y value");
    STAssertEqualsWithAccuracy(origLength * 2.0f, scaledLength, E, @"wrong length");
}

- (void)testNormalize
{
    SPPoint *result = [mP1 normalize];
    STAssertTrue(SP_IS_FLOAT_EQUAL(1.0f, result.length), @"wrong length");
    STAssertTrue(SP_IS_FLOAT_EQUAL(mP1.angle, result.angle), @"wrong angle");
    SPPoint *origin = [[SPPoint alloc] init];
    STAssertThrows([origin normalize], @"origin cannot be normalized!");
    [origin release];
}

- (void)testInvert
{
    SPPoint *point = [mP1 invert];
    STAssertEqualsWithAccuracy(-mP1.x, point.x, E, @"wrong x value");
    STAssertEqualsWithAccuracy(-mP1.y, point.y, E, @"wrong y value");
}

- (void)testDotProduct
{
    STAssertEqualsWithAccuracy(11.0f, [mP1 dot:mP2], E, @"wrong dot product");
}

- (void)testRotate
{
    SPPoint *point = [SPPoint pointWithX:0 y:5];
    SPPoint *rPoint = [point rotateBy:PI_HALF];
    STAssertEqualsWithAccuracy(-5.0f, rPoint.x, E, @"wrong rotation");
    STAssertEqualsWithAccuracy( 0.0f, rPoint.y, E, @"wrong rotation");
    
    rPoint = [point rotateBy:PI];
    STAssertEqualsWithAccuracy( 0.0f, rPoint.x, E, @"wrong rotation");
    STAssertEqualsWithAccuracy(-5.0f, rPoint.y, E, @"wrong rotation");
}

- (void)testClone
{
    SPPoint *result = [mP1 copy];
    STAssertEquals(mP1.x, result.x, @"wrong x value");
    STAssertEquals(mP1.y, result.y, @"wrong y value");
    STAssertFalse(result == mP1, @"object should not be identical");
    STAssertEqualObjects(mP1, result, @"objects should be equal");
    [result release];
}

- (void)testIsEqual
{
    STAssertFalse([mP1 isEqual:mP2], @"should not be equal");    
    SPPoint *p3 = [[SPPoint alloc] initWithX:mP1.x y:mP1.y];
    STAssertTrue([mP1 isEqual:p3], @"should be equal");
    p3.x += 0.0000001;
    p3.y -= 0.0000001;
    STAssertTrue([mP1 isEqual:p3], @"should be equal, as difference is smaller than epsilon");
    [p3 release];
}

- (void)testIsOrigin
{
    SPPoint *point = [SPPoint point];
    STAssertTrue([SPPoint point].isOrigin, @"point not indicated as being in the origin");
    
    point.x = 1.0f;
    STAssertFalse(point.isOrigin, @"point wrongly indicated as being in the origin");
    
    point.x = 0.0f;
    point.y = 1.0f;
    STAssertFalse(point.isOrigin, @"point wrongly indicated as being in the origin");
}

- (void)testDistance
{
    SPPoint *p3 = [[SPPoint alloc] initWithX:5 y:0];
    SPPoint *p4 = [[SPPoint alloc] initWithX:5 y:5];
    float distance = [SPPoint distanceFromPoint:p3 toPoint:p4];
    STAssertTrue(SP_IS_FLOAT_EQUAL(5.0f, distance), @"wrong distance");
    p3.y = -5;
    distance = [SPPoint distanceFromPoint:p3 toPoint:p4];
    STAssertTrue(SP_IS_FLOAT_EQUAL(10.0f, distance), @"wrong distance");
    [p3 release];
    [p4 release];
}

- (void)testAngleBetweenPoints
{
    SPPoint *p1 = [SPPoint pointWithX:3.0f y:0.0f];
    SPPoint *p2 = [SPPoint pointWithX:0.0f y:1.5f];
    SPPoint *p3 = [SPPoint pointWithX:-2.0f y:0.0f];
    SPPoint *p4 = [SPPoint pointWithX:0.0f y:-4.0f];
    
    STAssertEqualsWithAccuracy(PI_HALF, [SPPoint angleBetweenPoint:p1 andPoint:p2], E, @"wrong angle");
    STAssertEqualsWithAccuracy(PI, [SPPoint angleBetweenPoint:p1 andPoint:p3], E, @"wrong angle");
    STAssertEqualsWithAccuracy(PI_HALF, [SPPoint angleBetweenPoint:p1 andPoint:p4], E, @"wrong angle");
}

- (void)testPolarPoint
{
    float angle = 5.0 * PI / 4.0;
    float negAngle = -(2*PI - angle);
    float length = 2.0f;
    SPPoint *p3 = [SPPoint pointWithPolarLength:length angle:angle];
    STAssertTrue(SP_IS_FLOAT_EQUAL(length, p3.length), @"wrong length");
    STAssertTrue(SP_IS_FLOAT_EQUAL(negAngle, p3.angle), @"wrong angle");
    STAssertTrue(SP_IS_FLOAT_EQUAL(-cosf(angle-PI)*length, p3.x), @"wrong x");
    STAssertTrue(SP_IS_FLOAT_EQUAL(-sinf(angle-PI)*length, p3.y), @"wrong y");    
}

- (void)testInterpolate
{
    SPPoint *interpolation;
    
    interpolation = [SPPoint interpolateFromPoint:mP1 toPoint:mP2 ratio:0.25f];
    STAssertEqualsWithAccuracy(interpolation.x, 2.5f, E, @"wrong interpolated x");
    STAssertEqualsWithAccuracy(interpolation.y, 2.5f, E, @"wrong interpolated y");

    interpolation = [SPPoint interpolateFromPoint:mP1 toPoint:mP2 ratio:-0.25f];
    STAssertEqualsWithAccuracy(interpolation.x, 1.5f, E, @"wrong interpolated x");
    STAssertEqualsWithAccuracy(interpolation.y, 3.5f, E, @"wrong interpolated y");

    interpolation = [SPPoint interpolateFromPoint:mP1 toPoint:mP2 ratio:1.25f];
    STAssertEqualsWithAccuracy(interpolation.x, 4.5f, E, @"wrong interpolated x");
    STAssertEqualsWithAccuracy(interpolation.y, 0.5f, E, @"wrong interpolated y");
    
    SPPoint *p1 = [SPPoint pointWithX:2.0f y:1.0f];
    SPPoint *p2 = [SPPoint pointWithX:-2.0f y:-1.0f];
    
    interpolation = [SPPoint interpolateFromPoint:p1 toPoint:p2 ratio:0.5f];    
    STAssertEqualsWithAccuracy(interpolation.x, 0.0f, E, @"wrong interpolated x");
    STAssertEqualsWithAccuracy(interpolation.y, 0.0f, E, @"wrong interpolated y");
    
    interpolation = [SPPoint interpolateFromPoint:p1 toPoint:p2 ratio:0.0f];
    STAssertEqualsWithAccuracy(interpolation.x, 2.0f, E, @"wrong interpolated x");
    STAssertEqualsWithAccuracy(interpolation.y, 1.0f, E, @"wrong interpolated y");
    
    interpolation = [SPPoint interpolateFromPoint:p1 toPoint:p2 ratio:1.0f];
    STAssertEqualsWithAccuracy(interpolation.x, -2.0f, E, @"wrong interpolated x");
    STAssertEqualsWithAccuracy(interpolation.y, -1.0f, E, @"wrong interpolated y");
}

// STAssertEquals(value, value, message, ...)
// STAssertEqualObjects(object, object, message, ...)
// STAssertNotNil(object, message, ...)
// STAssertTrue(expression, message, ...)
// STAssertFalse(expression, message, ...)
// STAssertThrows(expression, message, ...) 
// STAssertThrowsSpecific(expression, exception, message, ...)
// STAssertNoThrow(expression, message, ...)
// STFail(message, ...)

@end

#endif