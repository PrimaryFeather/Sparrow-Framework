//
//  SPDelayedInvocation.m
//  Sparrow
//
//  Created by Daniel Sperl on 11.07.09.
//  Copyright 2009 Incognitek. All rights reserved.
//

#import "SPDelayedInvocation.h"


@implementation SPDelayedInvocation

@synthesize totalTime = mTotalTime;
@synthesize currentTime = mCurrentTime;
@synthesize target = mTarget;

- (id)initWithTarget:(id)target delay:(double)time
{
    if (self = [super init])
    {
        mTotalTime = time;
        mCurrentTime = 0;
        mTarget = [target retain];
        mInvocations = [[NSMutableSet alloc] init];
    }
    return self;
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)aSelector
{
    NSMethodSignature *sig = [[self class] instanceMethodSignatureForSelector:aSelector];
    if (sig == nil)
        sig = [mTarget methodSignatureForSelector:aSelector];
    return sig;
}

- (void)forwardInvocation:(NSInvocation*)anInvocation
{
    if ([mTarget respondsToSelector:[anInvocation selector]])
        [mInvocations addObject:anInvocation];
}

- (void)setCurrentTime:(double)currentTime
{
    double previousTime = mCurrentTime;    
    mCurrentTime = currentTime;
    
    if (previousTime < mTotalTime && mCurrentTime >= mTotalTime)
    {
        for (NSInvocation *inv in mInvocations)                    
            [inv invokeWithTarget:mTarget];
    }    
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
