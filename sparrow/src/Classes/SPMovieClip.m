//
//  SPMovieClip.m
//  Sparrow
//
//  Created by Daniel Sperl on 01.05.10.
//  Copyright 2010 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPMovieClip.h"
#import "SPMacros.h"

// --- private interface ---------------------------------------------------------------------------

@interface SPMovieClip ()

- (void)updateCurrentFrame;
- (void)playCurrentSound;
- (void)checkIndex:(int)frameID;

@end


// --- class implementation ------------------------------------------------------------------------

@implementation SPMovieClip

@synthesize loop = mLoop;
@synthesize isPlaying = mPlaying;
@synthesize currentFrame = mCurrentFrame;
@synthesize duration = mTotalDuration;

- (id)initWithFrame:(SPTexture *)texture fps:(float)fps
{
    if (self = [super initWithTexture:texture])
    {
        self.fps = fps;
        mLoop = YES;
        mPlaying = YES;
        mTotalDuration = 0.0;
        mElapsedTime = 0.0;
        mCurrentFrame = 0;
        mFrames = [[NSMutableArray alloc] init];
        mSounds = [[NSMutableArray alloc] init];
        mFrameDurations = [[NSMutableArray alloc] init];        
        [self addFrame:texture];
    }
    return self;
}

- (id)initWithFrames:(NSArray *)textures fps:(float)fps
{
    if (textures.count == 0)
        [NSException raise:SP_EXC_INVALID_OPERATION format:@"empty texture array"];
        
    [self initWithFrame:[textures objectAtIndex:0] fps:fps];
    
    if (textures.count > 1)
        for (int i=1; i<textures.count; ++i)
            [self addFrame:[textures objectAtIndex:i]];
    
    return self;
}

- (id)initWithTexture:(SPTexture *)texture
{
    return [self initWithFrame:texture fps:10];
}

- (void)dealloc
{
    [mFrames release];
    [mSounds release];
    [mFrameDurations release];
    [super dealloc];
}

- (int)addFrame:(SPTexture *)texture
{
    return [self addFrame:texture withDuration:mDefaultFrameDuration];
}

- (int)addFrame:(SPTexture *)texture withDuration:(double)duration
{
    mTotalDuration += duration;    
    [mFrames addObject:texture];    
    [mFrameDurations addObject:[NSNumber numberWithDouble:duration]];
    [mSounds addObject:[NSNull null]];        
    return mFrames.count - 1;
}

- (void)insertFrame:(SPTexture *)texture atIndex:(int)frameID
{
    [self checkIndex:frameID];
    [mFrames insertObject:texture atIndex:frameID];
    [mSounds insertObject:[NSNull null] atIndex:frameID];
    [mFrameDurations insertObject:[NSNumber numberWithDouble:mDefaultFrameDuration] atIndex:frameID];
    mTotalDuration += mDefaultFrameDuration;    
}

- (void)removeFrameAtIndex:(int)frameID
{
    [self checkIndex:frameID];    
    [mFrames removeObjectAtIndex:frameID];
    [mSounds removeObjectAtIndex:frameID];
    mTotalDuration -= [self durationAtIndex:frameID];
    [mFrameDurations removeObjectAtIndex:frameID];        
}

- (void)setFrame:(SPTexture *)texture atIndex:(int)frameID
{
    [self checkIndex:frameID];    
    [mFrames replaceObjectAtIndex:frameID withObject:texture];    
}

- (void)setSound:(SPSoundChannel *)sound atIndex:(int)frameID
{
    [self checkIndex:frameID];
    id soundObject = sound;
    if (!sound) soundObject = [NSNull null];
    [mSounds replaceObjectAtIndex:frameID withObject:soundObject];    
}

- (void)setDuration:(double)duration atIndex:(int)frameID
{
    [self checkIndex:frameID];
    mTotalDuration -= [self durationAtIndex:frameID];
    [mFrameDurations replaceObjectAtIndex:frameID withObject:[NSNumber numberWithDouble:duration]];
    mTotalDuration += duration;
}

- (SPTexture *)frameAtIndex:(int)frameID
{
    [self checkIndex:frameID];
    return [mFrames objectAtIndex:frameID];    
}

- (SPSoundChannel *)soundAtIndex:(int)frameID
{
    [self checkIndex:frameID];
    
    id sound = [mSounds objectAtIndex:frameID];
    if ([NSNull class] != [sound class]) return sound;
    else return nil;
}

- (double)durationAtIndex:(int)frameID
{
    [self checkIndex:frameID];    
    return [[mFrameDurations objectAtIndex:frameID] doubleValue];
}

- (void)setFps:(float)fps
{
    float newFrameDuration = (fps == 0.0f ? INT_MAX : 1.0 / fps);
	float acceleration = newFrameDuration / mDefaultFrameDuration;
    mElapsedTime *= acceleration;
    mDefaultFrameDuration = newFrameDuration;
    
	for (int i=0; i<self.numFrames; ++i)
		[self setDuration:[self durationAtIndex:i] * acceleration atIndex:i];
}

- (float)fps
{
	return (float)(1.0 / mDefaultFrameDuration);
}

- (int)numFrames
{        
    return mFrames.count;
}

- (void)play
{
    mPlaying = YES;    
}

- (void)pause
{
    mPlaying = NO;
}

- (void)updateCurrentFrame
{
    self.texture = [mFrames objectAtIndex:mCurrentFrame];
}

- (void)playCurrentSound
{
    id sound = [mSounds objectAtIndex:mCurrentFrame];
    if ([NSNull class] != [sound class])                    
        [sound play];
}

- (void)setCurrentFrame:(int)frameID
{
    mCurrentFrame = frameID;
    mElapsedTime = 0.0;
    
    for (int i=0; i<frameID; ++i)
        mElapsedTime += [[mFrameDurations objectAtIndex:i] doubleValue];
    
    [self updateCurrentFrame];
}

- (void)checkIndex:(int)frameID
{
    if (frameID < 0 || frameID > mFrames.count)
        [NSException raise:SP_EXC_INDEX_OUT_OF_BOUNDS format:@"invalid frame index"];    
}

+ (SPMovieClip *)movieWithFrame:(SPTexture *)texture fps:(float)fps
{
    return [[[SPMovieClip alloc] initWithFrame:texture fps:fps] autorelease];
}

+ (SPMovieClip *)movieWithFrames:(NSArray *)textures fps:(float)fps
{
    return [[[SPMovieClip alloc] initWithFrames:textures fps:fps] autorelease];
}

#pragma mark SPAnimatable

- (void)advanceTime:(double)seconds
{    
    if (!mPlaying || (!mLoop && mElapsedTime == mTotalDuration)) return;
    
    double previousElapsedTime = mElapsedTime;
    mElapsedTime += seconds;       
    
    if (mLoop)
    {
        while (mElapsedTime > mTotalDuration) 
            mElapsedTime -= mTotalDuration;    
    }
    else
    {
        mElapsedTime = MIN(mTotalDuration, mElapsedTime);
    }
    
    double durationSum = 0.0;
    int i = 0;
    
    for (NSNumber *frameDuration in mFrameDurations)
    {
        double fd = [frameDuration doubleValue];
        if (durationSum + fd >= mElapsedTime)            
        {
            if (mCurrentFrame != i)
            {
                mCurrentFrame = i;
                [self updateCurrentFrame];
                [self playCurrentSound];
            }
            break;
        }
        
        ++i;
        durationSum += fd;
    }
    
    if (!mLoop && previousElapsedTime < mTotalDuration && mElapsedTime >= mTotalDuration)
        [self dispatchEvent:[SPEvent eventWithType:SP_EVENT_TYPE_MOVIE_COMPLETED]];
}

- (BOOL)isComplete
{
    return NO;
}

@end