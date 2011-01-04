//
//  SPTween.m
//  Sparrow
//
//  Created by Daniel Sperl on 09.05.09.
//  Copyright 2009 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPTween.h"
#import "SPTransitions.h"
#import "SPTweenedProperty.h"
#import "SPMacros.h"

#define TRANS_SUFFIX  @":"

typedef float (*FnPtrTransition) (id, SEL, float);

@implementation SPTween

@synthesize time = mTotalTime;
@synthesize delay = mDelay;
@synthesize target = mTarget;
@synthesize loop = mLoop;

- (id)initWithTarget:(id)target time:(double)time transition:(NSString*)transition
{
    if (self = [super init])
    {
        mTarget = [target retain];
        mTotalTime = MAX(0.0001, time); // zero is not allowed
        mCurrentTime = 0;
        mDelay = 0;
        mProperties = [[NSMutableArray alloc] init];        
        mLoop = SPLoopTypeNone;
        mInvertTransition = NO;
        
        // create function pointer for transition
        NSString *transMethod = [transition stringByAppendingString:TRANS_SUFFIX];
        mTransition = NSSelectorFromString(transMethod);    
        if (![SPTransitions respondsToSelector:mTransition])
            [NSException raise:SP_EXC_INVALID_OPERATION 
                        format:@"transition not found: '%@'", transition];
        mTransitionFunc = [SPTransitions methodForSelector:mTransition];
    }
    return self;
}

- (id)initWithTarget:(id)target time:(double)time
{
    return [self initWithTarget:target time:time transition:SP_TRANSITION_LINEAR];
}

- (void)animateProperty:(NSString*)property targetValue:(float)value
{    
    if (!mTarget) return; // tweening nil just does nothing.
    
    SPTweenedProperty *tweenedProp = [[SPTweenedProperty alloc] 
        initWithTarget:mTarget name:property endValue:value];
    [mProperties addObject:tweenedProp];
    [tweenedProp release];
}

- (void)advanceTime:(double)seconds
{
    if (seconds == 0.0) return; // nothing to do
    
    double previousTime = mCurrentTime;    
    mCurrentTime = MIN(mTotalTime, mCurrentTime + seconds);

    if (mCurrentTime < 0 || previousTime >= mTotalTime) return;

    if (previousTime <= 0 && mCurrentTime >= 0 &&
        [self hasEventListenerForType:SP_EVENT_TYPE_TWEEN_STARTED])
    {
        SPEvent *event = [[SPEvent alloc] initWithType:SP_EVENT_TYPE_TWEEN_STARTED];        
        [self dispatchEvent:event];
        [event release];        
    }   
    
    float ratio = mCurrentTime / mTotalTime;
    FnPtrTransition transFunc = (FnPtrTransition) mTransitionFunc;
    Class transClass = [SPTransitions class];
    
    for (SPTweenedProperty *prop in mProperties)
    {        
        if (previousTime <= 0 && mCurrentTime >= 0) 
            prop.startValue = prop.currentValue;

        float transitionValue = mInvertTransition ? 
            1.0f - transFunc(transClass, mTransition, 1.0f - ratio) :
            transFunc(transClass, mTransition, ratio);        
        
        prop.currentValue = prop.startValue + prop.delta * transitionValue;
    }
   
    if ([self hasEventListenerForType:SP_EVENT_TYPE_TWEEN_UPDATED])
    {
        SPEvent *event = [[SPEvent alloc] initWithType:SP_EVENT_TYPE_TWEEN_UPDATED];
        [self dispatchEvent:event];    
        [event release];
    }
    
    if (previousTime < mTotalTime && mCurrentTime >= mTotalTime)
    {
		if (mLoop == SPLoopTypeRepeat)
		{
			for (SPTweenedProperty *prop in mProperties)
				prop.currentValue = prop.startValue;

			mCurrentTime = 0;
		}
		else if (mLoop == SPLoopTypeReverse)
		{
			for (SPTweenedProperty *prop in mProperties)
            {
                prop.currentValue = prop.endValue; // since tweens not necessarily end with endValue
                prop.endValue = prop.startValue;
                mInvertTransition = !mInvertTransition;
            }

			mCurrentTime = 0;
		}        
        else if ([self hasEventListenerForType:SP_EVENT_TYPE_TWEEN_COMPLETED])
        {
            SPEvent *event = [[SPEvent alloc] initWithType:SP_EVENT_TYPE_TWEEN_COMPLETED];
            [self dispatchEvent:event];
            [event release];
        }
    }
}

- (NSString*)transition
{
    NSString *selectorName = NSStringFromSelector(mTransition);
    return [selectorName substringToIndex:selectorName.length - [TRANS_SUFFIX length]];
}

- (BOOL)isComplete
{
    return mCurrentTime >= mTotalTime && mLoop == SPLoopTypeNone;
}

- (void)setDelay:(double)delay
{
    mCurrentTime = mCurrentTime + mDelay - delay;
    mDelay = delay;
}

+ (SPTween*)tweenWithTarget:(id)target time:(double)time transition:(NSString*)transition
{
    return [[[SPTween alloc] initWithTarget:target time:time transition:transition] autorelease];
}

+ (SPTween*)tweenWithTarget:(id)target time:(double)time
{
    return [[[SPTween alloc] initWithTarget:target time:time] autorelease];
}

- (void)dealloc
{
    [mTarget release];
    [mProperties release];
    [super dealloc];
}

@end
