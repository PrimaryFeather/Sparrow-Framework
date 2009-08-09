//
//  SPTween.m
//  Sparrow
//
//  Created by Daniel Sperl on 09.05.09.
//  Copyright 2009 Incognitek. All rights reserved.
//

#import "SPTween.h"
#import "SPTransitions.h"
#import "SPNSExtensions.h"
#import "SPMakros.h"

#define TRANS_SUFFIX @"WithDelta:ratio:"

// --- private interface ---------------------------------------------------------------------------

@interface SPTween ()

- (void)setTransition:(NSString*)transition;

@end


// --- class implementation ------------------------------------------------------------------------

@implementation SPTween

@synthesize totalTime = mTotalTime;
@synthesize currentTime = mCurrentTime;
@synthesize target = mTarget;
@synthesize roundToInt = mRoundToInt;

- (id)initWithTarget:(id)target time:(double)time transition:(NSString*)transition
{
    if (self = [super init])
    {
        mTarget = [target retain];
        mTotalTime = time;
        mCurrentTime = 0;
        mRoundToInt = NO;
        mInvocations = [[NSMutableArray alloc] init];
        mStartValues = [[NSMutableArray alloc] init];
        mEndValues = [[NSMutableArray alloc] init];
        self.transition = transition;        
    }
    return self;
}

- (id)initWithTarget:(id)target time:(double)time
{
    return [self initWithTarget:target time:time transition:SP_TRANSITION_LINEAR];
}

- (void)addProperty:(NSString*)property targetValue:(float)value
{
    SEL getter = NSSelectorFromString(property);
    SEL setter = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:", 
                                       [[property substringToIndex:1] uppercaseString], 
                                       [property substringFromIndex:1]]);
 
    if (![mTarget respondsToSelector:getter] || ![mTarget respondsToSelector:setter])
        [NSException raise:SP_EXC_INVALID_OPERATION format:@"property not found or readonly: '%@'", property];
    
    // find the start value    
    float startValue = 0.0f;
    
    NSInvocation *getterInv = [NSInvocation invocationWithTarget:mTarget selector:getter]; 
    [getterInv invoke];
    [getterInv getReturnValue:&startValue];
    
    // create invocation vor setter
    NSInvocation *setterInv = [NSInvocation invocationWithTarget:mTarget selector:setter];    
    [mInvocations addObject:setterInv];    
    
    // save start- & endValue
    [mStartValues addObject:[NSNumber numberWithFloat:startValue]];
    [mEndValues addObject:[NSNumber numberWithFloat:value]];    
}

- (void)setCurrentTime:(double)currentTime
{
    double previousTime = mCurrentTime;    
    mCurrentTime = currentTime;

    if (mCurrentTime < 0 || previousTime >= mTotalTime) return;
    
    float ratio = mCurrentTime / mTotalTime;    
    for (int i=0; i<mStartValues.count; ++i)
    {
        float startValue = [[mStartValues objectAtIndex:i] floatValue];
        float endValue = [[mEndValues objectAtIndex:i] floatValue];
        float delta = endValue - startValue;
        float transitionValue = 0;
        [mTransitionInvocation setArgument:&delta atIndex:2];
        [mTransitionInvocation setArgument:&ratio atIndex:3];        
        [mTransitionInvocation invoke];
        [mTransitionInvocation getReturnValue:&transitionValue];        
        
        float currentValue = startValue + transitionValue;        
        if (mRoundToInt) currentValue = roundf(currentValue);
    
        NSInvocation *setterInv = [mInvocations objectAtIndex:i];
        [setterInv setArgument:&currentValue atIndex:2];
        [setterInv invoke];        
    }
    
    if (previousTime <= 0 && mCurrentTime > 0)
        [self dispatchEvent:[SPEvent eventWithType:SP_EVENT_TYPE_TWEEN_STARTED]];
    else if (previousTime > 0 && mCurrentTime < mTotalTime)
        [self dispatchEvent:[SPEvent eventWithType:SP_EVENT_TYPE_TWEEN_UPDATED]];    
    else if (previousTime < mTotalTime && mCurrentTime >= mTotalTime)
        [self dispatchEvent:[SPEvent eventWithType:SP_EVENT_TYPE_TWEEN_COMPLETED]];
}

- (void)setTransition:(NSString*)transition
{
    [mTransitionInvocation release];        
    NSString *transMethod = [transition stringByAppendingString:TRANS_SUFFIX];
    SEL transSelector = NSSelectorFromString(transMethod);    
    if (![SPTransitions respondsToSelector:transSelector])
        [NSException raise:SP_EXC_INVALID_OPERATION format:@"transition not found: '%@'", transition];
    mTransitionInvocation = [[NSInvocation invocationWithTarget:[SPTransitions class] 
                                                      selector:transSelector] retain];
}

- (NSString*)transition
{
    NSString *selectorName = NSStringFromSelector(mTransitionInvocation.selector);
    return [selectorName substringToIndex:selectorName.length - [TRANS_SUFFIX length]];
}

+ (SPTween*)tweenWithTarget:(id)target time:(double)time transition:(NSString*)transition
{
    return [[[SPTween alloc] initWithTarget:target time:time transition:transition] autorelease];
}

+ (SPTween*)tweenWithTarget:(id)target time:(double)time
{
    return [[[SPTween alloc] initWithTarget:target time:time]autorelease];
}

- (void)dealloc
{
    [mTarget release];
    [mTransitionInvocation release];
    [mInvocations release];
    [mStartValues release];
    [mEndValues release];
    [super dealloc];
}

@end
