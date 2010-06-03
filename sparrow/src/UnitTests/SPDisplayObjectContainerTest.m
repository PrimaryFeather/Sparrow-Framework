//
//  SPDisplayObjectContainerTest.m
//  Sparrow
//
//  Created by Daniel Sperl on 13.04.09.
//  Copyright 2009 Incognitek. All rights reserved.
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
#import "SPStage.h"
#import "SPRectangle.h"

// -------------------------------------------------------------------------------------------------

@interface SPDisplayObjectContainerTest : SenTestCase 
{
    int mAdded;
    int mAddedToStage;
    int mRemoved;
    int mRemovedFromStage;
    SPSprite *mTestSprite;
}

- (void)addQuadToSprite:(SPSprite*)sprite;

@end

// -------------------------------------------------------------------------------------------------

@implementation SPDisplayObjectContainerTest

#define E 0.0001f

- (void) setUp
{
    mAdded = mAddedToStage = mRemoved = mRemovedFromStage = 0;    
    mTestSprite = [[SPSprite alloc] init];
}

- (void) tearDown
{
    [mTestSprite release];
}

#pragma mark -

- (void)testChildParentHandling
{
    SPSprite *parent = [[SPSprite alloc] init];
    SPSprite *child1 = [[SPSprite alloc] init];
    SPSprite *child2 = [[SPSprite alloc] init];
    
    STAssertEquals(0, parent.numChildren, @"wrong number of children");
    STAssertNil(child1.parent, @"parent not nil");
    
    [parent addChild:child1];
    STAssertEquals(1, parent.numChildren, @"wrong number of children");
    STAssertEqualObjects(parent, child1.parent, @"invalid parent");
    
    [parent addChild:child2];
    STAssertEquals(2, parent.numChildren, @"wrong number of children");
    STAssertEqualObjects(parent, child2.parent, @"invalid parent");
    STAssertEqualObjects(child1, [parent childAtIndex:0], @"wrong child index");
    STAssertEqualObjects(child2, [parent childAtIndex:1], @"wrong child index");
    
    [parent removeChild:child1];
    STAssertNil(child1.parent, @"parent not nil");
    STAssertEqualObjects(child2, [parent childAtIndex:0], @"wrong child index");
    STAssertNoThrow([child1 removeFromParent], @"exception raised");
    
    [child2 addChild:child1];
    STAssertTrue([parent containsChild:child1], @"child not found");
    STAssertTrue([parent containsChild:child2], @"child not found");
    STAssertEqualObjects(child2, child1.parent, @"invalid parent");
    
    [parent addChild:child1 atIndex:0];
    STAssertEqualObjects(parent, child1.parent, @"invalid parent");
    STAssertFalse([child2 containsChild:child1], @"invalid connection");
    STAssertEqualObjects(child1, [parent childAtIndex:0], @"wrong child");
    STAssertEqualObjects(child2, [parent childAtIndex:1], @"wrong child");    
    
    [child2 release];
    [child1 release];
    [parent release];
}

- (void)testWidthAndHeight
{
    SPSprite *sprite = [[SPSprite alloc] init];
    
    SPQuad *quad1 = [[SPQuad alloc] initWithWidth:10 height:20];    
    quad1.x = -10;
    quad1.y = -15;
    
    SPQuad *quad2 = [[SPQuad alloc] initWithWidth:15 height:25];
    quad2.x = 30;
    quad2.y = 25;
    
    [sprite addChild:quad1];
    [sprite addChild:quad2];
    
    STAssertTrue(SP_IS_FLOAT_EQUAL(55.0f, sprite.width), @"wrong width: %f", sprite.width);
    STAssertTrue(SP_IS_FLOAT_EQUAL(65.0f, sprite.height), @"wrong height: %f", sprite.height);
    
    quad1.rotation = PI_HALF;
    STAssertTrue(SP_IS_FLOAT_EQUAL(75.0f, sprite.width), @"wrong width: %f", sprite.width);
    STAssertTrue(SP_IS_FLOAT_EQUAL(65.0f, sprite.height), @"wrong height: %f", sprite.height);
    
    quad1.rotation = PI;
    STAssertTrue(SP_IS_FLOAT_EQUAL(65.0f, sprite.width), @"wrong width: %f", sprite.width);
    STAssertTrue(SP_IS_FLOAT_EQUAL(85.0f, sprite.height), @"wrong height: %f", sprite.height);
    
    [quad1 release];
    [quad2 release];
    [sprite release];
}

- (void)testBounds
{
    SPQuad *quad = [[SPQuad alloc] initWithWidth:10 height:20];
    quad.x = -10;
    quad.y = 10;
    quad.rotation = PI_HALF;
    
    SPSprite *sprite = [[SPSprite alloc] init];
    [sprite addChild:quad];
    
    SPRectangle *bounds = [sprite bounds];
    STAssertTrue(SP_IS_FLOAT_EQUAL(-30, bounds.x), @"wrong bounds.x: %f", bounds.x);
    STAssertTrue(SP_IS_FLOAT_EQUAL(10, bounds.y), @"wrong bounds.y: %f", bounds.y);
    STAssertTrue(SP_IS_FLOAT_EQUAL(20, bounds.width), @"wrong bounds.width: %f", bounds.width);
    STAssertTrue(SP_IS_FLOAT_EQUAL(10, bounds.height), @"wrong bounds.height: %f", bounds.height);    
    
    bounds = [sprite boundsInSpace:sprite];
    STAssertTrue(SP_IS_FLOAT_EQUAL(-30, bounds.x), @"wrong bounds.x: %f", bounds.x);
    STAssertTrue(SP_IS_FLOAT_EQUAL(10, bounds.y), @"wrong bounds.y: %f", bounds.y);
    STAssertTrue(SP_IS_FLOAT_EQUAL(20, bounds.width), @"wrong bounds.width: %f", bounds.width);
    STAssertTrue(SP_IS_FLOAT_EQUAL(10, bounds.height), @"wrong bounds.height: %f", bounds.height); 
    
    [sprite release];
    [quad release];    
}

- (void)testBoundsInSpace
{
    SPSprite *root = [[SPSprite alloc] init];
    
    SPSprite *spriteA = [[SPSprite alloc] init];
    spriteA.x = 50;
    spriteA.y = 50;
    [self addQuadToSprite:spriteA];
    [root addChild:spriteA];
    [spriteA release];
    
    SPSprite *spriteA1 = [[SPSprite alloc] init];
    spriteA1.x = 150;
    spriteA1.y = 50;
    spriteA1.scaleX = spriteA1.scaleY = 0.5;
    [self addQuadToSprite:spriteA1];
    [spriteA addChild:spriteA1];
    [spriteA1 release];
    
    SPSprite *spriteA11 = [[SPSprite alloc] init];
    spriteA11.x = 25;
    spriteA11.y = 50;
    spriteA11.scaleX = spriteA11.scaleY = 0.5;
    [self addQuadToSprite:spriteA11];
    [spriteA1 addChild:spriteA11];
    [spriteA11 release];
    
    SPSprite *spriteA2 = [[SPSprite alloc] init];
    spriteA2.x = 50;
    spriteA2.y = 150;
    spriteA2.scaleX = spriteA2.scaleY = 0.5;
    [self addQuadToSprite:spriteA2];
    [spriteA addChild:spriteA2];
    [spriteA2 release];
    
    SPSprite *spriteA21 = [[SPSprite alloc] init];
    spriteA21.x = 50;
    spriteA21.y = 25;
    spriteA21.scaleX = spriteA21.scaleY = 0.5;
    [self addQuadToSprite:spriteA21];
    [spriteA2 addChild:spriteA21];    
    [spriteA21 release];
    
    // ---
    
    SPRectangle *bounds = [spriteA21 boundsInSpace:spriteA11];
    SPRectangle *expectedBounds = [SPRectangle rectangleWithX:-350 y:350 width:100 height:100];
    STAssertEqualObjects(expectedBounds, bounds, @"wrong bounds: %@", bounds);    
    
    // now rotate as well
    
    spriteA11.rotation = PI/4.0f;
    spriteA21.rotation = -PI/4.0f;
    
    bounds = [spriteA21 boundsInSpace:spriteA11];
    expectedBounds = [SPRectangle rectangleWithX:0 y:394.974762 width:100 height:100];
    STAssertEqualObjects(expectedBounds, bounds, @"wrong bounds: %@", bounds);    
    
    [root release];
}

- (void)testSize
{
    SPQuad *quad1 = [SPQuad quadWithWidth:100 height:100];
    SPQuad *quad2 = [SPQuad quadWithWidth:100 height:100];
    quad2.x = quad2.y = 100;
    
    SPSprite *sprite = [SPSprite sprite];
    SPSprite *childSprite = [SPSprite sprite];
    
    [sprite addChild:childSprite];
    [childSprite addChild:quad1];
    [childSprite addChild:quad2];
        
    
    STAssertEqualsWithAccuracy(200.0f, sprite.width, E, @"wrong width: %f", sprite.width);
    STAssertEqualsWithAccuracy(200.0f, sprite.height, E, @"wrong height: %f", sprite.height);
        
    sprite.scaleX = 2;
    sprite.scaleY = 2;
    STAssertEqualsWithAccuracy(400.0f, sprite.width, E, @"wrong width: %f", sprite.width);
    STAssertEqualsWithAccuracy(400.0f, sprite.height, E, @"wrong height: %f", sprite.height);    
}

- (void)addQuadToSprite:(SPSprite*)sprite
{
    SPQuad *quad = [[SPQuad alloc] initWithWidth:100 height:100];
    quad.alpha = 0.2f;
    [sprite addChild:quad];
    return [quad release];
}

- (void)testDisplayListEvents
{
    SPStage *stage = [[SPStage alloc] init];
    SPSprite *sprite = [[SPSprite alloc] init];
    SPQuad *quad = [[SPQuad alloc] initWithWidth:20 height:20];
    
    [quad addEventListener:@selector(onAdded:) atObject:self forType:SP_EVENT_TYPE_ADDED];
    [quad addEventListener:@selector(onAddedToStage:) atObject:self forType:SP_EVENT_TYPE_ADDED_TO_STAGE];
    [quad addEventListener:@selector(onRemoved:) atObject:self forType:SP_EVENT_TYPE_REMOVED];
    [quad addEventListener:@selector(onRemovedFromStage:) atObject:self forType:SP_EVENT_TYPE_REMOVED_FROM_STAGE];
    
    [sprite addChild:quad];
    
    STAssertEquals(1, mAdded, @"failure on event 'added'");
    STAssertEquals(0, mRemoved, @"failure on event 'removed'");
    STAssertEquals(0, mAddedToStage, @"failure on event 'addedToStage'");
    STAssertEquals(0, mRemovedFromStage, @"failure on event 'removedFromStage'");
    
    [stage addChild:sprite];
    
    STAssertEquals(1, mAdded, @"failure on event 'added'");
    STAssertEquals(0, mRemoved, @"failure on event 'removed'");
    STAssertEquals(1, mAddedToStage, @"failure on event 'addedToStage'");
    STAssertEquals(0, mRemovedFromStage, @"failure on event 'removedFromStage'");
    
    [stage removeChild:sprite];
    
    STAssertEquals(1, mAdded, @"failure on event 'added'");
    STAssertEquals(0, mRemoved, @"failure on event 'removed'");
    STAssertEquals(1, mAddedToStage, @"failure on event 'addedToStage'");
    STAssertEquals(1, mRemovedFromStage, @"failure on event 'removedFromStage'");
    
    [sprite removeChild:quad];
    
    STAssertEquals(1, mAdded, @"failure on event 'added'");
    STAssertEquals(1, mRemoved, @"failure on event 'removed'");
    STAssertEquals(1, mAddedToStage, @"failure on event 'addedToStage'");
    STAssertEquals(1, mRemovedFromStage, @"failure on event 'removedFromStage'");
    
    [quad removeEventListenersAtObject:self forType:SP_EVENT_TYPE_ADDED];
    [quad removeEventListenersAtObject:self forType:SP_EVENT_TYPE_ADDED_TO_STAGE];
    [quad removeEventListenersAtObject:self forType:SP_EVENT_TYPE_REMOVED];
    [quad removeEventListenersAtObject:self forType:SP_EVENT_TYPE_REMOVED_FROM_STAGE];
    
    [quad release];
    [sprite release];    
    [stage release];    
}

- (void)onAdded:(SPEvent*)event { mAdded++; }
- (void)onRemoved:(SPEvent*)event { mRemoved++; }
- (void)onAddedToStage:(SPEvent*)event { mAddedToStage++; }
- (void)onRemovedFromStage:(SPEvent*)event { mRemovedFromStage++; }

- (void)testRemovedFromStage
{
    SPStage *stage = [[SPStage alloc] init];
    [stage addChild:mTestSprite];    
    [mTestSprite addEventListener:@selector(onTestSpriteRemovedFromStage:) atObject:self
                          forType:SP_EVENT_TYPE_REMOVED_FROM_STAGE];    
    [mTestSprite removeFromParent];
    [mTestSprite removeEventListenersAtObject:self forType:SP_EVENT_TYPE_REMOVED_FROM_STAGE];        
    [stage release];
}

- (void)onTestSpriteRemovedFromStage:(SPEvent *)event
{
    STAssertNotNil(mTestSprite.stage, @"stage not accessible in removed from stage event");
}

- (void)testAddExistingChild
{
    SPSprite *sprite = [SPSprite sprite];
    SPQuad *quad = [SPQuad quadWithWidth:100 height:100];
    [sprite addChild:quad];
    STAssertNoThrow([sprite addChild:quad], @"Could not add child multiple times");
}

- (void)testRemoveAllChildren
{
    SPSprite *sprite = [SPSprite sprite];
    
    STAssertEquals(0, sprite.numChildren, @"wrong number of children");
    [sprite removeAllChildren];
    STAssertEquals(0, sprite.numChildren, @"wrong number of children");
    
    [sprite addChild:[SPQuad quadWithWidth:100 height:100]];
    [sprite addChild:[SPQuad quadWithWidth:100 height:100]];    

    STAssertEquals(2, sprite.numChildren, @"wrong number of children");
    [sprite removeAllChildren];    
    STAssertEquals(0, sprite.numChildren, @"remove all children did not work");    
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