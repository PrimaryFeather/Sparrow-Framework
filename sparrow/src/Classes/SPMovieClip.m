//
//  SPMovieClip.m
//  Sparrow
//
//  Created by Daniel Sperl on 01.05.10.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPMovieClip.h"
#import "SPMacros.h"

// --- class implementation ------------------------------------------------------------------------

@implementation SPMovieClip
{
    NSMutableArray *mTextures;
    NSMutableArray *mSounds;
    NSMutableArray *mDurations;
    
    double mDefaultFrameDuration;
    double mTotalTime;
    double mCurrentTime;
    BOOL mLoop;
    BOOL mPlaying;
    int mCurrentFrame;
}

@synthesize loop = mLoop;
@synthesize isPlaying = mPlaying;
@synthesize currentFrame = mCurrentFrame;
@synthesize totalTime = mTotalTime;
@synthesize currentTime = mCurrentTime;

- (id)initWithFrame:(SPTexture *)texture fps:(float)fps
{
    if ((self = [super initWithTexture:texture]))
    {
        mDefaultFrameDuration = 1.0f / fps;
        mLoop = YES;
        mPlaying = YES;
        mTotalTime = 0.0;
        mCurrentTime = 0.0;
        mCurrentFrame = 0;
        mTextures = [[NSMutableArray alloc] init];
        mSounds = [[NSMutableArray alloc] init];
        mDurations = [[NSMutableArray alloc] init];        
        [self addFrameWithTexture:texture];
    }
    return self;
}

- (id)initWithFrames:(NSArray *)textures fps:(float)fps
{
    if (textures.count == 0)
        [NSException raise:SP_EXC_INVALID_OPERATION format:@"empty texture array"];
        
    self = [self initWithFrame:textures[0] fps:fps];
        
    if (self && textures.count > 1)
        for (int i=1; i<textures.count; ++i)
            [self addFrameWithTexture:textures[i] atIndex:i];
    
    return self;
}

- (id)initWithTexture:(SPTexture *)texture
{
    return [self initWithFrame:texture fps:10];
}

- (void)addFrameWithTexture:(SPTexture *)texture
{
    [self addFrameWithTexture:texture atIndex:self.numFrames];
}

- (void)addFrameWithTexture:(SPTexture *)texture duration:(double)duration
{
    [self addFrameWithTexture:texture duration:duration atIndex:self.numFrames];
}

- (void)addFrameWithTexture:(SPTexture *)texture duration:(double)duration sound:(SPSoundChannel *)sound
{
    [self addFrameWithTexture:texture duration:duration sound:sound atIndex:self.numFrames];
}

- (void)addFrameWithTexture:(SPTexture *)texture atIndex:(int)frameID
{
    [self addFrameWithTexture:texture duration:mDefaultFrameDuration atIndex:frameID];
}

- (void)addFrameWithTexture:(SPTexture *)texture duration:(double)duration atIndex:(int)frameID
{
    [self addFrameWithTexture:texture duration:duration sound:nil atIndex:frameID];
}

- (void)addFrameWithTexture:(SPTexture *)texture duration:(double)duration
                      sound:(SPSoundChannel *)sound atIndex:(int)frameID
{
    mTotalTime += duration;
    [mTextures insertObject:texture atIndex:frameID];
    [mDurations insertObject:@(duration) atIndex:frameID];
    [mSounds insertObject:(sound ? sound : [NSNull null]) atIndex:frameID];
}

- (void)removeFrameAtIndex:(int)frameID
{
    mTotalTime -= [self durationAtIndex:frameID];
    [mTextures removeObjectAtIndex:frameID];
    [mDurations removeObjectAtIndex:frameID];
    [mSounds removeObjectAtIndex:frameID];
}

- (void)setTexture:(SPTexture *)texture atIndex:(int)frameID
{
    mTextures[frameID] = texture;
}

- (void)setSound:(SPSoundChannel *)sound atIndex:(int)frameID
{
    mSounds[frameID] = sound ? sound : [NSNull null];
}

- (void)setDuration:(double)duration atIndex:(int)frameID
{
    mTotalTime -= [self durationAtIndex:frameID];
    mDurations[frameID] = @(duration);
    mTotalTime += duration;
}

- (SPTexture *)textureAtIndex:(int)frameID
{
    return mTextures[frameID];    
}

- (SPSoundChannel *)soundAtIndex:(int)frameID
{
    id sound = mSounds[frameID];
    if ([NSNull class] != [sound class]) return sound;
    else return nil;
}

- (double)durationAtIndex:(int)frameID
{
    return [mDurations[frameID] doubleValue];
}

- (void)setFps:(float)fps
{
    float newFrameDuration = (fps == 0.0f ? INT_MAX : 1.0 / fps);
	float acceleration = newFrameDuration / mDefaultFrameDuration;
    mCurrentTime *= acceleration;
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
    return mTextures.count;
}

- (void)play
{
    mPlaying = YES;    
}

- (void)pause
{
    mPlaying = NO;
}

- (void)stop
{
    mPlaying = NO;
    self.currentFrame = 0;
}

- (void)updateCurrentFrame
{
    self.texture = mTextures[mCurrentFrame];
}

- (void)playCurrentSound
{
    id sound = mSounds[mCurrentFrame];
    if ([NSNull class] != [sound class])                    
        [sound play];
}

- (void)setCurrentFrame:(int)frameID
{
    mCurrentFrame = frameID;
    mCurrentTime = 0.0;
    
    for (int i=0; i<frameID; ++i)
        mCurrentTime += [mDurations[i] doubleValue];
    
    [self updateCurrentFrame];
}

- (BOOL)isPlaying
{
    if (mPlaying)
        return mLoop || mCurrentTime < mTotalTime;
    else
        return NO;
}

- (BOOL)isComplete
{
    return !mLoop && mCurrentTime >= mTotalTime;
}

+ (id)movieWithFrame:(SPTexture *)texture fps:(float)fps
{
    return [[self alloc] initWithFrame:texture fps:fps];
}

+ (id)movieWithFrames:(NSArray *)textures fps:(float)fps
{
    return [[self alloc] initWithFrames:textures fps:fps];
}

#pragma mark SPAnimatable

- (void)advanceTime:(double)seconds
{    
    if (mLoop && mCurrentTime == mTotalTime) mCurrentTime = 0.0;    
    if (!mPlaying || seconds == 0.0 || mCurrentTime == mTotalTime) return;    
    
    int i = 0;
    double durationSum = 0.0;
    double previousTime = mCurrentTime;
    double restTime = mTotalTime - mCurrentTime;
    double carryOverTime = seconds > restTime ? seconds - restTime : 0.0;
    mCurrentTime = MIN(mTotalTime, mCurrentTime + seconds);            
       
    for (NSNumber *frameDuration in mDurations)
    {
        double fd = [frameDuration doubleValue];
        if (durationSum + fd >= mCurrentTime)            
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
    
    if (previousTime < mTotalTime && mCurrentTime == mTotalTime)
        [self dispatchEventWithType:SP_EVENT_TYPE_COMPLETED];
    
    [self advanceTime:carryOverTime];
}

@end