//
//  SPAVSoundChannel.h
//  Sparrow
//
//  Created by Daniel Sperl on 29.05.10.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "SPSoundChannel.h"
#import "SPAVSound.h"

/** ------------------------------------------------------------------------------------------------

 The SPAVSoundChannel class is a concrete implementation of SPSoundChannel that uses AVAudioPlayer 
 internally. 
 
 Don't create instances of this class manually. Use `[SPSound createChannel]` instead.
 
------------------------------------------------------------------------------------------------- */

@interface SPAVSoundChannel : SPSoundChannel <AVAudioPlayerDelegate> 
{
  @private
    SPAVSound *mSound;
    AVAudioPlayer *mPlayer;
    BOOL mPaused;
    float mVolume;
}

/// ------------------
/// @name Initializers
/// ------------------

/// Initializes a sound channel from an SPAVSound object.
- (id)initWithSound:(SPAVSound *)sound;

@end
