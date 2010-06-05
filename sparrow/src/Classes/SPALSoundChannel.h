//
//  SPALSoundChannel.h
//  Sparrow
//
//  Created by Daniel Sperl on 28.05.10.
//  Copyright 2010 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>
#import "SPSoundChannel.h"

@class SPALSound;

@interface SPALSoundChannel : SPSoundChannel
{
  @private
    SPALSound *mSound;
    uint mSourceID;
    float mVolume;
    BOOL mLoop;
    
    double mStartMoment;
    double mPauseMoment;
    BOOL mInterrupted;
}

- (id)initWithSound:(SPALSound *)sound;

@end
