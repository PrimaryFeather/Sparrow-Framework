//
//  SPSoundChannel.h
//  Sparrow
//
//  Created by Daniel Sperl on 14.11.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>
#import "SPSound.h"
#import "SPEventDispatcher.h"

#define SP_EVENT_TYPE_SOUND_COMPLETED @"soundCompleted"

/** ------------------------------------------------------------------------------------------------

 An SPSoundChannel represents an audio source. Use this class to control sound playback.
 
 Sound channels are created with the method `[SPSound createChannel]`. They allow control over
 playback (`play`, `pause`, `stop`) and properties as the volume or if the sound should loop.
 
 Furthermore, it will dispatch events of type `SP_EVENT_TYPE_SOUND_COMPLETED` when the sound
 is finished.
 
 Before releasing a channel, it is a good habit to call `stop` or to remove any event listeners.
 Otherwise, an event may be dispatched to an object that was already released, causing a crash.

------------------------------------------------------------------------------------------------- */

@interface SPSoundChannel : SPEventDispatcher 

/// -------------
/// @name Methods
/// -------------

/// Starts playback.
- (void)play;

/// Stops playback. Sound will start from the beginning on `play`.
- (void)stop;

/// Pauses the sound. Call `play` again to continue.
- (void)pause;

/// ----------------
/// @name Properties
/// ----------------

/// Indicates if the sound is currently playing.
@property (nonatomic, readonly) BOOL isPlaying;

/// Indicates if the sound is currently paused.
@property (nonatomic, readonly) BOOL isPaused;

/// Indicates if the sound was stopped.
@property (nonatomic, readonly) BOOL isStopped;

/// The duration of the sound in seconds.
@property (nonatomic, readonly) double duration;

/// The volume of the sound. Range: [0.0 - 1.0]
@property (nonatomic, assign) float volume;

/// Indicates if the sound should loop. Looping sounds don't dispatch SOUND_COMPLETED events.
@property (nonatomic, assign) BOOL loop;

@end
