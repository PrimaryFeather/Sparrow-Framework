//
//  SPMatrixTest.m
//  Sparrow
//
//  Created by Daniel Sperl on 26.03.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Availability.h>
#ifdef __IPHONE_3_0

#import <SenTestingKit/SenTestingKit.h>
#import <UIKit/UIKit.h>

#import "SPMatrix.h"
#import "SPPoint.h"
#import "SPMacros.h"

// -------------------------------------------------------------------------------------------------

@interface SPMatrixTest : SenTestCase 
{
    SPMatrix *countMatrix;
    SPMatrix *identMatrix;
}

- (BOOL)checkMatrixValues:(SPMatrix*)matrix a:(float)a b:(float)b c:(float)c d:(float)d 
                       tx:(float)tx ty:(float)ty;

@end

// -------------------------------------------------------------------------------------------------

@implementation SPMatrixTest

- (void) setUp
{
    countMatrix = [[SPMatrix alloc] initWithA:1 b:2 c:3 d:4 tx:5 ty:6];
    identMatrix = [[SPMatrix alloc] init];
}

- (void) tearDown
{
    [countMatrix release];
    [identMatrix release];
}

- (void)testInit
{
    BOOL isEqual = [self checkMatrixValues:countMatrix a:1.0f b:2.0f c:3.0f d:4.0f tx:5.0f ty:6.0f];
    STAssertTrue(isEqual, @"wrong matrix: %@", countMatrix);
    isEqual = [self checkMatrixValues:identMatrix a:1.0f b:0.0f c:0.0f d:1.0f tx:0.0f ty:0.0f];
    STAssertTrue(isEqual, @"wrong matrix: %@", identMatrix);
}

- (void)testCopy
{
    SPMatrix *copy = [countMatrix copy];
    STAssertEqualObjects(countMatrix, copy, @"copy not equal: %@", copy);
    STAssertFalse(countMatrix == copy, @"copy is identical");
    
    [copy release];
}

- (void)testConcatMatrix
{
    SPMatrix *copy = [countMatrix copy];
    [copy concatMatrix:identMatrix];
    STAssertEqualObjects(countMatrix, copy, @"multiplication with identity modified matrix");
    [copy release];
    copy = [identMatrix copy];
    [copy concatMatrix:countMatrix];
    STAssertEqualObjects(countMatrix, copy, @"multiplication with identity modified matrix");
    
    SPMatrix *countDownMatrix = [[SPMatrix alloc] initWithA:9 b:8 c:7 d:6 tx:5 ty:4];
    [copy concatMatrix:countDownMatrix];
    STAssertTrue([self checkMatrixValues:copy a:23 b:20 c:55 d:48 tx:92 ty:80], 
                 @"wrong matrix: %@", copy);
    [countDownMatrix concatMatrix:countMatrix];
    STAssertTrue([self checkMatrixValues:countDownMatrix a:33 b:50 c:25 d:38 tx:22 ty:32],
                 @"wrong matrix: %@", copy);  
    
    [countDownMatrix release];
    [copy release];
}

- (void)testInvert
{
    [countMatrix invert];
    STAssertTrue([self checkMatrixValues:countMatrix a:-2 b:1 c:3.0f/2.0f d:-0.5f tx:1 ty:-2],
                 @"invert produced wrong result: %@", countMatrix);
    
    SPMatrix *translateMatrix = [SPMatrix matrixWithIdentity];
    [translateMatrix translateXBy:20 yBy:40];
    [translateMatrix invert];
    
    STAssertTrue([self checkMatrixValues:translateMatrix a:1 b:0 c:0 d:1 tx:-20 ty:-40],
                @"invert produced wrong result: %@", translateMatrix);
}

- (void)testTranslate
{
    [identMatrix translateXBy:5 yBy:7];
    SPPoint *point = [[SPPoint alloc] initWithX:10 y:20];
    SPPoint *tPoint = [identMatrix transformPoint:point];
    STAssertTrue(SP_IS_FLOAT_EQUAL(15, tPoint.x), @"wrong x value: %f", tPoint.x);
    STAssertTrue(SP_IS_FLOAT_EQUAL(27, tPoint.y), @"wrong y value: %f", tPoint.y);    
    [point release];
}

- (void)testRotate
{
    [identMatrix rotateBy:PI/2.0f];
    SPPoint *point = [[SPPoint alloc] initWithX:10 y:0];
    SPPoint *rPoint = [identMatrix transformPoint:point];
    STAssertTrue(SP_IS_FLOAT_EQUAL(0, rPoint.x), @"wrong x value: %f", rPoint.x);
    STAssertTrue(SP_IS_FLOAT_EQUAL(10, rPoint.y), @"wrong y value: %f", rPoint.y);
    
    [identMatrix identity];
    [identMatrix rotateBy:PI];
    point.y = 20;
    rPoint = [identMatrix transformPoint:point];
    STAssertTrue(SP_IS_FLOAT_EQUAL(-10, rPoint.x), @"wrong x value: %f", rPoint.x);
    STAssertTrue(SP_IS_FLOAT_EQUAL(-20, rPoint.y), @"wrong y value: %f", rPoint.y);
    
    [point release];
}

- (void)testScale
{
    [identMatrix scaleXBy:2.0 yBy:0.5];
    SPPoint *point = [[SPPoint alloc] initWithX:10 y:20];
    SPPoint *sPoint = [identMatrix transformPoint:point];
    STAssertTrue(SP_IS_FLOAT_EQUAL(20.0f, sPoint.x), @"wrong x value: %f", sPoint.x);
    STAssertTrue(SP_IS_FLOAT_EQUAL(10.0f, sPoint.y), @"wrong y value: %f", sPoint.y);    
    [point release];
}

- (void)testConcatenatedTransformations
{
    [identMatrix rotateBy:PI/2.0f];    
    [identMatrix scaleBy:0.5f];
    [identMatrix translateXBy:0.0f yBy:5.0];
    SPPoint *point = [[SPPoint alloc] initWithX:10 y:0];
    SPPoint *ctPoint = [identMatrix transformPoint:point];
    STAssertTrue(SP_IS_FLOAT_EQUAL(0.0f, ctPoint.x), @"wrong x value: %f", ctPoint.x);
    STAssertTrue(SP_IS_FLOAT_EQUAL(10.0f, ctPoint.y), @"wrong y value: %f", ctPoint.y);    
    [point release];
}

- (BOOL)checkMatrixValues:(SPMatrix*)matrix a:(float)a b:(float)b c:(float)c d:(float)d 
                       tx:(float)tx ty:(float)ty
{
    return SP_IS_FLOAT_EQUAL(a, matrix.a) && SP_IS_FLOAT_EQUAL(b, matrix.b) &&
           SP_IS_FLOAT_EQUAL(b, matrix.b) && SP_IS_FLOAT_EQUAL(c, matrix.c) &&
           SP_IS_FLOAT_EQUAL(tx, matrix.tx) && SP_IS_FLOAT_EQUAL(ty, matrix.ty);
}

@end

#endif