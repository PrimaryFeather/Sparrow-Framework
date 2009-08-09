//
//  SPTouch_Internal.m
//  Sparrow
//
//  Created by Daniel Sperl on 03.05.09.
//  Copyright 2009 Incognitek. All rights reserved.
//

#import "SPTouch_Internal.h"

@implementation SPTouch (Internal)

- (void)setTimestamp:(double)timestamp
{
    mTimestamp = timestamp;
}

- (void)setGlobalX:(float)x
{
    mGlobalX = x;
}

- (void)setGlobalY:(float)y
{
    mGlobalY = y;
}

- (void)setPreviousGlobalX:(float)x
{
    mPreviousGlobalX = x;
}

- (void)setPreviousGlobalY:(float)y
{
    mPreviousGlobalY = y;
}

- (void)setTapCount:(int)tapCount
{
    mTapCount = tapCount;
}

- (void)setPhase:(SPTouchPhase)phase
{
    mPhase = phase;
}

- (void)setTarget:(SPDisplayObject*)target
{
    if (target != mTarget)
    {    
        [mTarget release];
        mTarget = [target retain];
    }
}

+ (SPTouch*)touch
{
    return [[[SPTouch alloc] init] autorelease];
}

@end
