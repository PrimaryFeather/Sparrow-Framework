//
//  SPTouch.h
//  Sparrow
//
//  Created by Daniel Sperl on 01.05.09.
//  Copyright 2009 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>

@class SPDisplayObject;
@class SPPoint;

/// SPTouchPhase describes the phases in the life-cycle of a touch.
typedef enum 
{    
    SPTouchPhaseBegan,      /// The finger just touched the screen.    
    SPTouchPhaseMoved,      /// The finger moves around.    
    SPTouchPhaseStationary, /// The finger has not moved since the last frame.    
    SPTouchPhaseEnded,      /// The finger was lifted from the screen.    
    SPTouchPhaseCancelled   /// The touch was aborted by the system (e.g. because of an AlertBox popping up)
} SPTouchPhase;

/** ------------------------------------------------------------------------------------------------

 An SPTouch contains information about the presence or movement of a finger on the screen.
 
 You receive objects of this type via an SPTouchEvent. When such an event is triggered, you can 
 query it for all touches that are currently present on the screen. One SPTouch object contains
 information about a single touch.
 
 *The phase of a touch*
 
 Each touch normally moves through the following phases in its life:
 
 `Began -> Moved -> Ended`
 
 Furthermore, a touch can enter a `Stationary` phase. That phase will not trigger an event itself, 
 but you might receive it when another touch does so. Finally, there's the `Cancelled` phase,
 which happens when the system aborts a touch (e.g. because of an AlertBox that pops up).
 
 *The position of a touch*
 
 You can get the current and last position on the screen with corresponding properties. However, 
 you'll want to have the position in a different coordinate system most of the time. 
 For this reason, there are methods that convert the current and previous touches into the local
 coordinate system of any object.
 
------------------------------------------------------------------------------------------------- */

@interface SPTouch : NSObject 
{
  @private
    double mTimestamp;
    float mGlobalX;
    float mGlobalY;
    float mPreviousGlobalX;
    float mPreviousGlobalY;    
    int mTapCount;
    SPTouchPhase mPhase;
    SPDisplayObject *mTarget;
}

/// -------------
/// @name Methods
/// -------------

/// Converts the current location of a touch to the local coordinate system of a display object.
- (SPPoint*)locationInSpace:(SPDisplayObject*)space;

/// Converts the previous location of a touch to the local coordinate system of a display object.
- (SPPoint*)previousLocationInSpace:(SPDisplayObject*)space;

/// ----------------
/// @name Properties
/// ----------------

/// The moment the event occurred (in seconds since application start).
@property (nonatomic, readonly) double timestamp;

/// The x-position of the touch in screen coordinates
@property (nonatomic, readonly) float globalX;

/// The y-position of the touch in screen coordinates
@property (nonatomic, readonly) float globalY;

/// The previous x-position of the touch in screen coordinates
@property (nonatomic, readonly) float previousGlobalX;

/// The previous y-position of the touch in screen coordinates
@property (nonatomic, readonly) float previousGlobalY;

/// The number of taps the finger made in a short amount of time. Use this to detect double-taps, etc. 
@property (nonatomic, readonly) int tapCount;

/// The current phase the touch is in.
@property (nonatomic, readonly) SPTouchPhase phase;

/// The display object at which the touch occurred.
@property (nonatomic, readonly) SPDisplayObject *target;

@end
