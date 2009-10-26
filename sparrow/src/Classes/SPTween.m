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
#import "SPMacros.h"
#import "SPTweenedProperty.h"

#define TRANS_SUFFIX  @"WithDelta:ratio:"
#define UNKNOWN_VALUE FLT_MAX

// --- private interface ---------------------------------------------------------------------------

@interface SPTween ()

- (void)setTransition:(NSString*)transition;

@end


// --- class implementation ------------------------------------------------------------------------

@implementation SPTween

@synthesize time = mTotalTime;
@synthesize delay = mDelay;
@synthesize target = mTarget;

- (id)initWithTarget:(id)target time:(double)time transition:(NSString*)transition
{
    if (self = [super init])
    {
        mTarget = [target retain];
        mTotalTime = MAX(0.0001, time); // zero is not allowed
        mCurrentTime = 0;
        mDelay = 0;
        mProperties = [[NSMutableArray alloc] init];
        self.transition = transition;        
    }
    return self;
}

- (id)initWithTarget:(id)target time:(double)time
{
    return [self initWithTarget:target time:time transition:SP_TRANSITION_LINEAR];
}

- (void)animateProperty:(NSString*)property targetValue:(float)value
{    
    SEL getter = NSSelectorFromString(property);
    SEL setter = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:", 
                                       [[property substringToIndex:1] uppercaseString], 
                                       [property substringFromIndex:1]]);
 
    if (![mTarget respondsToSelector:getter] || ![mTarget respondsToSelector:setter])
        [NSException raise:SP_EXC_INVALID_OPERATION format:@"property not found or readonly: '%@'", property];    
    
    // query argument type
    NSMethodSignature *sig = [mTarget methodSignatureForSelector:getter];
    char numericType = *[sig methodReturnType];    
    if (numericType != 'f' && numericType != 'i' && numericType != 'd')
        [NSException raise:SP_EXC_INVALID_OPERATION format:@"property not numeric: '%@'", property];
        
    // create invocations
    NSInvocation *getterInv = [NSInvocation invocationWithTarget:mTarget selector:getter];    
    NSInvocation *setterInv = [NSInvocation invocationWithTarget:mTarget selector:setter];    
    
    // save property information
    SPTweenedProperty *tweenedProp = [[SPTweenedProperty alloc] 
        initWithGetter:getterInv setter:setterInv startValue:UNKNOWN_VALUE endValue:value 
           numericType:numericType];
    
    [mProperties addObject:tweenedProp];
    [tweenedProp release];
}

- (void)advanceTime:(double)seconds
{
    double previousTime = mCurrentTime;    
    mCurrentTime = MIN(mTotalTime, mCurrentTime + seconds);

    if (mCurrentTime < 0 || previousTime >= mTotalTime) return;
    
    float ratio = mCurrentTime / mTotalTime;    
    for (SPTweenedProperty *prop in mProperties)
    {        
        if (prop.startValue == UNKNOWN_VALUE)
        {
            // The tween should use the value of the property at the moment it starts.
            // Since the start can be delayed, we have to read the value here, 
            // not in 'animateProperty:targetValue:'

            float startValue = 0.0f;
            NSInvocation *getterInv = prop.getter;
            [getterInv invoke];
            [getterInv getReturnValue:&startValue];
            prop.startValue = startValue;
        }        
        
        float startValue = prop.startValue;
        float delta = prop.endValue - startValue;
        float transitionValue = 0;

        [mTransitionInvocation setArgument:&delta atIndex:2];
        [mTransitionInvocation setArgument:&ratio atIndex:3];        
        [mTransitionInvocation invoke];
        [mTransitionInvocation getReturnValue:&transitionValue];        
        
        NSInvocation *setterInv = prop.setter;        

        char numericType = prop.numericType;
        if (numericType == 'i')
        {
            int currentValue = (int)(startValue + transitionValue);
            [setterInv setArgument:&currentValue atIndex:2];
        }
        else if (numericType == 'd')
        {
            double currentValue = (double)(startValue + transitionValue);
            [setterInv setArgument:&currentValue atIndex:2];            
        }        
        else
        {
            float currentValue = startValue + transitionValue;
            [setterInv setArgument:&currentValue atIndex:2];
        }                
        
        [setterInv invoke];        
    }
    
    if (previousTime <= 0 && mCurrentTime > 0 &&
        [self hasEventListenerForType:SP_EVENT_TYPE_TWEEN_STARTED])
    {
        SPEvent *event = [[SPEvent alloc] initWithType:SP_EVENT_TYPE_TWEEN_STARTED];        
        [self dispatchEvent:event];
        [event release];        
    }
    
    if ([self hasEventListenerForType:SP_EVENT_TYPE_TWEEN_UPDATED])
    {
        SPEvent *event = [[SPEvent alloc] initWithType:SP_EVENT_TYPE_TWEEN_UPDATED];
        [self dispatchEvent:event];    
        [event release];
    }
    
    if (previousTime < mTotalTime && mCurrentTime >= mTotalTime &&
        [self hasEventListenerForType:SP_EVENT_TYPE_TWEEN_COMPLETED])
    {
        SPEvent *event = [[SPEvent alloc] initWithType:SP_EVENT_TYPE_TWEEN_COMPLETED];
        [self dispatchEvent:event];
        [event release];        
    }        
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

- (BOOL)isComplete
{
    return mCurrentTime >= mTotalTime;
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
    [mTransitionInvocation release];
    [mProperties release];
    [super dealloc];
}

@end
