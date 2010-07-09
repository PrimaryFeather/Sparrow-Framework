//
//  SPALSoundChannel.m
//  Sparrow
//
//  Created by Daniel Sperl on 28.05.10.
//  Copyright 2010 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPALSoundChannel.h"
#import "SPALSound.h"
#import "SPAudioEngine.h"
#import "SPMacros.h"

#import <QuartzCore/QuartzCore.h> // for CACurrentMediaTime
#import <OpenAL/al.h>
#import <OpenAL/alc.h>

// --- private interface ---------------------------------------------------------------------------

@interface SPALSoundChannel ()

- (void)scheduleSoundCompletedEvent;
- (void)revokeSoundCompletedEvent;

@end

// --- class implementation ------------------------------------------------------------------------

@implementation SPALSoundChannel

@synthesize volume = mVolume;
@synthesize loop = mLoop;

- (id)init
{
    [self release];
    return nil;
}

- (id)initWithSound:(SPALSound *)sound
{
    if (self = [super init])
    {
        mSound = [sound retain];
        mVolume = 1.0f;
        mLoop = NO;
        mInterrupted = NO;
        mStartMoment = 0.0;
        mPauseMoment = 0.0;
        
        alGenSources(1, &mSourceID);
        alSourcei(mSourceID, AL_BUFFER, sound.bufferID);
        ALenum errorCode = alGetError();
        if (errorCode != AL_NO_ERROR)
        {
            NSLog(@"Could not create OpenAL source (%x)", errorCode);
            [self release];
            return nil;
        }         
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];        
        [nc addObserver:self selector:@selector(onInterruptionBegan:) 
            name:SP_NOTIFICATION_AUDIO_INTERRUPTION_BEGAN object:nil];
        [nc addObserver:self selector:@selector(onInterruptionEnded:) 
            name:SP_NOTIFICATION_AUDIO_INTERRUPTION_ENDED object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];    
    alSourceStop(mSourceID);
    alSourcei(mSourceID, AL_BUFFER, 0);
    alDeleteSources(1, &mSourceID);
    mSourceID = 0;
    [mSound release];
    [super dealloc];
}

- (void)play
{
    if (!self.isPlaying)
    {
        double now = CACurrentMediaTime();
        
        if (mPauseMoment != 0.0) // paused
        {
            mStartMoment += now - mPauseMoment;
            mPauseMoment = 0.0;
        }
        else // stopped 
        {
            mStartMoment = now;
        }
        
        [self scheduleSoundCompletedEvent];        
        alSourcePlay(mSourceID);
    }
}

- (void)pause
{
    if (self.isPlaying)
    {    
        [self revokeSoundCompletedEvent];
        mPauseMoment = CACurrentMediaTime();
        alSourcePause(mSourceID);
    }
}

- (void)stop
{
    [self revokeSoundCompletedEvent];
    mStartMoment = mPauseMoment = 0.0;
    alSourceStop(mSourceID);
}

- (BOOL)isPlaying
{
    ALint state;
    alGetSourcei(mSourceID, AL_SOURCE_STATE, &state);
    return state == AL_PLAYING;
}

- (BOOL)isPaused
{
    ALint state;
    alGetSourcei(mSourceID, AL_SOURCE_STATE, &state);
    return state == AL_PAUSED;
}

- (BOOL)isStopped
{
    ALint state;
    alGetSourcei(mSourceID, AL_SOURCE_STATE, &state);
    return state == AL_STOPPED;
}

- (void)setLoop:(BOOL)value
{
    if (value != mLoop)
    {
        mLoop = value;
        alSourcei(mSourceID, AL_LOOPING, mLoop);        
    }    
}

- (void)setVolume:(float)value
{
    if (value != mVolume)
    {
        mVolume = value;
        alSourcef(mSourceID, AL_GAIN, mVolume);        
    }
}

- (double)duration
{
    return [mSound duration];
}

- (void)scheduleSoundCompletedEvent
{
    if (mStartMoment != 0.0)
    {    
        double remainingTime = mSound.duration - (CACurrentMediaTime() - mStartMoment);        
        [self revokeSoundCompletedEvent];
        if (remainingTime >= 0.0)
        {        
            [self performSelector:@selector(dispatchSoundCompletedEvent) withObject:nil
                       afterDelay:remainingTime];   
        }
    }
}

- (void)revokeSoundCompletedEvent
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self 
        selector:@selector(dispatchSoundCompletedEvent) object:nil];
}

- (void)dispatchSoundCompletedEvent
{
    if (!mLoop)
    {
        SPEvent *event = [[SPEvent alloc] initWithType:SP_EVENT_TYPE_SOUND_COMPLETED];
        [self dispatchEvent:event];
        [event release];
    }
}

- (void)onInterruptionBegan:(NSNotification *)notification
{        
    if (self.isPlaying)
    {
        [self revokeSoundCompletedEvent];
        mInterrupted = YES;
        mPauseMoment = CACurrentMediaTime();
    }
}

- (void)onInterruptionEnded:(NSNotification *)notification
{
    if (mInterrupted)
    {
        mStartMoment += CACurrentMediaTime() - mPauseMoment;
        mPauseMoment = 0.0;
        mInterrupted = NO;
        [self scheduleSoundCompletedEvent];
    }
}

@end
