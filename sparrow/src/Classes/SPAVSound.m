//
//  SPAVSound.m
//  Sparrow
//
//  Created by Daniel Sperl on 29.05.10.
//  Copyright 2010 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPAVSound.h"
#import "SPAVSoundChannel.h"

@implementation SPAVSound

@synthesize duration = mDuration;

- (id)init
{
    [self release];
    return nil;
}

- (id)initWithContentsOfFile:(NSString *)path duration:(double)duration
{
    if (self = [super init])
    {
        NSString *fullPath = [path isAbsolutePath] ? 
            path : [[NSBundle mainBundle] pathForResource:path ofType:nil];
        mSoundData = [[NSData alloc] initWithContentsOfMappedFile:fullPath];
        mDuration = duration;
    }
    return self;
}

- (void)dealloc
{
    [mSoundData release];
    [super dealloc];
}

- (SPSoundChannel *)createChannel
{
    return [[[SPAVSoundChannel alloc] initWithSound:self] autorelease];    
}

- (AVAudioPlayer *)createPlayer
{
    NSError *error = nil;    
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithData:mSoundData error:&error];
    if (error) NSLog(@"Could not create AVAudioPlayer: %@", [error description]);    
    return [player autorelease];	
}

@end
