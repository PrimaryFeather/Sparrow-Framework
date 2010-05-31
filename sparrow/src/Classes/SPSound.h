//
//  SPSound.h
//  Sparrow
//
//  Created by Daniel Sperl on 14.11.09.
//  Copyright 2009 Incognitek. All rights reserved.
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
