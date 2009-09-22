//
//  SPDisplayObjectContainer.m
//  Sparrow
//
//  Created by Daniel Sperl on 15.03.09.
//  Copyright 2009 Incognitek. All rights reserved.
//

#import "SPDisplayObjectContainer.h"
#import "SPEnterFrameEvent.h"
#import "SPDisplayObject_Internal.h"
#import "SPMakros.h"

// --- private interface ---------------------------------------------------------------------------

@interface SPDisplayObjectContainer ()

- (void)dispatchEventOnChildren:(SPEvent*)event;

@end

// --- class implementation ------------------------------------------------------------------------

@implementation SPDisplayObjectContainer

- (id)init
{    
    if ([[self class] isEqual:[SPDisplayObjectContainer class]]) 
    { 
        [NSException raise:SP_EXC_ABSTRACT_CLASS 
                    format:@"Attempting to instantiate SPDisplayObjectContainer directly."];
        [self release]; 
        return nil; 
    }
    
    if (self = [super init]) 
    {
        mChildren = [[NSMutableArray alloc] init];
        [self addEventListener:@selector(dispatchEventOnChildren:) atObject:self 
                       forType:SP_EVENT_TYPE_ADDED_TO_STAGE];
        [self addEventListener:@selector(dispatchEventOnChildren:) atObject:self
                       forType:SP_EVENT_TYPE_REMOVED_FROM_STAGE];
    }
    
    return self;
}


#pragma mark -

- (void)addChild:(SPDisplayObject *)child
{
    [self addChild:child atIndex:self.numChildren];
}

- (void)addChild:(SPDisplayObject *)child atIndex:(int)index
{
    [child retain];
    [child removeFromParent];
    [mChildren insertObject:child atIndex:index];    
    child.parent = self;
    
    [child dispatchEvent:[SPEvent eventWithType:SP_EVENT_TYPE_ADDED]];
    if (self.stage)
        [child dispatchEvent:[SPEvent eventWithType:SP_EVENT_TYPE_ADDED_TO_STAGE]];
    
    [child release];
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
            if ([currentChild isEqual: child]) return YES;
        }
    }
    
    return NO;
}

- (SPDisplayObject *)childAtIndex:(int)index
{
    return [mChildren objectAtIndex:index];
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
    if (childIndex == SP_NOT_FOUND)
        [NSException raise:SP_EXC_NOT_RELATED format:@"Object is not a child of this container"];
    else 
        [self removeChildAtIndex:childIndex];
}

- (void)removeChildAtIndex:(int)index
{
    if (index >= 0 && index < self.numChildren)
    {
        SPDisplayObject *child = [[mChildren objectAtIndex:index] retain];
        [mChildren removeObjectAtIndex:index];
        child.parent = nil;        
        
        [child dispatchEvent:[SPEvent eventWithType:SP_EVENT_TYPE_REMOVED]];
        if (self.stage) 
            [child dispatchEvent:[SPEvent eventWithType:SP_EVENT_TYPE_REMOVED_FROM_STAGE]];        
        
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
    if (index1 < 0 || index1 >= self.numChildren || index2 < 0 || index2 >= self.numChildren)
        [NSException raise:SP_EXC_INVALID_OPERATION format:@"invalid child indices"];
    [mChildren exchangeObjectAtIndex:index1 withObjectAtIndex:index2];
}

- (int)numChildren
{
    return [mChildren count];
}

#pragma mark -

- (void)dispatchEventOnChildren:(SPEvent*)event
{
    for (SPDisplayObject *child in mChildren)
        [child dispatchEvent:event];
}

- (SPRectangle*)boundsInSpace:(SPDisplayObject*)targetCoordinateSpace
{    
    int numChildren = self.numChildren;

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
    if (isTouch && (!self.isVisible || !self.isTouchable)) 
        return nil;
    
    for (int i=self.numChildren-1; i>=0; --i) // front to back!
    {
        SPDisplayObject *child = [mChildren objectAtIndex:i];
        SPMatrix *transformationMatrix = [self transformationMatrixToSpace:child];
        SPPoint  *transformedPoint = [transformationMatrix transformPoint:localPoint];
        SPDisplayObject *target = [child hitTestPoint:transformedPoint forTouch:isTouch];
        if (target) return target;
    }
    
    return nil;
}

#pragma mark -

- (void)dealloc 
{    
    [mChildren release];
    [self removeEventListenersAtObject:self forType:SP_EVENT_TYPE_ADDED_TO_STAGE];
    [self removeEventListenersAtObject:self forType:SP_EVENT_TYPE_REMOVED_FROM_STAGE];
    [super dealloc];
}

#pragma mark NSFastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf 
                                    count:(NSUInteger)len
{
    return [mChildren countByEnumeratingWithState:state objects:stackbuf count:len];
}

@end
