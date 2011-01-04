//
//  SPTween.h
//  Sparrow
//
//  Created by Daniel Sperl on 09.05.09.
//  Copyright 2009 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>
#import "SPEventDispatcher.h"
#import "SPAnimatable.h"
#import "SPTransitions.h"

typedef enum 
{
    SPLoopTypeNone,
    SPLoopTypeRepeat,
    SPLoopTypeReverse
} SPLoopType;

#define SP_EVENT_TYPE_TWEEN_STARTED   @"tweenStarted"
#define SP_EVENT_TYPE_TWEEN_UPDATED   @"tweenUpdated"
#define SP_EVENT_TYPE_TWEEN_COMPLETED @"tweenCompleted"

@interface SPTween : SPEventDispatcher <SPAnimatable>
{
  @private
    id mTarget;    
    SEL mTransition;
    IMP mTransitionFunc;    
    NSMutableArray *mProperties;
    
    double mTotalTime;
    double mCurrentTime;
    double mDelay;
    
    SPLoopType mLoop;
    BOOL mInvertTransition;
}

@property (nonatomic, readonly) id target;
@property (nonatomic, readonly) NSString *transition;
@property (nonatomic, readonly) double time;
@property (nonatomic, assign)   double delay;
@property (nonatomic, assign)   SPLoopType loop;

- (id)initWithTarget:(id)target time:(double)time transition:(NSString*)transition;
- (id)initWithTarget:(id)target time:(double)time;

- (void)animateProperty:(NSString*)property targetValue:(float)value;

+ (SPTween *)tweenWithTarget:(id)target time:(double)time transition:(NSString *)transition;
+ (SPTween *)tweenWithTarget:(id)target time:(double)time;

@end
