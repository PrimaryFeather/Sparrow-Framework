//
//  SPJuggler.m
//  Sparrow
//
//  Created by Daniel Sperl on 09.05.09.
//  Copyright 2009 Incognitek. All rights reserved.
//

#import "SPJuggler.h"
#import "SPAnimatable.h"
#import "SPDelayedInvocation.h"

@implementation SPJuggler

@synthesize elapsedTime = mElapsedTime;

- (id)init
{    
    if (self = [super init])
    {        
        mObjects = [[NSMutableSet alloc] init];
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
    for (id<SPAnimatable> object in [mObjects allObjects])    
    {
        [object advanceTime:seconds];        
        if (object.isComplete) [self removeObject:object];
    }    
}
 
- (void)addObject:(id<SPAnimatable>)object
{
    [mObjects addObject:object];    
}

- (void)removeObject:(id<SPAnimatable>)object
{
    [mObjects removeObject:object];
}

- (void)removeAllObjects;
{
    [mObjects removeAllObjects];
}
 
- (id)delayInvocationAtTarget:(id)target byTime:(double)time
{
    SPDelayedInvocation *delayedInvoc = [SPDelayedInvocation invocationWithTarget:target delay:time];
    [self addObject:delayedInvoc];    
    return delayedInvoc;    
}

- (void)dealloc
{
    [mObjects release];
    [super dealloc];
}

@end
