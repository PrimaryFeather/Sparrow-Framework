//
//  SPAVSound.h
//  Sparrow
//
//  Created by Daniel Sperl on 29.05.10.
//  Copyright 2010 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "SPSound.h"

/** ------------------------------------------------------------------------------------------------

 The SPAVSound class is a concrete implementation of SPSound that uses AVAudioPlayer internally. 
 
 Don't create instances of this class manually. Use [SPSound initWithContentsOfFile:] instead.
 
 */

@interface SPAVSound : SPSound 
{
  @private
    NSData *mSoundData;
    double mDuration;
}

/// --------------------
/// @name Initialization
/// --------------------

/// Initializes a sound with the contents of a file and the known duration.
- (id)initWithContentsOfFile:(NSString *)path duration:(double)duration;

/// -------------
/// @name methods
/// -------------

/// Creates an AVAudioPlayer object from the sound.
- (AVAudioPlayer *)createPlayer;

@end
