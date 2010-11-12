//
//  SPDisplayObjectContainer.m
//  Sparrow
//
//  Created by Daniel Sperl on 15.03.09.
//  Copyright 2009 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPDisplayObjectContainer.h"
#import "SPEnterFrameEvent.h"
#import "SPDisplayObject_Internal.h"
#import "SPMacros.h"

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
    
    if (self = [super init]) 
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
            [child dispatchEventOnChildren:addedToStageEvent];
            [addedToStageEvent release];
        }
        
        [child release];
    }
    else [NSException raise:SP_EXC_INDEX_OUT_OF_BOUNDS format:@"Invalid child index"]; 
}

- (BOOL)containsChild:(SPDisplayObject *)child
{
    if ([self isEqual:child]) return YES; 
    
    for (SPDisplayObject *currentChild in mChildren)
    {
        if ([currentChild isKindOfClass:[SPDisplayObjectContainer class]])
        {
            if ([(SPDisplayObjectContainer *)currentChild containsChild:child]) return YES;
        }
        else
        {
            if (currentChild == child) return YES;
        }
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
        SPDisplayObject *child = [[mChildren objectAtIndex:index] retain];        

        SPEvent *remEvent = [[SPEvent alloc] initWithType:SP_EVENT_TYPE_REMOVED];    
        [child dispatchEvent:remEvent];
        [remEvent release];    
        
        if (self.stage)
        {
            SPEvent *remFromStageEvent = [[SPEvent alloc] initWithType:SP_EVENT_TYPE_REMOVED_FROM_STAGE];
            [child dispatchEventOnChildren:remFromStageEvent];
            [remFromStageEvent release];
        }        
        
        [mChildren removeObjectAtIndex:index];
        child.parent = nil; 
        
        [child release];
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

- (void)removeAllChildren
{
    for (int i=mChildren.count-1; i>=0; --i)
        [self removeChildAtIndex:i];
}

- (int)numChildren
{
    return [mChildren count];
}

- (SPRectangle*)boundsInSpace:(SPDisplayObject*)targetCoordinateSpace
{    
    int numChildren = [mChildren count];

    if (numChildren == 0) 
        return [SPRectangle rectangleWithX:0 y:0 width:0 height:0];
    else if (numChildren == 1) 
        return [[mChildren objectAtIndex:0] boundsInSpace:targetCoordinateSpace];
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
        return [SPRectangle rectangleWithX:minX y:minY width:maxX-minX height:maxY-minY];
    }
}

- (SPDisplayObject*)hitTestPoint:(SPPoint*)localPoint forTouch:(BOOL)isTouch;
{
    if (isTouch && (!self.visible || !self.touchable)) 
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

- (void)dispatchEventOnChildren:(SPEvent *)event
{
    // the event listeners might modify the display tree, which could make the loop crash. 
    // thus, we collect them in a list and iterate over that list instead.
    
    NSMutableArray *listeners = [[NSMutableArray alloc] init];
    getChildEventListeners(self, event.type, listeners);        
    [listeners makeObjectsPerformSelector:@selector(dispatchEvent:) withObject:event];
    [listeners release];
}

- (void)dealloc 
{    
    // 'self' is becoming invalid; thus, we have to remove any references to it.    
    [mChildren makeObjectsPerformSelector:@selector(setParent:) withObject:nil];
    [mChildren release];
    [super dealloc];
}

#pragma mark NSFastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf 
                                    count:(NSUInteger)len
{
    return [mChildren countByEnumeratingWithState:state objects:stackbuf count:len];
}

@end
