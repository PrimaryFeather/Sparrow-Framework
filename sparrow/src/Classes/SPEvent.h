//
//  SPEvent.h
//  Sparrow
//
//  Created by Daniel Sperl on 27.04.09.
//  Copyright 2009 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>

#define SP_EVENT_TYPE_ADDED @"added"
#define SP_EVENT_TYPE_ADDED_TO_STAGE @"addedToStage"
#define SP_EVENT_TYPE_REMOVED @"removed"
#define SP_EVENT_TYPE_REMOVED_FROM_STAGE @"removedFromStage"

@class SPEventDispatcher;

/** ------------------------------------------------------------------------------------------------

 The SPEvent class contains data that describes an event.
 
 `SPEventDispatcher`s create instances of this class and send them to registered listeners. An event
 contains information that characterizes an event, most importantly the event type and if the event 
 bubbles. The target of an event is the object that dispatched it.
 
 For some event types, this information is sufficient; other events may need additional information 
 to be carried to the listener. 
 In that case, you can subclass SPEvent and add properties with all the information you require. 
 The SPEnterFrameEvent is an example for this practice; it adds a property about the time that
 has passed since the last frame.
 
 Furthermore, the event class contains methods that can stop the event from being processed by
 other listeners - either completely or at the next bubble stage.
 
------------------------------------------------------------------------------------------------- */

@interface SPEvent : NSObject
{
  @private
    SPEventDispatcher *mTarget;
    SPEventDispatcher *mCurrentTarget;
    NSString *mType;
    BOOL mStopsImmediatePropagation;
    BOOL mStopsPropagation;
    BOOL mBubbles;
}

/// ------------------
/// @name Initializers
/// ------------------

/// Initializes an event object that can be passed to listeners. _Designated Initializer_.
- (id)initWithType:(NSString*)type bubbles:(BOOL)bubbles;

/// Initializes a non-bubbling event.
- (id)initWithType:(NSString*)type;

/// Factory method.
+ (SPEvent*)eventWithType:(NSString*)type bubbles:(BOOL)bubbles;

/// Factory method.
+ (SPEvent*)eventWithType:(NSString*)type;

/// -------------
/// @name Methods
/// -------------

/// Prevents any other listeners from receiving the event.
- (void)stopImmediatePropagation;

/// Prevents listeners at the next bubble stage from receiving the event.
- (void)stopPropagation;

/// ----------------
/// @name Properties
/// ----------------

/// A string that identifies the event.
@property (nonatomic, readonly) NSString *type; 

/// Indicates if event will bubble.
@property (nonatomic, readonly) BOOL bubbles; 

/// The object that dispatched the event.
@property (nonatomic, readonly) SPEventDispatcher *target; 

/// The object the event is currently bubbling at.
@property (nonatomic, readonly) SPEventDispatcher *currentTarget; 

@end
