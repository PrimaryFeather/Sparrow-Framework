//
//  SPDisplayObjectTest.h
//  Sparrow
//
//  Created by Daniel Sperl on 13.04.09.
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
#import "SPMacros.h"
#import "SPPoint.h"
#import "SPSprite.h"
#import "SPQuad.h"

#define E 0.0001f

// -------------------------------------------------------------------------------------------------

@interface SPDisplayObjectTest : SenTestCase 
{
}

@end

// -------------------------------------------------------------------------------------------------

@implementation SPDisplayObjectTest

- (void)testRoot
{
    SPSprite *root = [[SPSprite alloc] init];    
    SPSprite *child = [[SPSprite alloc] init];
    SPSprite *grandChild = [[SPSprite alloc] init];
    
    [root addChild:child];
    [child addChild:grandChild];
    
    STAssertEqualObjects(root, grandChild.root, @"wrong root");
    
    [grandChild release];
    [child release];
    [root release];    
}

- (void)testTransformationMatrixToSpace
{
    SPSprite *sprite = [SPSprite sprite];
    SPSprite *child = [SPSprite sprite];
    child.x = 30;
    child.y = 20;
    child.scaleX = 1.2f;
    child.scaleY = 1.5f;
    child.rotation = PI/4.0f;    
    [sprite addChild:child];
    
    SPMatrix *matrix = [sprite transformationMatrixToSpace:child];    
    SPMatrix *expectedMatrix = child.transformationMatrix;
    [expectedMatrix invert];
    STAssertEqualObjects(expectedMatrix, matrix, @"wrong matrix");

    matrix = [child transformationMatrixToSpace:sprite];
    STAssertEqualObjects(child.transformationMatrix, matrix, @"wrong matrix");    
    
    // more is tested indirectly via 'testBoundsInSpace' in DisplayObjectContainerTest
}

- (void)testTransformationMatrix
{
    SPSprite *sprite = [[SPSprite alloc] init];
    sprite.x = 50;
    sprite.y = 100;
    sprite.rotation = PI / 4;
    sprite.scaleX = 0.5;
    sprite.scaleY = 1.5;
    
    SPMatrix *matrix = [[SPMatrix alloc] init];
    [matrix scaleXBy:sprite.scaleX yBy:sprite.scaleY];
    [matrix rotateBy:sprite.rotation];
    [matrix translateXBy:sprite.x yBy:sprite.y];
    
    STAssertEqualObjects(sprite.transformationMatrix, matrix, @"wrong matrix");
    
    [sprite release];
    [matrix release];
}

- (void)testBounds
{
    SPQuad *quad = [[SPQuad alloc] initWithWidth:10 height:20];
    quad.x = -10;
    quad.y = 10;
    quad.rotation = PI_HALF;
    SPRectangle *bounds = quad.bounds;
    
    STAssertTrue(SP_IS_FLOAT_EQUAL(-30, bounds.x), @"wrong bounds.x: %f", bounds.x);
    STAssertTrue(SP_IS_FLOAT_EQUAL(10, bounds.y), @"wrong bounds.y: %f", bounds.y);
    STAssertTrue(SP_IS_FLOAT_EQUAL(20, bounds.width), @"wrong bounds.width: %f", bounds.width);
    STAssertTrue(SP_IS_FLOAT_EQUAL(10, bounds.height), @"wrong bounds.height: %f", bounds.height);
    
    bounds = [quad boundsInSpace:quad];
    STAssertTrue(SP_IS_FLOAT_EQUAL(0, bounds.x), @"wrong inner bounds.x: %f", bounds.x);
    STAssertTrue(SP_IS_FLOAT_EQUAL(0, bounds.y), @"wrong inner bounds.y: %f", bounds.y);
    STAssertTrue(SP_IS_FLOAT_EQUAL(10, bounds.width), @"wrong inner bounds.width: %f", bounds.width);
    STAssertTrue(SP_IS_FLOAT_EQUAL(20, bounds.height), @"wrong innter bounds.height: %f", bounds.height);
    
    [quad release];
}

- (void)testZeroSize
{
    SPSprite *sprite = [SPSprite sprite];
    STAssertEqualsWithAccuracy(1.0f, sprite.scaleX, E, @"wrong scaleX value");
    STAssertEqualsWithAccuracy(1.0f, sprite.scaleY, E, @"wrong scaleY value");
    
    // sprite is empty, scaling should thus have no effect!
    sprite.width = 100;
    sprite.height = 200;
    STAssertEqualsWithAccuracy(1.0f, sprite.scaleX, E, @"wrong scaleX value");
    STAssertEqualsWithAccuracy(1.0f, sprite.scaleY, E, @"wrong scaleY value");
    STAssertEqualsWithAccuracy(0.0f, sprite.width,  E, @"wrong width");
    STAssertEqualsWithAccuracy(0.0f, sprite.height, E, @"wrong height");
    
    // setting a value to zero should be no problem -- and the original size should be remembered.
    SPQuad *quad = [SPQuad quadWithWidth:100 height:200];
    quad.scaleX = 0.0f;
    quad.scaleY = 0.0f;
    STAssertEqualsWithAccuracy(0.0f, quad.width,  E, @"wrong width");
    STAssertEqualsWithAccuracy(0.0f, quad.height, E, @"wrong height");

    quad.scaleX = 1.0f;
    quad.scaleY = 1.0f;
    STAssertEqualsWithAccuracy(100.0f, quad.width,  E, @"wrong width");
    STAssertEqualsWithAccuracy(200.0f, quad.height, E, @"wrong height");
    STAssertEqualsWithAccuracy(1.0f, quad.scaleX,   E, @"wrong scaleX value");
    STAssertEqualsWithAccuracy(1.0f, quad.scaleY,   E, @"wrong scaleY value");
}

- (void)testLocalToGlobal
{
    SPSprite *sprite = [[SPSprite alloc] init];
    sprite.x = 10;
    sprite.y = 20;    
    SPSprite *sprite2 = [[SPSprite alloc] init];
    sprite2.x = 150;
    sprite2.y = 200;    
    [sprite addChild:sprite2];
    
    SPPoint *localPoint = [SPPoint pointWithX:0 y:0];
    SPPoint *globalPoint = [sprite2 localToGlobal:localPoint];
    SPPoint *expectedPoint = [SPPoint pointWithX:160 y:220];    
    STAssertEqualObjects(expectedPoint, globalPoint, @"wrong global point:");    
    
    [sprite release];
    [sprite2 release];
}

- (void)testLocalToGlobalWithPivot
{
    SPSprite *sprite = [SPSprite sprite];
    SPQuad *quad = [SPQuad quadWithWidth:40 height:30];
    quad.x = 10;
    quad.y = 20;
    quad.pivotX = quad.width;
    quad.pivotY = quad.height;
    [sprite addChild:quad];
    SPPoint *point = [SPPoint pointWithX:0.0f y:0.0f];
    
    SPPoint *globalPoint = [quad localToGlobal:point];
    STAssertEqualsWithAccuracy(-30.0f, globalPoint.x, E, @"wrong global point with pivot");
    STAssertEqualsWithAccuracy(-10.0f, globalPoint.y, E, @"wrong global point with pivot");
}

- (void)testGlobalToLocal
{
    SPSprite *sprite = [[SPSprite alloc] init];
    sprite.x = 10;
    sprite.y = 20;
    SPSprite *sprite2 = [[SPSprite alloc] init];
    sprite2.x = 150;
    sprite2.y = 200;    
    [sprite addChild:sprite2];
    
    SPPoint *globalPoint = [SPPoint pointWithX:160 y:220];
    SPPoint *localPoint = [sprite2 globalToLocal:globalPoint];
    SPPoint *expectedPoint = [SPPoint pointWithX:0 y:0];    
    STAssertEqualObjects(expectedPoint, localPoint, @"wrong local point");    
    
    [sprite release];
    [sprite2 release];
}

- (void)testHitTestPoint
{
    SPQuad *quad = [[SPQuad alloc] initWithWidth:25 height:10];
    
    STAssertNotNil([quad hitTestPoint:[SPPoint pointWithX:15 y:5] forTouch:YES], 
                   @"point should be inside");
    STAssertNotNil([quad hitTestPoint:[SPPoint pointWithX:0 y:0] forTouch:YES],  
                   @"point should be inside");
    STAssertNotNil([quad hitTestPoint:[SPPoint pointWithX:25 y:0] forTouch:YES], 
                   @"point should be inside");
    STAssertNotNil([quad hitTestPoint:[SPPoint pointWithX:25 y:10] forTouch:YES], 
                   @"point should be inside");
    STAssertNotNil([quad hitTestPoint:[SPPoint pointWithX:0 y:10] forTouch:YES], 
                   @"point should be inside");
    STAssertNil([quad hitTestPoint:[SPPoint pointWithX:-1 y:-1] forTouch:YES], 
                @"point should be outside");    
    STAssertNil([quad hitTestPoint:[SPPoint pointWithX:26 y:11] forTouch:YES], 
                @"point should be outside");

    quad.visible = NO;
    STAssertNil([quad hitTestPoint:[SPPoint pointWithX:15 y:5] forTouch:YES], 
                @"hitTest should fail, object invisible");
        
    quad.visible = YES;
    quad.touchable = NO;
    STAssertNil([quad hitTestPoint:[SPPoint pointWithX:15 y:5] forTouch:YES], 
                @"hitTest should fail, object untouchable");    

    quad.visible = NO;
    quad.touchable = NO;
    STAssertNotNil([quad hitTestPoint:[SPPoint pointWithX:15 y:5] forTouch:NO], 
                @"hitTest should succeed, this is no touch test");    
    
    [quad release];
}

- (void)testRotation
{
    SPQuad *quad = [SPQuad quadWithWidth:100 height:100];
    
    quad.rotation = SP_D2R(400);  
    STAssertEqualsWithAccuracy(SP_D2R(40.0f), quad.rotation, E, @"wrong angle");    
    quad.rotation = SP_D2R(220); 
    STAssertEqualsWithAccuracy(SP_D2R(-140.0f), quad.rotation, E, @"wrong angle");    
    quad.rotation = SP_D2R(180);  
    STAssertEqualsWithAccuracy(SP_D2R(180.0f), quad.rotation, E, @"wrong angle");    
    quad.rotation = SP_D2R(-90); 
    STAssertEqualsWithAccuracy(SP_D2R(-90.0f), quad.rotation, E, @"wrong angle");    
    quad.rotation = SP_D2R(-179); 
    STAssertEqualsWithAccuracy(SP_D2R(-179.0f), quad.rotation, E, @"wrong angle");    
    quad.rotation = SP_D2R(-180); 
    STAssertEqualsWithAccuracy(SP_D2R(-180.0f), quad.rotation, E, @"wrong angle");    
    quad.rotation = SP_D2R(-181); 
    STAssertEqualsWithAccuracy(SP_D2R(179.0f), quad.rotation, E, @"wrong angle");    
    quad.rotation = SP_D2R(-300); 
    STAssertEqualsWithAccuracy(SP_D2R(60.0f), quad.rotation, E, @"wrong angle");    
    quad.rotation = SP_D2R(-370); 
    STAssertEqualsWithAccuracy(SP_D2R(-10.0f), quad.rotation, E, @"wrong angle");
}

- (void)testPivotPoint
{
    float width = 100.0f;
    float height = 150.0f;
    
    // a quad with a pivot point should behave exactly as a quad without 
    // pivot point inside a sprite
    
    SPSprite *sprite = [SPSprite sprite];
    SPQuad *innerQuad = [SPQuad quadWithWidth:width height:height];
    [sprite addChild:innerQuad];
    
    SPQuad *quad = [SPQuad quadWithWidth:width height:height];
    
    STAssertEqualObjects(sprite.bounds, quad.bounds, @"Bounds are not equal (no pivot)");
   
    innerQuad.x = -50;
    quad.pivotX = 50;
    
    innerQuad.y = -20;
    quad.pivotY = 20;
    
    STAssertEqualObjects(sprite.bounds, quad.bounds, @"Bounds are not equal (pivot)");
    
    sprite.rotation = SP_D2R(45);
    quad.rotation = SP_D2R(45);
    
    STAssertEqualObjects(sprite.bounds, quad.bounds, @"Bounds are not equal (pivot, rotation)");

    sprite.scaleX = 1.5f;
    quad.scaleX = 1.5f;
    
    STAssertEqualObjects(sprite.bounds, quad.bounds, @"Bounds are not equal (pivot, scaleX");
    
    sprite.scaleY = 0.6f;
    quad.scaleY = 0.6f;
    
    STAssertEqualObjects(sprite.bounds, quad.bounds, @"Bounds are not equal (pivot, scaleY");

    sprite.x = 5.0f;
    sprite.y = 20.0f;
    
    quad.x = 5.0f;
    quad.y = 20.0f;
    
    STAssertEqualObjects(sprite.bounds, quad.bounds, @"Bounds are not equal (pivot, translation");
}
 
- (void)testName
{
    SPSprite *sprite = [SPSprite sprite];
    STAssertNil(sprite.name, @"name not nil after initialization");
    
    sprite.name = @"hugo";
    STAssertEqualObjects(@"hugo", sprite.name, @"wrong name");
}

@end

#endif