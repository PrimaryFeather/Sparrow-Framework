//
//  SPAudioEngine.h
//  Sparrow
//
//  Created by Daniel Sperl on 14.11.09.
//  Copyright 2009 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>

#define SP_NOTIFICATION_MASTER_VOLUME_CHANGED      @"masterVolumeChanged"
#define SP_NOTIFICATION_AUDIO_INTERRUPTION_BEGAN   @"audioInterruptionBegan"
#define SP_NOTIFICATION_AUDIO_INTERRUPTION_ENDED   @"audioInterruptionEnded"

typedef enum {
    SPAudioSessionCategory_AmbientSound     = 'ambi',
    SPAudioSessionCategory_SoloAmbientSound = 'solo',
    SPAudioSessionCategory_MediaPlayback    = 'medi',
    SPAudioSessionCategory_RecordAudio      = 'reca',
    SPAudioSessionCategory_PlayAndRecord    = 'plar',
    SPAudioSessionCategory_AudioProcessing  = 'proc'
} SPAudioSessionCategory;

/** ------------------------------------------------------------------------------------------------ 

 The SPAudioEngine prepares the system for audio playback and controls global volume.
 
 Before you play sounds, you should start an audio session. The type of the audio session
 defines how iOS will handle audio processing and how iPod music will mix with your audio.
 
 * `SPAudioSessionCategory_AmbientSound:`     iPod music mixes with your audio, audio silences on mute
 * `SPAudioSessionCategory_SoloAmbientSound:` iPod music is silenced, audio silences on mute
 * `SPAudioSessionCategory_MediaPlayback:`    iPod music is silenced, audio continues on mute
 * `SPAudioSessionCategory_RecordAudio:`      iPod music is silenced, used for audio recording
 * `SPAudioSessionCategory_PlayAndRecord:`    iPod music is silenced, for simultaneous in- and output
 * `SPAudioSessionCategory_AudioProcessing:`  For using an audio hardware codec or signal processor
 
 */

@interface SPAudioEngine : NSObject

/// -------------
/// @name Methods
/// -------------

/// Starts an audio session with a specified category. Call this at the start of your application.
+ (void)start:(SPAudioSessionCategory)category;

/// Starts an audio session with with the category 'SoloAmbientSound'.
+ (void)start;

/// Stops the audio session. Call this before the application shuts down.
+ (void)stop;

/// The master volume for all audio. Default: 1.0
+ (float)masterVolume;

/// Set the master volume for all audio. Range: [0.0 - 1.0]
+ (void)setMasterVolume:(float)volume;

@end
