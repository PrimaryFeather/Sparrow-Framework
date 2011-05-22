//
//  SPQuadTest.m
//  Sparrow
//
//  Created by Daniel Sperl on 23.04.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Availability.h>
#ifdef __IPHONE_3_0

#import <SenTestingKit/SenTestingKit.h>
#import <UIKit/UIKit.h>
#import <math.h>

#import "SPMatrix.h"
#import "SPMacros.h"
#import "SPPoint.h"
#import "SPSprite.h"
#import "SPQuad.h"

// -------------------------------------------------------------------------------------------------

@interface SPQuadTest : SenTestCase 

@end

// -------------------------------------------------------------------------------------------------

@implementation SPQuadTest

- (void)testProperties
{
    float width = 30.0f;
    float height = 20.0f;
    float x = 3;
    float y = 2;
    
    SPQuad *quad = [[SPQuad alloc] initWithWidth:width height:height];
    quad.x = x; 
    quad.y = y;
    
    STAssertTrue(SP_IS_FLOAT_EQUAL(x, quad.x), @"wrong x");
    STAssertTrue(SP_IS_FLOAT_EQUAL(y, quad.y), @"wrong y");
    STAssertTrue(SP_IS_FLOAT_EQUAL(width, quad.width), @"wrong width");
    STAssertTrue(SP_IS_FLOAT_EQUAL(height, quad.height), @"wrong height");
    
    [quad release];
}

- (void)testWidth
{
    float width = 30;
    float height = 40;
    float angle = SP_D2R(45.0f);
    SPQuad *quad = [[SPQuad alloc] initWithWidth:width height:height];
    quad.rotation = angle;

    float expectedWidth = cosf(angle) * (width + height);
    STAssertTrue(SP_IS_FLOAT_EQUAL(expectedWidth, quad.width), @"wrong width: %f", quad.width);
    
    [quad release];
}

@end

#endif