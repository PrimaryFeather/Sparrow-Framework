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

typedef enum 
{
    SPTouchPhaseBegan,
    SPTouchPhaseMoved,
    SPTouchPhaseStationary,
    SPTouchPhaseEnded,
    SPTouchPhaseCancelled,
} SPTouchPhase;

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

@property (nonatomic, readonly) double timestamp;
@property (nonatomic, readonly) float globalX;
@property (nonatomic, readonly) float globalY;
@property (nonatomic, readonly) float previousGlobalX;
@property (nonatomic, readonly) float previousGlobalY;
@property (nonatomic, readonly) int tapCount;
@property (nonatomic, readonly) SPTouchPhase phase;
@property (nonatomic, readonly) SPDisplayObject *target;

- (id)init;
- (SPPoint*)locationInSpace:(SPDisplayObject*)space;
- (SPPoint*)previousLocationInSpace:(SPDisplayObject*)space;

@end
