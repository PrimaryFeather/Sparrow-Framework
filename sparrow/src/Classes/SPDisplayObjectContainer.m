//
//  SPDisplayObjectContainer.m
//  Sparrow
//
//  Created by Daniel Sperl on 15.03.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPDisplayObjectContainer.h"
#import "SPEnterFrameEvent.h"
#import "SPDisplayObject_Internal.h"
#import "SPMacros.h"
#import "SPEvent_Internal.h"

// --- C functions ---------------------------------------------------------------------------------

static void getChildEventListeners(SPDisplayObject *object, NSString *eventType, 
                                   NSMutableArray *listeners)
{
    // some events (ENTER_FRAME, ADDED_TO_STAGE, etc.) are dispatched very often and traverse
    // the entire display tree -- thus, it pays off handling them in their own c function.
    
    if ([object hasEventListenerForType:eventType])
        [listeners addObject:object];
    
    if ([object isKindOfClass:[SPDisplayObjectContainer class]])
        for (SPDisplayObject *child in (SPDisplayObjectContainer *)object)        
            getChildEventListeners(child, eventType, listeners);
}

// --- class implementation ------------------------------------------------------------------------

@implementation SPDisplayObjectContainer

@synthesize clipRect = mClipRect;

- (id)init
{    
    #if DEBUG    
    if ([[self class] isEqual:[SPDisplayObjectContainer class]]) 
    { 
        [NSException raise:SP_EXC_ABSTRACT_CLASS 
                    format:@"Attempting to instantiate SPDisplayObjectContainer directly."];
        [self release]; 
        return nil; 
    }    
    #endif
    
    if ((self = [super init])) 
    {
        mChildren = [[NSMutableArray alloc] init];
    }    
    return self;
}

- (void)addChild:(SPDisplayObject *)child
{
    [self addChild:child atIndex:[mChildren count]];
}

- (void)addChild:(SPDisplayObject *)child atIndex:(int)index
{
    if (index >= 0 && index <= [mChildren count])
    {
        [child retain];
        [child removeFromParent];
        [mChildren insertObject:child atIndex:MIN(mChildren.count, index)];
        child.parent = self;
        
        SPEvent *addedEvent = [[SPEvent alloc] initWithType:SP_EVENT_TYPE_ADDED];    
        [child dispatchEvent:addedEvent];
        [addedEvent release];    
        
        if (self.stage)
        {
            SPEvent *addedToStageEvent = [[SPEvent alloc] initWithType:SP_EVENT_TYPE_ADDED_TO_STAGE];
            [child broadcastEvent:addedToStageEvent];
            [addedToStageEvent release];
        }
        
        [child release];
    }
    else [NSException raise:SP_EXC_INDEX_OUT_OF_BOUNDS format:@"Invalid child index"]; 
}

- (BOOL)containsChild:(SPDisplayObject *)child
{
    while (child)
    {
        if (child == self) return YES;
        else child = child.parent;
    }
    
    return NO;
}

- (SPDisplayObject *)childAtIndex:(int)index
{
    return [mChildren objectAtIndex:index];
}

- (SPDisplayObject *)childByName:(NSString *)name
{
    for (SPDisplayObject *currentChild in mChildren)
        if ([currentChild.name isEqualToString:name]) return currentChild;
    
    return nil;
}

- (int)childIndex:(SPDisplayObject *)child
{
    int index = [mChildren indexOfObject:child];
    if (index == NSNotFound) return SP_NOT_FOUND;
    else                     return index;
}

- (void)setIndex:(int)index ofChild:(SPDisplayObject *)child
{
    int oldIndex = [mChildren indexOfObject:child];
    if (oldIndex == NSNotFound) 
        [NSException raise:SP_EXC_INVALID_OPERATION format:@"Not a child of this container"];
    else
    {
        [child retain];
        [mChildren removeObjectAtIndex:oldIndex];
        [mChildren insertObject:child atIndex:index];
        [child release];
    }
}

- (void)removeChild:(SPDisplayObject *)child
{
    int childIndex = [self childIndex:child];
    if (childIndex != SP_NOT_FOUND)
        [self removeChildAtIndex:childIndex];
}

- (void)removeChildAtIndex:(int)index
{
    if (index >= 0 && index < [mChildren count])
    {
        SPDisplayObject *child = [mChildren objectAtIndex:index];

        SPEvent *remEvent = [[SPEvent alloc] initWithType:SP_EVENT_TYPE_REMOVED];    
        [child dispatchEvent:remEvent];
        [remEvent release];    
        
        if (self.stage)
        {
            SPEvent *remFromStageEvent = [[SPEvent alloc] initWithType:SP_EVENT_TYPE_REMOVED_FROM_STAGE];
            [child broadcastEvent:remFromStageEvent];
            [remFromStageEvent release];
        }        
        
        child.parent = nil; 
        index = [mChildren indexOfObject:child]; // index might have changed in event handler
        if (index != NSNotFound) [mChildren removeObjectAtIndex:index];
    }
    else [NSException raise:SP_EXC_INDEX_OUT_OF_BOUNDS format:@"Invalid child index"];        
}

- (void)swapChild:(SPDisplayObject*)child1 withChild:(SPDisplayObject*)child2
{
    int index1 = [self childIndex:child1];
    int index2 = [self childIndex:child2];
    [self swapChildAtIndex:index1 withChildAtIndex:index2];
}

- (void)swapChildAtIndex:(int)index1 withChildAtIndex:(int)index2
{    
    int numChildren = [mChildren count];    
    if (index1 < 0 || index1 >= numChildren || index2 < 0 || index2 >= numChildren)
        [NSException raise:SP_EXC_INVALID_OPERATION format:@"invalid child indices"];
    [mChildren exchangeObjectAtIndex:index1 withObjectAtIndex:index2];
}

- (void)sortChildren:(NSComparator)comparator
{
    if ([mChildren respondsToSelector:@selector(sortWithOptions:usingComparator:)])
        [mChildren sortWithOptions:NSSortStable usingComparator:comparator];
    else
        [NSException raise:SP_EXC_INVALID_OPERATION 
                    format:@"sortChildren is only available in iOS 4 and above"];
}

- (void)removeAllChildren
{
    for (int i=mChildren.count-1; i>=0; --i)
        [self removeChildAtIndex:i];
}

- (int)numChildren
{
    return [mChildren count];
}

- (SPRectangle *)clipBoundsInSpace:(SPDisplayObject *)targetCoordinateSpace
{
    if (mClipRect == nil) return nil;
    
    float minX = FLT_MAX, maxX = -FLT_MAX, minY = FLT_MAX, maxY = -FLT_MAX;
    SPMatrix *transformationMatrix = [self transformationMatrixToSpace:targetCoordinateSpace];
    SPPoint *point = [[SPPoint alloc] init];
    for (int i=0; i<4; ++i)
    {
        switch (i) 
        {
            case 0: point.x = mClipRect.left; point.y = mClipRect.top; break;
            case 1: point.x = mClipRect.left; point.y = mClipRect.bottom; break;
            case 2: point.x = mClipRect.right; point.y = mClipRect.top; break;
            case 3: point.x = mClipRect.right; point.y = mClipRect.bottom; break;
        }
        SPPoint *transformedPoint = [transformationMatrix transformPoint:point];
        float tfX = transformedPoint.x; 
        float tfY = transformedPoint.y;
        minX = MIN(minX, tfX);
        maxX = MAX(maxX, tfX);
        minY = MIN(minY, tfY);
        maxY = MAX(maxY, tfY);
    }
    
    [point release];
    
    return [SPRectangle rectangleWithX:minX y:minY width:maxX-minX height:maxY-minY];
}

- (SPRectangle*)boundsInSpace:(SPDisplayObject*)targetCoordinateSpace
{    
    SPRectangle* bounds = nil;
    
    int numChildren = [mChildren count];

    if (numChildren == 0)
    {
        SPMatrix *transformationMatrix = [self transformationMatrixToSpace:targetCoordinateSpace];
        SPPoint *point = [SPPoint pointWithX:self.x y:self.y];
        SPPoint *transformedPoint = [transformationMatrix transformPoint:point];
        bounds = [SPRectangle rectangleWithX:transformedPoint.x y:transformedPoint.y 
                                     width:0.0f height:0.0f];
    }
    else if (numChildren == 1)
    {
        bounds = [[mChildren objectAtIndex:0] boundsInSpace:targetCoordinateSpace];
    }
    else
    {
        float minX = FLT_MAX, maxX = -FLT_MAX, minY = FLT_MAX, maxY = -FLT_MAX;    
        for (SPDisplayObject *child in mChildren)
        {
            SPRectangle *childBounds = [child boundsInSpace:targetCoordinateSpace];        
            minX = MIN(minX, childBounds.x);
            maxX = MAX(maxX, childBounds.x + childBounds.width);
            minY = MIN(minY, childBounds.y);
            maxY = MAX(maxY, childBounds.y + childBounds.height);        
        }    
        bounds =  [SPRectangle rectangleWithX:minX y:minY width:maxX-minX height:maxY-minY];
    }
    
    // if we have a clip rect, intersect it with our bounds
    if (mClipRect != nil)
        bounds = [bounds intersectionWithRectangle:[self clipBoundsInSpace:targetCoordinateSpace]];
    
    return bounds;
}

- (SPDisplayObject*)hitTestPoint:(SPPoint*)localPoint forTouch:(BOOL)isTouch
{
    if (isTouch && (!self.visible || !self.touchable)) 
        return nil;
    
    if (mClipRect != nil && ![mClipRect containsPoint:localPoint])
        return nil;
    
    for (int i=[mChildren count]-1; i>=0; --i) // front to back!
    {
        SPDisplayObject *child = [mChildren objectAtIndex:i];
        SPMatrix *transformationMatrix = [self transformationMatrixToSpace:child];
        SPPoint  *transformedPoint = [transformationMatrix transformPoint:localPoint];
        SPDisplayObject *target = [child hitTestPoint:transformedPoint forTouch:isTouch];
        if (target) return target;
    }
    
    return nil;
}

- (void)broadcastEvent:(SPEvent *)event
{
    if (event.bubbles) 
        [NSException raise:SP_EXC_INVALID_OPERATION 
                    format:@"Broadcast of bubbling events is prohibited"];
    
    // the event listeners might modify the display tree, which could make the loop crash. 
    // thus, we collect them in a list and iterate over that list instead.
    NSMutableArray *listeners = [[NSMutableArray alloc] init];
    getChildEventListeners(self, event.type, listeners);
    [event setTarget:self];
    [listeners makeObjectsPerformSelector:@selector(dispatchEvent:) withObject:event];
    [listeners release];
}

- (void)dealloc 
{
    // 'self' is becoming invalid; thus, we have to remove any references to it.    
    [mChildren makeObjectsPerformSelector:@selector(setParent:) withObject:nil];
    [mChildren release];
    [mClipRect release];
    [super dealloc];
}

#pragma mark NSFastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf 
                                    count:(NSUInteger)len
{
    return [mChildren countByEnumeratingWithState:state objects:stackbuf count:len];
}

@end
