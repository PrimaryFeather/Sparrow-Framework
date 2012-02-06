//
//  SPMovieClip.h
//  Sparrow
//
//  Created by Daniel Sperl on 01.05.10.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>
#import "SPSprite.h"
#import "SPTexture.h"
#import "SPAnimatable.h"
#import "SPImage.h"
#import "SPSoundChannel.h"

#define SP_EVENT_TYPE_MOVIE_COMPLETED @"movieCompleted"

/** ------------------------------------------------------------------------------------------------

 An SPMovieClip is a simple way to display an animation depicted by a list of textures.

 You can add the frames one by one or pass them all at once (in an array) at initialization time.
 The movie clip will have the width and height of the first frame.
 
 At initialization, you can specify the desired framerate. You can, however, manually give each
 frame a custom duration. You can also play a sound whenever a certain frame appears.
 
 The methods `play` and `pause` control playback of the movie. You will receive an event of type
 `SP_EVENT_TYPE_MOVIE_COMPLETED` when the movie finished playback. When the movie is looping,
 the event is dispatched once per loop.
 
 As any animated object, a movie clip has to be added to a juggler (or have its `advanceTime:` 
 method called regularly) to run.
 
------------------------------------------------------------------------------------------------- */
 
@interface SPMovieClip : SPImage <SPAnimatable>
{
  @private
    NSMutableArray *mFrames;
    NSMutableArray *mSounds;
    NSMutableArray *mFrameDurations;
    
    double mDefaultFrameDuration;
    double mTotalDuration;
    double mCurrentTime;
    BOOL mLoop;
    BOOL mPlaying;
    int mCurrentFrame;
}

/// ------------------
/// @name Initializers
/// ------------------

/// Initializes a movie with the first frame and the default number of frames per second. _Designated initializer_.
- (id)initWithFrame:(SPTexture *)texture fps:(float)fps; // designated initializer

/// Initializes a movie with an array of textures and the default number of frames per second.
- (id)initWithFrames:(NSArray *)textures fps:(float)fps;

/// Factory method.
+ (SPMovieClip *)movieWithFrame:(SPTexture *)texture fps:(float)fps;

/// Factory method.
+ (SPMovieClip *)movieWithFrames:(NSArray *)textures fps:(float)fps;

/// --------------------------------
/// @name Frame Manipulation Methods
/// --------------------------------

/// Adds a frame with the default duration.
- (int)addFrame:(SPTexture *)texture;

/// Adds a frame with a specified duration.
- (int)addFrame:(SPTexture *)texture withDuration:(double)duration;

/// Inserts a frame at the index specified.
- (void)insertFrame:(SPTexture *)texture atIndex:(int)frameID;

/// Removes the frame at the index specified.
- (void)removeFrameAtIndex:(int)frameID;

/// Sets the texture of a certain frame.
- (void)setFrame:(SPTexture *)texture atIndex:(int)frameID;

/// Sets the sound that will be played back when a certain frame is active.
- (void)setSound:(SPSoundChannel *)sound atIndex:(int)frameID;

/// Sets the duration of a certain frame in seconds.
- (void)setDuration:(double)duration atIndex:(int)frameID;

/// Returns the texture of a frame at a certain index.
- (SPTexture *)frameAtIndex:(int)frameID;

/// Returns the sound of a frame at a certain index.
- (SPSoundChannel *)soundAtIndex:(int)frameID;

/// Returns the duration (in seconds) of a frame at a certain index.
- (double)durationAtIndex:(int)frameID;

/// ----------------------
/// @name Playback Methods
/// ----------------------

/// Start playback. Beware that the clip has to be added to a juggler, too!
- (void)play;

/// Pause playback.
- (void)pause;

/// Stop playback. Resets currentFrame to beginning.
- (void)stop;

/// ----------------
/// @name Properties
/// ----------------

/// The number of frames of the clip.
@property (nonatomic, readonly) int numFrames;

/// The accumulated duration of all frames.
@property (nonatomic, readonly) double duration;

/// Indicates if the movie is currently playing.
@property (nonatomic, readonly) BOOL isPlaying;

/// Indicates if the movie is looping.
@property (nonatomic, assign)   BOOL loop;

/// The ID of the frame that is currently displayed.
@property (nonatomic, assign)   int currentFrame;

/// The default frames per second. Used when you add a frame without specifying a duration.
@property (nonatomic, assign)   float fps;

@end
