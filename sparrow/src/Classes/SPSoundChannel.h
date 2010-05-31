//
//  SPSoundChannel.h
//  Sparrow
//
//  Created by Daniel Sperl on 14.11.09.
//  Copyright 2009 Incognitek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPSound.h"
#import "SPEventDispatcher.h"

#define SP_EVENT_TYPE_SOUND_COMPLETED @"soundCompleted"

@interface SPSoundChannel : SPEventDispatcher 

- (void)play;
- (void)stop;
- (void)pause;

@property (nonatomic, readonly) BOOL isPlaying;
@property (nonatomic, readonly) BOOL isPaused;
@property (nonatomic, readonly) BOOL isStopped;
@property (nonatomic, readonly) double duration;
@property (nonatomic, assign) float volume;
@property (nonatomic, assign) BOOL loop;

@end
