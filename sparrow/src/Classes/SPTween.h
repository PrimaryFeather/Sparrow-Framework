//
//  SPTween.h
//  Sparrow
//
//  Created by Daniel Sperl on 09.05.09.
//  Copyright 2011 Gamua. All rights reserved.
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

/** ------------------------------------------------------------------------------------------------
 
 An SPTween animates numeric properties of objects. It uses different transition functions to give
 the animations various styles.
 
 The primary use of this class is to do standard animations like movement, fading, rotation, etc.
 But there are no limits on what to animate; as long as the property you want to animate is numeric
 (`int`, `uint`, `float`, `double`), the tween can handle it. For a list of available Transition 
 types, see `SPTransitions`. 
 
 Here is an example of a tween that moves an object to the right, rotates it, and fades it out:
 
	SPTween *tween = [SPTween tweenWithTarget:object time:2.0 transition:SP_TRANSITION_EASE_IN_OUT];
	[tween animateProperty:@"x" targetValue:object.x + 50];
 	[tween animateProperty:@"rotation" targetValue:object.rotation + SP_D2R(45)];
 	[tween animateProperty:@"alpha" targetValue:0.0f];
 	[self.stage.juggler addObject:tween];
 
 Note that the object is added to a juggler at the end. A tween will only be executed if its
 `advanceTime:` method is executed regularly - the juggler will do that for us, and will release
 the tween when it is finished.
 
 Tweens dispatch events in certain phases of their life time:
 
 - `SP_EVENT_TYPE_TWEEN_STARTED`:   Dispatched once when the tween starts
 - `SP_EVENT_TYPE_TWEEN_UPDATED`:   Dispatched every time it is advanced
 - `SP_EVENT_TYPE_TWEEN_COMPLETED`: Dispatched when it reaches its target value (repeatedly
                                    dispatched when looping).
 
 Tweens can loop in two ways:
 
 - `SPLoopTypeRepeat`: Starts the animation from the beginning when it's finished.
 - `SPLoopTypeReverse`: Reverses the animation when it's finished, tweening back to the start value.
 
------------------------------------------------------------------------------------------------- */

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
    int mLoopCount;
}

/// ------------------
/// @name Initializers
/// ------------------

/// Initializes a tween with a target, duration (in seconds) and a transition function. 
/// _Designated Initializer_.
- (id)initWithTarget:(id)target time:(double)time transition:(NSString*)transition;

/// Initializes a tween with a target, a time (in seconds) and a linear transition 
/// (`SP_TRANSITION_LINEAR`).
- (id)initWithTarget:(id)target time:(double)time;

/// Factory method.
+ (SPTween *)tweenWithTarget:(id)target time:(double)time transition:(NSString *)transition;

/// Factory method.
+ (SPTween *)tweenWithTarget:(id)target time:(double)time;

/// -------------
/// @name Methods
/// -------------

/// Animates the property of an object to a target value. You can call this method multiple times
/// on one tween.
- (void)animateProperty:(NSString*)property targetValue:(float)value;

/// Animates the `x` and `y` properties of an object simultaneously.
- (void)moveToX:(float)x y:(float)y;

/// Animates the `scaleX` and `scaleY` properties of an object simultaneously.
- (void)scaleTo:(float)scale;

/// Animates the `alpha` property.
- (void)fadeTo:(float)alpha;

/// ----------------
/// @name Properties
/// ----------------

/// The target object that is animated.
@property (nonatomic, readonly) id target;

/// The transition method used for the animation.
@property (nonatomic, readonly) NSString *transition;

/// The total time the tween will take (in seconds).
@property (nonatomic, readonly) double time;

/// The time that has passed since the tween was started (in seconds).
@property (nonatomic, readonly) double currentTime;

/// The delay before the tween is started.
@property (nonatomic, assign)   double delay;

/// The type of loop. (Default: SPLoopTypeNone)
@property (nonatomic, assign)   SPLoopType loop;

@end
