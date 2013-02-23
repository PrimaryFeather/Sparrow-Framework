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
#import "SPEventDispatcher.h"

@implementation SPJuggler
{
    NSMutableArray *mObjects;
    double mElapsedTime;
}

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

- (void)advanceTime:(double)seconds
{
    mElapsedTime += seconds;
    
    // we need work with a copy, since user-code could modify the collection during the enumeration
    for (id<SPAnimatable> object in [NSArray arrayWithArray:mObjects])
        [object advanceTime:seconds];
}

- (void)addObject:(id<SPAnimatable>)object
{
    if (object && ![mObjects containsObject:object])
    {
        [mObjects addObject:object];
        
        if ([(id)object isKindOfClass:[SPEventDispatcher class]])
            [(SPEventDispatcher *)object addEventListener:@selector(onRemove:) atObject:self
                                                  forType:SP_EVENT_TYPE_REMOVE_FROM_JUGGLER];
    }
}

- (void)onRemove:(SPEvent *)event
{
    [self removeObject:(id<SPAnimatable>)event.target];
}

- (void)removeObject:(id<SPAnimatable>)object
{
    [mObjects removeObject:object];
    
    if ([(id)object isKindOfClass:[SPEventDispatcher class]])
        [(SPEventDispatcher *)object removeEventListenersAtObject:self
                                     forType:SP_EVENT_TYPE_REMOVE_FROM_JUGGLER];
}

- (void)removeAllObjects
{
    for (id object in mObjects)
    {
        if ([(id)object isKindOfClass:[SPEventDispatcher class]])
            [(SPEventDispatcher *)object removeEventListenersAtObject:self
                                         forType:SP_EVENT_TYPE_REMOVE_FROM_JUGGLER];
    }
    
    [mObjects removeAllObjects];
}

- (void)removeObjectsWithTarget:(id)object
{
    SEL targetSel = @selector(target);
    NSMutableArray *remainingObjects = [[NSMutableArray alloc] init];
    
    for (id currentObject in mObjects)
    {
        if (![currentObject respondsToSelector:targetSel] || ![[currentObject target] isEqual:object])
            [remainingObjects addObject:currentObject];
        else if ([(id)currentObject isKindOfClass:[SPEventDispatcher class]])
            [(SPEventDispatcher *)currentObject removeEventListenersAtObject:self
                                                forType:SP_EVENT_TYPE_REMOVE_FROM_JUGGLER];
    }
    
    mObjects = remainingObjects;
}

- (BOOL)containsObject:(id<SPAnimatable>)object
{
    return [mObjects containsObject:object];
}

- (id)delayInvocationAtTarget:(id)target byTime:(double)time
{
    SPDelayedInvocation *delayedInvoc = [SPDelayedInvocation invocationWithTarget:target delay:time];
    [self addObject:delayedInvoc];    
    return delayedInvoc;    
}

+ (SPJuggler *)juggler
{
    return [[SPJuggler alloc] init];
}

@end
