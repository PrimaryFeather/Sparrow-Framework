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
    SPPoint *point = [SPPoint pointWithX:mGlobalX y:mGlobalY];
    SPMatrix *transformationMatrix = [mTarget.root transformationMatrixToSpace:space];
    return [transformationMatrix transformPoint:point];
}

- (SPPoint*)previousLocationInSpace:(SPDisplayObject*)space
{
    SPPoint *point = [SPPoint pointWithX:mPreviousGlobalX y:mPreviousGlobalY];
    SPMatrix *transformationMatrix = [mTarget.root transformationMatrixToSpace:space];
    return [transformationMatrix transformPoint:point];
}

- (void)dealloc
{
    [mTarget release];
    [super dealloc];
}

@end

// -------------------------------------------------------------------------------------------------

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

