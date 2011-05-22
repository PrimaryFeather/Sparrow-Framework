//
//  SPSound.h
//  Sparrow
//
//  Created by Daniel Sperl on 14.11.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>

@class SPSoundChannel;

/** ------------------------------------------------------------------------------------------------

 The SPSound class contains audio data that is ready for playback.
 
 Just as SPTexture contains image data, SPSound contains audio data. It loads audio files in
 different formats and keeps them in memory (or streams them if the format supports it).
 
 You can use SPSound to play a sound directly, but this won't give you much control. 
 If you want to control the playback and volume of the sound, you you have to create an 
 SPSoundChannel first (via `createChannel`).
 
 If you need to play a sound repeatedly, create the SPSound object only once and keep it in 
 memory. Then call play or create a channel when you want to play the sound. 
 
 Your sounds will automatically be paused when the application 
 is disrupted (e.g. by a phone call), and will continue playback where they stopped.
 
 Behind the scenes, the SPSound class will choose the appropriate technology for playback: 
 uncompressed files will use OpenAL, compressed sound will be handled by Apple's AVAudioPlayer. 
 You don't have to care. 
 
------------------------------------------------------------------------------------------------- */

@interface SPSound : NSObject 
{
  @private
    NSMutableSet *mPlayingChannels;
}

/// ------------------
/// @name Initializers
/// ------------------

/// Initializes a sound 
- (id)initWithContentsOfFile:(NSString *)path;

/// Factory method.
+ (SPSound *)soundWithContentsOfFile:(NSString *)path;

/// -------------
/// @name Methods
/// -------------

/// Starts playback of the sound.
- (void)play;

/// Creates an audio channel that gives you more control over playback. Don't forget to retain it!
- (SPSoundChannel *)createChannel;

/// ----------------
/// @name Properties
/// ----------------

/// The duration of the sound in seconds.
@property (nonatomic, readonly) double duration;

@end
