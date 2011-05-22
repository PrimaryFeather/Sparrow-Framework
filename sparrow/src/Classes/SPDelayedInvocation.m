//
//  SPDelayedInvocation.m
//  Sparrow
//
//  Created by Daniel Sperl on 11.07.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPDelayedInvocation.h"


@implementation SPDelayedInvocation

@synthesize totalTime = mTotalTime;
@synthesize currentTime = mCurrentTime;
@synthesize target = mTarget;

- (id)initWithTarget:(id)target delay:(double)time
{
    if (!target)
    {
        [self release];
        return nil;
    }    
    
    if ((self = [super init]))
    {
        mTotalTime = MAX(0.0001, time); // zero is not allowed
        mCurrentTime = 0;
        mTarget = [target retain];
        mInvocations = [[NSMutableSet alloc] init];
    }
    return self;
}

- (id)init
{
    [self release];
    return nil;
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)aSelector
{
    NSMethodSignature *sig = [[self class] instanceMethodSignatureForSelector:aSelector];
    if (!sig) sig = [mTarget methodSignatureForSelector:aSelector];
    return sig;
}

- (void)forwardInvocation:(NSInvocation*)anInvocation
{
    if ([mTarget respondsToSelector:[anInvocation selector]])
    {
        anInvocation.target = mTarget;
        [anInvocation retainArguments];
        [mInvocations addObject:anInvocation];
    }
}

- (void)advanceTime:(double)seconds
{
    self.currentTime = mCurrentTime + seconds;
}

- (void)setCurrentTime:(double)currentTime
{
    double previousTime = mCurrentTime;    
    mCurrentTime = MIN(mTotalTime, currentTime);
    
    if (previousTime < mTotalTime && mCurrentTime >= mTotalTime)    
        [mInvocations makeObjectsPerformSelector:@selector(invoke)];        
}

- (BOOL)isComplete
{
    return mCurrentTime >= mTotalTime;
}

+ (SPDelayedInvocation*)invocationWithTarget:(id)target delay:(double)time
{
    return [[[SPDelayedInvocation alloc] initWithTarget:target delay:time] autorelease];
}

- (void)dealloc
{
    [mTarget release];
    [mInvocations release];
    [super dealloc];
}

@end
