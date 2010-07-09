//
//  SPAVSoundChannel.m
//  Sparrow
//
//  Created by Daniel Sperl on 29.05.10.
//  Copyright 2010 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPAVSoundChannel.h"
#import "SPAudioEngine.h"
#import "SPMacros.h"

@implementation SPAVSoundChannel

- (id)init
{
    [self release];
    return nil;
}

- (id)initWithSound:(SPAVSound *)sound
{
    if (self = [super init])
    {
        mVolume = 1.0f;
        mSound = [sound retain];
        mPlayer = [[sound createPlayer] retain];
        mPlayer.delegate = self;                
        [mPlayer prepareToPlay];

        [[NSNotificationCenter defaultCenter] addObserver:self 
            selector:@selector(onMasterVolumeChanged:)
                name:SP_NOTIFICATION_MASTER_VOLUME_CHANGED object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];    
    [mPlayer release];
    [mSound release];
    [super dealloc];
}

- (void)play
{
    mPaused = NO;
    [mPlayer play];
}

- (void)pause
{
    mPaused = YES;
    [mPlayer pause];
}

- (void)stop
{
    mPaused = NO;
    [mPlayer stop];
    mPlayer.currentTime = 0;
}

- (BOOL)isPlaying
{
    return mPlayer.playing;
}

- (BOOL)isPaused
{
    return mPaused && !mPlayer.playing;
}

- (BOOL)isStopped
{
    return !mPaused && !mPlayer.playing;
}

- (BOOL)loop
{
    return mPlayer.numberOfLoops < 0;
}

- (void)setLoop:(BOOL)value
{
    mPlayer.numberOfLoops = value ? -1 : 0;
}

- (float)volume
{
    return mVolume;
}

- (void)setVolume:(float)value
{
    mVolume = value;
    mPlayer.volume = value * [SPAudioEngine masterVolume];
}

- (double)duration
{
    return mPlayer.duration;
}

- (void)onMasterVolumeChanged:(NSNotification *)notification
{    
    self.volume = mVolume;    
}

#pragma mark AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{    
    [self dispatchEvent:[SPEvent eventWithType:SP_EVENT_TYPE_SOUND_COMPLETED]];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    NSLog(@"Error during sound decoding: %@", [error description]);
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
    [player pause];
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player
{
    [player play];
}

@end
