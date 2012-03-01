//
//  SPTouchEvent.h
//  Sparrow
//
//  Created by Daniel Sperl on 02.05.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>
#import "SPEvent.h"
#import "SPTouch.h"

@class SPDisplayObject;

#define SP_EVENT_TYPE_TOUCH @"touch"

/** ------------------------------------------------------------------------------------------------

 When one or more fingers touch the screen, move around or are raised, an SPTouchEvent is triggered.
 
 The event contains a list of all touches that are currently present. Each individual touch is 
 stored in an object of type "Touch". Since you are normally only interested in the touches 
 that occurred on top of certain objects, you can query the event for touches with a 
 specific target through the `touchesWithTarget:` method. In this context, the target of a 
 touch is not only the object that was touched (e.g. an SPImage), but also each of its parents - 
 e.g. the container that holds that image.
 
 Here is an example of how to react on touch events at 'self', which could be a subclass of SPSprite:

	// e.g. in 'init'
	[self addEventListener:@selector(onTouch:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
	
	// the corresponding listener:
	- (void)onTouch:(SPTouchEvent*)event
	{
 	    // query all touches that are currently moving on top of 'self'
	    NSArray *touches = [[event touchesWithTarget:self andPhase:SPTouchPhaseMoved] allObjects];
	
	    if (touches.count == 1)
	    {
	        // one finger touching
	        SPTouch *touch = [touches objectAtIndex:0];
	        SPPoint *currentPos = [touch locationInSpace:self.parent];
	        SPPoint *previousPos = [touch previousLocationInSpace:self.parent];
	        // ...
	    }
	    else if (touches.count >= 2)
	    {
	        // two fingers touching
	        // ...
	    }
	}

------------------------------------------------------------------------------------------------- */ 
 
@interface SPTouchEvent : SPEvent
{
  @private
    NSSet *mTouches;    
}

/// ------------------
/// @name Initializers
/// ------------------

/// Creates a touch event with a set of touches. _Designated Initializer_.
- (id)initWithType:(NSString*)type bubbles:(BOOL)bubbles touches:(NSSet*)touches;

/// Creates a touch event with a set of touches.
- (id)initWithType:(NSString*)type touches:(NSSet*)touches;

/// Factory method.
+ (SPTouchEvent*)eventWithType:(NSString*)type touches:(NSSet*)touches;

/// -------------
/// @name Methods
/// -------------

/// Gets a set of SPTouch objects that originated over a certain target.
- (NSSet*)touchesWithTarget:(SPDisplayObject*)target;

/// Gets a set of SPTouch objects that originated over a certain target and are in a certain phase.
- (NSSet*)touchesWithTarget:(SPDisplayObject*)target andPhase:(SPTouchPhase)phase;

/// ----------------
/// @name Properties
/// ----------------

/// All touches that are currently available.
@property (nonatomic, readonly) NSSet *touches;

/// The time the event occurred (in seconds since application launch).
@property (nonatomic, readonly) double timestamp;

@end
