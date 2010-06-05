//
//  SPAVSoundChannel.h
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

#import "SPSoundChannel.h"
#import "SPAVSound.h"

@interface SPAVSoundChannel : SPSoundChannel <AVAudioPlayerDelegate> 
{
  @private
    SPAVSound *mSound;
    AVAudioPlayer *mPlayer;
    BOOL mPaused;
    float mVolume;
}

- (id)initWithSound:(SPAVSound *)sound;

@end
