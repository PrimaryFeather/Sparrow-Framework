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

@interface SPAudioEngine : NSObject

+ (void)start:(SPAudioSessionCategory)category;
+ (void)start;
+ (void)stop;

+ (float)masterVolume;
+ (void)setMasterVolume:(float)volume;

@end
