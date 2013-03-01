//
//  SPTouch.m
//  Sparrow
//
//  Created by Daniel Sperl on 01.05.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPTouch.h"
#import "SPTouch_Internal.h"
#import "SPDisplayObject.h"
#import "SPPoint.h"

@implementation SPTouch
{
    double mTimestamp;
    float mGlobalX;
    float mGlobalY;
    float mPreviousGlobalX;
    float mPreviousGlobalY;
    int mTapCount;
    SPTouchPhase mPhase;
    SPDisplayObject *__weak mTarget;
}

@synthesize timestamp = mTimestamp;
@synthesize globalX = mGlobalX;
@synthesize globalY = mGlobalY;
@synthesize previousGlobalX = mPreviousGlobalX;
@synthesize previousGlobalY = mPreviousGlobalY;
@synthesize tapCount = mTapCount;
@synthesize phase = mPhase;
@synthesize target = mTarget;

- (id)init
{
    return [super init];
}

- (SPPoint*)locationInSpace:(SPDisplayObject*)space
{
    SPMatrix *transformationMatrix = [mTarget.root transformationMatrixToSpace:space];
    return [transformationMatrix transformPointWithX:mGlobalX y:mGlobalY];
}

- (SPPoint*)previousLocationInSpace:(SPDisplayObject*)space
{
    SPMatrix *transformationMatrix = [mTarget.root transformationMatrixToSpace:space];
    return [transformationMatrix transformPointWithX:mPreviousGlobalX y:mPreviousGlobalY];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"[SPTouch: globalX=%.1f, globalY=%.1f, phase=%d, tapCount=%d]",
            mGlobalX, mGlobalY, mPhase, mTapCount];
}

@end

// -------------------------------------------------------------------------------------------------

@implementation SPTouch (Internal)

// TODO: why not synthesize these properties?

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
    if (mTarget != target)
        mTarget = target;
}

+ (SPTouch*)touch
{
    return [[SPTouch alloc] init];
}

@end

