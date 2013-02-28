//
//  SPTween.m
//  Sparrow
//
//  Created by Daniel Sperl on 09.05.09.
//  Copyright 2011 Gamua. All rights reserved.
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
{
    id mTarget;
    SEL mTransition;
    IMP mTransitionFunc;
    NSMutableArray *mProperties;
    
    double mTotalTime;
    double mCurrentTime;
    double mDelay;
    
    int mRepeatCount;
    double mRepeatDelay;
    BOOL mReverse;
    int mCurrentCycle;
    
    SPCallbackBlock mOnStart;
    SPCallbackBlock mOnUpdate;
    SPCallbackBlock mOnRepeat;
    SPCallbackBlock mOnComplete;
}

@synthesize totalTime = mTotalTime;
@synthesize currentTime = mCurrentTime;
@synthesize delay = mDelay;
@synthesize target = mTarget;
@synthesize repeatCount = mRepeatCount;
@synthesize repeatDelay = mRepeatDelay;
@synthesize reverse = mReverse;
@synthesize onStart = mOnStart;
@synthesize onUpdate = mOnUpdate;
@synthesize onRepeat = mOnRepeat;
@synthesize onComplete = mOnComplete;

- (id)initWithTarget:(id)target time:(double)time transition:(NSString*)transition
{
    if ((self = [super init]))
    {
        mTarget = target;
        mTotalTime = MAX(0.0001, time); // zero is not allowed
        mCurrentTime = 0;
        mDelay = 0;
        mProperties = [[NSMutableArray alloc] init];
        mRepeatCount = 1;
        mCurrentCycle = -1;
        mReverse = NO;

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
}

- (void)moveToX:(float)x y:(float)y
{
    [self animateProperty:@"x" targetValue:x];
    [self animateProperty:@"y" targetValue:y];
}

- (void)scaleTo:(float)scale
{
    [self animateProperty:@"scaleX" targetValue:scale];
    [self animateProperty:@"scaleY" targetValue:scale];
}

- (void)fadeTo:(float)alpha
{
    [self animateProperty:@"alpha" targetValue:alpha];
}

- (void)advanceTime:(double)time
{
    if (time == 0.0 || (mRepeatCount == 1 && mCurrentTime == mTotalTime))
        return; // nothing to do
    else if ((mRepeatCount == 0 || mRepeatCount > 1) && mCurrentTime == mTotalTime)
        mCurrentTime = 0.0;
    
    double previousTime = mCurrentTime;
    double restTime = mTotalTime - mCurrentTime;
    double carryOverTime = time > restTime ? time - restTime : 0.0;    
    mCurrentTime = MIN(mTotalTime, mCurrentTime + time);
    BOOL isStarting = mCurrentCycle < 0 && previousTime <= 0 && mCurrentTime > 0;

    if (mCurrentTime <= 0) return; // the delay is not over yet

    if (isStarting)
    {
        mCurrentCycle++;
        if (mOnStart) mOnStart();
    }
    
    float ratio = mCurrentTime / mTotalTime;
    BOOL reversed = mReverse && (mCurrentCycle % 2 == 1);
    FnPtrTransition transFunc = (FnPtrTransition) mTransitionFunc;
    Class transClass = [SPTransitions class];
    
    for (SPTweenedProperty *prop in mProperties)
    {
        if (isStarting) prop.startValue = prop.currentValue;
        float transitionValue = reversed ? transFunc(transClass, mTransition, 1.0 - ratio) :
                                           transFunc(transClass, mTransition, ratio);
        prop.currentValue = prop.startValue + prop.delta * transitionValue;
    }
    
    if (mOnUpdate) mOnUpdate();
    
    if (previousTime < mTotalTime && mCurrentTime >= mTotalTime)
    {
        if (mRepeatCount == 0 || mRepeatCount > 1)
        {
            mCurrentTime = -mRepeatDelay;
            mCurrentCycle++;
            if (mRepeatCount > 1) mRepeatCount--;
            if (mOnRepeat) mOnRepeat();
        }
        else
        {
            [self dispatchEventWithType:SP_EVENT_TYPE_REMOVE_FROM_JUGGLER];
            if (mOnComplete) mOnComplete();
        }
    }
    
    if (carryOverTime)
        [self advanceTime:carryOverTime];
}

- (NSString*)transition
{
    NSString *selectorName = NSStringFromSelector(mTransition);
    return [selectorName substringToIndex:selectorName.length - [TRANS_SUFFIX length]];
}

- (BOOL)isComplete
{
    return mCurrentTime >= mTotalTime && mRepeatCount == 1;
}

- (void)setDelay:(double)delay
{
    mCurrentTime = mCurrentTime + mDelay - delay;
    mDelay = delay;
}

+ (id)tweenWithTarget:(id)target time:(double)time transition:(NSString*)transition
{
    return [[self alloc] initWithTarget:target time:time transition:transition];
}

+ (id)tweenWithTarget:(id)target time:(double)time
{
    return [[self alloc] initWithTarget:target time:time];
}

@end
