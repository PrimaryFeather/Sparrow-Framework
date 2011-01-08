//
//  SPEnterFrameEvent.h
//  Sparrow
//
//  Created by Daniel Sperl on 30.04.09.
//  Copyright 2009 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>
#import "SPEvent.h"

#define SP_EVENT_TYPE_ENTER_FRAME @"enterFrame"

/** ------------------------------------------------------------------------------------------------

 An SPEnterFrameEvent is triggered once per frame and is dispatched to all objects in the
 display tree.
 
 It contains information about the time that has passed since the last frame. That way, you 
 can easily make animations that are independet of the frame rate, but take the passed time
 into account.
 
------------------------------------------------------------------------------------------------- */

@interface SPEnterFrameEvent : SPEvent
{
  @private 
    double mPassedTime;
}

/// ------------------
/// @name Initializers
/// ------------------

/// Initializes an enter frame event with the passed time. _Designated Initializer_.
- (id)initWithType:(NSString*)type bubbles:(BOOL)bubbles passedTime:(double)seconds;

/// Initializes an enter frame event that does not bubble (recommended).
- (id)initWithType:(NSString*)type passedTime:(double)seconds;

/// Factory method.
+ (SPEnterFrameEvent*)eventWithType:(NSString*)type passedTime:(double)seconds;

/// ----------------
/// @name Properties
/// ----------------

/// The time that has passed since the last frame (in seconds).
@property (nonatomic, readonly) double passedTime;

@end
