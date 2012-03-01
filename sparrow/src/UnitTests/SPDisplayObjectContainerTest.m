//
//  SPDisplayObjectContainerTest.m
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
#import "SPStage.h"
#import "SPRectangle.h"
#import "SPDisplayObject_Internal.h"

// -------------------------------------------------------------------------------------------------

@interface SPDisplayObjectContainerTest : SenTestCase 
{
    int mAdded;
    int mAddedToStage;
    int mRemoved;
    int mRemovedFromStage;
    int mEventCount;
    SPSprite *mTestSprite;
    SPEventDispatcher *mBroadcastTarget;
}

- (void)addQuadToSprite:(SPSprite*)sprite;

@end

// -------------------------------------------------------------------------------------------------

@implementation SPDisplayObjectContainerTest

#define E 0.0001f

- (void) setUp
{
    mAdded = mAddedToStage = mRemoved = mRemovedFromStage = mEventCount = 0;    
    mTestSprite = [[SPSprite alloc] init];
}

- (void) tearDown
{
    [mTestSprite release];
}

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

- (void)testSetChildIndex
{
    SPSprite *parent = [SPSprite sprite];
    SPSprite *childA = [SPSprite sprite];
    SPSprite *childB = [SPSprite sprite];
    SPSprite *childC = [SPSprite sprite];
    
    [parent addChild:childA];
    [parent addChild:childB];
    [parent addChild:childC];
    
    [parent setIndex:0 ofChild:childB];
    STAssertEquals(childB, [parent childAtIndex:0], @"wrong child order");
    STAssertEquals(childA, [parent childAtIndex:1], @"wrong child order");
    STAssertEquals(childC, [parent childAtIndex:2], @"wrong child order");
    
    [parent setIndex:1 ofChild:childB];
    STAssertEquals(childA, [parent childAtIndex:0], @"wrong child order");
    STAssertEquals(childB, [parent childAtIndex:1], @"wrong child order");
    STAssertEquals(childC, [parent childAtIndex:2], @"wrong child order");
    
    [parent setIndex:2 ofChild:childB];
    STAssertEquals(childA, [parent childAtIndex:0], @"wrong child order");
    STAssertEquals(childC, [parent childAtIndex:1], @"wrong child order");
    STAssertEquals(childB, [parent childAtIndex:2], @"wrong child order");
    
    STAssertEquals(3, parent.numChildren, @"wrong child count");
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

- (void)testIllegalRecursion
{
    SPSprite *sprite1 = [SPSprite sprite];
    SPSprite *sprite2 = [SPSprite sprite];
    SPSprite *sprite3 = [SPSprite sprite];
    
    [sprite1 addChild:sprite2];
    [sprite2 addChild:sprite3];
    
    STAssertThrows([sprite3 addChild:sprite1], @"container allowed adding child as parent");
}

- (void)testAddAsChildToSelf
{
    SPSprite *sprite = [SPSprite sprite];
    STAssertThrows([sprite addChild:sprite], @"container allowed adding self as child");
}

- (void)addQuadToSprite:(SPSprite*)sprite
{
    SPQuad *quad = [[SPQuad alloc] initWithWidth:100 height:100];
    quad.alpha = 0.2f;
    [sprite addChild:quad];
    [quad release];
    return;
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

- (void)testChildByName
{
    SPSprite *parent = [SPSprite sprite];
    SPSprite *child1 = [SPSprite sprite];
    SPSprite *child2 = [SPSprite sprite];
    SPSprite *child3 = [SPSprite sprite];
    
    [parent addChild:child1];
    [parent addChild:child2];
    [parent addChild:child3];
    
    child1.name = @"CHILD";
    child3.name = @"child";
    
    STAssertEquals(child1, [parent childByName:@"CHILD"], @"wrong child returned");
    STAssertEquals(child3, [parent childByName:@"child"], @"wrong child returned");
    STAssertNil([parent childByName:@"ChIlD"], @"return child on wrong name");
}

- (void)testSortChildren
{
    SPSprite *s1 = [SPSprite sprite]; s1.y = 8;
    SPSprite *s2 = [SPSprite sprite]; s2.y = 3;
    SPSprite *s3 = [SPSprite sprite]; s3.y = 6;
    SPSprite *s4 = [SPSprite sprite]; s4.y = 1;
    
    SPSprite *parent = [SPSprite sprite];
    [parent addChild:s1];
    [parent addChild:s2];
    [parent addChild:s3];
    [parent addChild:s4];
    
    [parent sortChildren:^(SPDisplayObject *child1, SPDisplayObject *child2) 
    {
        if (child1.y < child2.y) return NSOrderedAscending;
        else if (child1.y > child2.y) return NSOrderedDescending;
        else return NSOrderedSame;
    }];

    STAssertEquals(s4, [parent childAtIndex:0], @"incorrect sort");
    STAssertEquals(s2, [parent childAtIndex:1], @"incorrect sort");
    STAssertEquals(s3, [parent childAtIndex:2], @"incorrect sort");
    STAssertEquals(s1, [parent childAtIndex:3], @"incorrect sort");
}

- (void)testBroadcastEvent
{
    SPSprite *parent = [SPSprite sprite];

    SPSprite *child1 = [SPSprite sprite];
    SPSprite *child2 = [SPSprite sprite];
    SPSprite *child3 = [SPSprite sprite];
    
    [parent addChild:child1];
    [parent addChild:child2];
    [parent addChild:child3];
    
    child1.name = @"trigger";
    [child1 addEventListener:@selector(onChildEvent:) atObject:self forType:@"dunno"];
    [child2 addEventListener:@selector(onChildEvent:) atObject:self forType:@"dunno"];
    [child3 addEventListener:@selector(onChildEvent:) atObject:self forType:@"dunno"];
    
    SPEvent *event = [SPEvent eventWithType:@"dunno"];
    [parent broadcastEvent:event];
    
    // event should have dispatched to all 3 children, even if the event listener
    // removes the children from their parent when it reaches child1. Furthermore, it should
    // not crash.
    
    STAssertEquals(3, mEventCount, @"not all children received events!");
}

- (void)testBroadcastEventTarget
{
    SPSprite *parent = [SPSprite sprite];
    SPSprite *childA = [SPSprite sprite];
    SPSprite *childA1 = [SPSprite sprite];
    SPSprite *childA2 = [SPSprite sprite];
    
    [parent addChild:childA];
    [parent addChild:childA1];
    [parent addChild:childA2];
    
    parent.name = @"parent";
    childA.name = @"childA";
    childA1.name = @"childA1";
    childA2.name = @"childA2";
    
    [childA2 addEventListener:@selector(onBroadcastEvent:) atObject:self forType:@"test"];
    [parent broadcastEvent:[SPEvent eventWithType:@"test"]];
    
    STAssertEquals(parent, mBroadcastTarget, @"wrong event.target on broadcast");
}

- (void)onBroadcastEvent:(SPEvent *)event
{
    mBroadcastTarget = event.target;
}

- (void)onChildEvent:(SPEvent *)event
{
    SPDisplayObject *target = (SPDisplayObject *)event.target;
    
    if ([target.name isEqualToString:@"trigger"])
        [target.parent removeAllChildren];
    
    ++mEventCount;
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