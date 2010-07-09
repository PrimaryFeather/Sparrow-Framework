//
//  SPAudioEngine.m
//  Sparrow
//
//  Created by Daniel Sperl on 14.11.09.
//  Copyright 2009 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPAudioEngine.h"

#import <AudioToolbox/AudioToolbox.h> 
#import <OpenAL/al.h>
#import <OpenAL/alc.h>

@interface SPAudioEngine ()

+ (BOOL)initAudioSession:(SPAudioSessionCategory)category;
+ (BOOL)initOpenAL;

+ (void)beginInterruption;
+ (void)endInterruption;

+ (void)postNotification:(NSString *)name object:(id)object;

@end

@implementation SPAudioEngine

// --- C functions ---

void interruptionCallback (void *inUserData, UInt32 interruptionState) 
{   
    if (interruptionState == kAudioSessionBeginInterruption)  
        [SPAudioEngine beginInterruption]; 
    else if (interruptionState == kAudioSessionEndInterruption)
        [SPAudioEngine endInterruption];      
} 

// --- static members ---

static ALCdevice  *device  = NULL;
static ALCcontext *context = NULL;
static float masterVolume = 1.0f;

// ---

- (id)init
{
    [self release];
    [NSException raise:NSGenericException format:@"Static class - do not initialize!"];        
    return nil;
}

+ (void)start:(SPAudioSessionCategory)category
{
    if (!device)
    {
        if ([SPAudioEngine initAudioSession:category])
            [SPAudioEngine initOpenAL];        
    }
}

+ (void)start
{      
    [SPAudioEngine start:SPAudioSessionCategory_SoloAmbientSound];
}

+ (void)stop
{
    alcMakeContextCurrent(NULL);
    alcDestroyContext(context);
    alcCloseDevice(device);
    
    device = NULL;
    context = NULL;
    
    AudioSessionSetActive(NO);
}

+ (BOOL)initAudioSession:(SPAudioSessionCategory)category
{
    static BOOL sessionInitialized = NO;
    OSStatus result;
    
    if (!sessionInitialized)
    {
        result = AudioSessionInitialize(NULL, NULL, interruptionCallback, NULL);
        if (result != kAudioSessionNoError)        
        {        
            NSLog(@"Could not initialize audio session: %x", result);
            return NO;
        }        
        sessionInitialized = YES;
    }
    
    UInt32 sessionCategory = category;
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,                             
                            sizeof(sessionCategory), &sessionCategory);
    
    result = AudioSessionSetActive(YES);
    if (result != kAudioSessionNoError)
    {
        NSLog(@"Could not activate audio session: %x", result);
        return NO;
    }
    
    return YES;
}

+ (BOOL)initOpenAL
{
    alGetError(); // reset any errors
    
    device = alcOpenDevice(NULL);
    if (!device)
    {
        NSLog(@"Could not open default OpenAL device");
        return NO;
    }
    
    context = alcCreateContext(device, 0);
    if (!context)
    {
        NSLog(@"Could not create OpenAL context for default device");
        return NO;
    }
    
    BOOL success = alcMakeContextCurrent(context);
    if (!success)
    {
        NSLog(@"Could not set current OpenAL context");
        return NO;
    }
    
    return YES;
}

+ (void)beginInterruption
{    
    [SPAudioEngine postNotification:SP_NOTIFICATION_AUDIO_INTERRUPTION_BEGAN object:nil];
    alcMakeContextCurrent(NULL);
    AudioSessionSetActive(NO);     
}

+ (void)endInterruption
{    
    AudioSessionSetActive(YES);    
    alcMakeContextCurrent(context);
    alcProcessContext(context);
    [SPAudioEngine postNotification:SP_NOTIFICATION_AUDIO_INTERRUPTION_ENDED object:nil];
}

+ (float)masterVolume
{
    return masterVolume;
}

+ (void)setMasterVolume:(float)volume
{       
    masterVolume = volume;
    alListenerf(AL_GAIN, volume);
    [SPAudioEngine postNotification:SP_NOTIFICATION_MASTER_VOLUME_CHANGED object:nil];
}

+ (void)postNotification:(NSString *)name object:(id)object
{
    [[NSNotificationCenter defaultCenter] postNotification:
     [NSNotification notificationWithName:name object:object]]; 
}

@end
