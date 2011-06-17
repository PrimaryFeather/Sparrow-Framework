//
//  SPJuggler.m
//  Sparrow
//
//  Created by Daniel Sperl on 09.05.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPJuggler.h"
#import "SPAnimatable.h"
#import "SPDelayedInvocation.h"

@implementation SPJuggler

@synthesize elapsedTime = mElapsedTime;

- (id)init
{    
    if ((self = [super init]))
    {        
        mObjects = [[NSMutableArray alloc] init];
        mElapsedTime = 0.0;
    }
    return self;
}

- (BOOL)isComplete
{
    return NO;
}

- (void)advanceTime:(double)seconds
{
    mElapsedTime += seconds;
    
    // we need work with a copy, since user-code could modify the collection during the enumeration
    for (id<SPAnimatable> object in [NSArray arrayWithArray:mObjects])
    {
        [object advanceTime:seconds];        
        if (object.isComplete) [self removeObject:object];
    }    
}
 
- (void)addObject:(id<SPAnimatable>)object
{
    if (object)
        [mObjects addObject:object];    
}

- (void)removeObject:(id<SPAnimatable>)object
{
    [mObjects removeObject:object];
}

- (void)removeAllObjects
{
    [mObjects removeAllObjects];
}

- (void)removeTweensWithTarget:(id)object
{
    [self removeObjectsWithTarget:object];
}

- (void)removeObjectsWithTarget:(id)object
{
    SEL targetSel = @selector(target);
    NSMutableArray *remainingObjects = [[NSMutableArray alloc] init];
    
    for (id currentObject in mObjects)
    {
        if (![currentObject respondsToSelector:targetSel] || ![[currentObject target] isEqual:object])
            [remainingObjects addObject:currentObject];     
    }
    
    [mObjects release];
    mObjects = remainingObjects;
}

- (id)delayInvocationAtTarget:(id)target byTime:(double)time
{
    SPDelayedInvocation *delayedInvoc = [SPDelayedInvocation invocationWithTarget:target delay:time];
    [self addObject:delayedInvoc];    
    return delayedInvoc;    
}

+ (SPJuggler *)juggler
{
    return [[[SPJuggler alloc] init] autorelease];
}

- (void)dealloc
{
    [mObjects release];
    [super dealloc];
}

@end
