//
//  SPSound.h
//  Sparrow
//
//  Created by Daniel Sperl on 14.11.09.
//  Copyright 2009 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>

@class SPSoundChannel;

@interface SPSound : NSObject 
{
    NSMutableSet *mPlayingChannels;
}

- (id)initWithContentsOfFile:(NSString *)path;
- (void)play;
- (SPSoundChannel *)createChannel;

+ (SPSound *)soundWithContentsOfFile:(NSString *)path;

@property (nonatomic, readonly) double duration;

@end
