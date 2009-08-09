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

@synthesize currentTime = mCurrentTime;

- (id)init
{    
    if (self = [super init])
    {        
        mObjects = [[NSMutableSet alloc] init];
        mCurrentTime = 0.0;        
    }
    return self;
}

- (double)totalTime
{
    return DBL_MAX;
}

- (void)setCurrentTime:(double)currentTime
{
    double delta = currentTime - mCurrentTime;
    mCurrentTime = currentTime;    
    NSMutableSet *remainingObjects = [[NSMutableSet alloc] initWithCapacity:mObjects.count];
    
    for (id<SPAnimatable> object in mObjects)    
    {
        object.currentTime += delta;        
        if (object.currentTime < object.totalTime)
            [remainingObjects addObject:object];
    }
    
    [mObjects release];
    mObjects = remainingObjects;
}

- (void)addObject:(id<SPAnimatable>)object
{
    [mObjects addObject:object];    
}

- (void)removeObject:(id<SPAnimatable>)object
{
    [mObjects removeObject:object];
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
