//
//  SPTween.h
//  Sparrow
//
//  Created by Daniel Sperl on 09.05.09.
//  Copyright 2009 Incognitek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPEventDispatcher.h"
#import "SPAnimatable.h"
#import "SPTransitions.h"

#define SP_EVENT_TYPE_TWEEN_STARTED @"tweenStarted"
#define SP_EVENT_TYPE_TWEEN_UPDATED @"tweenUpdated"
#define SP_EVENT_TYPE_TWEEN_COMPLETED @"tweenCompleted"

@interface SPTween : SPEventDispatcher <SPAnimatable>
{
  @private
    id mTarget;
    NSInvocation *mTransitionInvocation;
    NSMutableArray *mProperties;
    NSMutableArray *mInvocations;
    NSMutableArray *mStartValues;
    NSMutableArray *mEndValues;
    
    double mTotalTime;
    double mCurrentTime;
    double mDelay;
    BOOL mRoundToInt;
}

@property (nonatomic, readonly) id target;
@property (nonatomic, readonly) NSString *transition;
@property (nonatomic, assign)   BOOL roundToInt;
@property (nonatomic, readonly) double time;
@property (nonatomic, assign)   double delay;

- (id)initWithTarget:(id)target time:(double)time transition:(NSString*)transition;
- (id)initWithTarget:(id)target time:(double)time;

- (void)animateProperty:(NSString*)property targetValue:(float)value;

+ (SPTween*)tweenWithTarget:(id)target time:(double)time transition:(NSString*)transition;
+ (SPTween*)tweenWithTarget:(id)target time:(double)time;

@end
