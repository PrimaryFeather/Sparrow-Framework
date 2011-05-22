//
//  SoundScene.m
//  Demo
//
//  Created by Daniel Sperl on 28.05.10.
//  Copyright 2011 Gamua. All rights reserved.
//

#import "SoundScene.h"

#define FONTNAME @"Helvetica-Bold"

@implementation SoundScene

- (id)init
{
    if ((self = [super init]))
    {
        // notice these lines in 'DemoAppDelegate!'
        // [SPAudioEngine start];
        // [SPAudioEngine stop];
        
        // Create music channel:
        
        SPSound *music = [SPSound soundWithContentsOfFile:@"music.aifc"];        
        mMusicChannel = [[music createChannel] retain];
        mMusicChannel.loop = YES;
        
        SPSound *sound = [SPSound soundWithContentsOfFile:@"sound0.caf"];
        mSoundChannel = [[sound createChannel] retain];
        [mSoundChannel addEventListener:@selector(onSoundCompleted:) atObject:self
                                forType:SP_EVENT_TYPE_SOUND_COMPLETED];
        
        SPTexture *buttonTexture = [SPTexture textureWithContentsOfFile:@"button_square.png"];
        
        // music control
        
        SPTextField *musicLabel = [SPTextField textFieldWithText:@"Background Music (compressed)"];
        musicLabel.x = 30;
        musicLabel.y = 55;
        musicLabel.fontName = FONTNAME;
        musicLabel.width = 260;
        musicLabel.height = 30;
        [self addChild:musicLabel];

        SPButton *playButton = [SPButton buttonWithUpState:buttonTexture text:@">"];
        playButton.x = 80;
        playButton.y = 105;
        playButton.fontName = FONTNAME;        
        [playButton addEventListener:@selector(onPlayButtonTriggered:) atObject:self
                             forType:SP_EVENT_TYPE_TRIGGERED];        
        [self addChild:playButton];

        SPButton *pauseButton = [SPButton buttonWithUpState:buttonTexture text:@"||"];
        pauseButton.x = 140;
        pauseButton.y = playButton.y;
        pauseButton.fontName = FONTNAME;
        [pauseButton addEventListener:@selector(onPauseButtonTriggered:) atObject:self
                              forType:SP_EVENT_TYPE_TRIGGERED];        
        [self addChild:pauseButton];
        
        SPButton *stopButton = [SPButton buttonWithUpState:buttonTexture text:@"[]"];
        stopButton.x = 200;
        stopButton.y = playButton.y;
        stopButton.fontName = FONTNAME;
        [stopButton addEventListener:@selector(onStopButtonTriggered:) atObject:self
                             forType:SP_EVENT_TYPE_TRIGGERED];        
        [self addChild:stopButton];       
        
        // simple sound button
        
        SPTextField *simpleLabel = [SPTextField textFieldWithText:@"Simple"];
        simpleLabel.x = 60;
        simpleLabel.y = 180;
        simpleLabel.fontName = FONTNAME;
        simpleLabel.width = 80;
        simpleLabel.height = 30;
        [self addChild:simpleLabel];
        
        SPButton *simpleButton = [SPButton buttonWithUpState:buttonTexture text:@">"];
        simpleButton.x = 80;
        simpleButton.y = 230;
        simpleButton.fontName = FONTNAME;
        [simpleButton addEventListener:@selector(onSimpleButtonTriggered:) atObject:self
                               forType:SP_EVENT_TYPE_TRIGGERED];  
        [self addChild:simpleButton];
        
        // channel sound button
        
        SPTextField *channelLabel = [SPTextField textFieldWithText:@"Channel"];
        channelLabel.x = 180;
        channelLabel.y = simpleLabel.y;
        channelLabel.fontName = FONTNAME;
        channelLabel.width = 80;
        channelLabel.height = 30;
        [self addChild:channelLabel];
        
        mChannelButton = [SPButton buttonWithUpState:buttonTexture text:@">"];
        mChannelButton.x = 200;
        mChannelButton.y = simpleButton.y;
        mChannelButton.fontName = FONTNAME;
        [mChannelButton addEventListener:@selector(onChannelButtonTriggered:) atObject:self
                                forType:SP_EVENT_TYPE_TRIGGERED];  
        [self addChild:mChannelButton];
        
        // volume buttons
        
        SPTextField *volumeLabel = [SPTextField textFieldWithText:@"Master Volume"];
        volumeLabel.x = 30;
        volumeLabel.y = 305;
        volumeLabel.fontName = FONTNAME;
        volumeLabel.width = 260;
        volumeLabel.height = 30;
        [self addChild:volumeLabel];
        
        SPButton *volume0Button = [SPButton buttonWithUpState:buttonTexture text:@"0"];
        volume0Button.x = 80;
        volume0Button.y = 355;
        volume0Button.fontName = FONTNAME;
        [volume0Button addEventListener:@selector(onVolume0ButtonTriggered:) atObject:self
                                forType:SP_EVENT_TYPE_TRIGGERED]; 
        [self addChild:volume0Button];
        
        SPButton *volume50Button = [SPButton buttonWithUpState:buttonTexture text:@"50"];
        volume50Button.x = 140;
        volume50Button.y = volume0Button.y;
        volume50Button.fontName = FONTNAME;
        [volume50Button addEventListener:@selector(onVolume50ButtonTriggered:) atObject:self
                                forType:SP_EVENT_TYPE_TRIGGERED]; 
        [self addChild:volume50Button];
        
        SPButton *volume100Button = [SPButton buttonWithUpState:buttonTexture text:@"100"];
        volume100Button.x = 200;
        volume100Button.y = volume0Button.y;
        volume100Button.fontName = FONTNAME;
        [volume100Button addEventListener:@selector(onVolume100ButtonTriggered:) atObject:self
                                forType:SP_EVENT_TYPE_TRIGGERED]; 
        [self addChild:volume100Button];        
        
        
        #if TARGET_IPHONE_SIMULATOR

        // on the simulator, there is a weird bug: if you start the music, then stop it,
        // then the other sounds won't work any more -- until you restart (or pause) the music
        // again. On the device, it works fine. I suppose this is a bug in the OpenAL implementation
        // of the simulator.        
        
        NSString *description = @"Warning: the simulator might not reproduce sound accurately.";        
        SPTextField *infoText = [SPTextField textFieldWithWidth:300 height:50 text:description
                                                       fontName:@"Verdana" fontSize:13 color:0x0];    
        infoText.x = infoText.y = 10;
        infoText.vAlign = SPVAlignTop;        
        [self addChild:infoText];        
        
        #endif
    }
    return self;
}

- (void)onPlayButtonTriggered:(SPEvent *)event
{    
    [mMusicChannel play];
}

- (void)onPauseButtonTriggered:(SPEvent *)event
{    
    [mMusicChannel pause];
}

- (void)onStopButtonTriggered:(SPEvent *)event
{    
    [mMusicChannel stop];
}

- (void)onSimpleButtonTriggered:(SPEvent *)event
{
    // that's the easiest way to play a sound!
    [[SPSound soundWithContentsOfFile:@"sound1.caf"] play];
}

- (void)onChannelButtonTriggered:(SPEvent *)event
{
    // we change the color to demonstrate the "onCompleted" feature
    mChannelButton.fontColor = 0xff0000;
    [mSoundChannel play];
}

- (void)onVolume0ButtonTriggered:(SPEvent *)event
{
    [SPAudioEngine setMasterVolume:0.0f];
}

- (void)onVolume50ButtonTriggered:(SPEvent *)event
{
    [SPAudioEngine setMasterVolume:0.5f];
}

- (void)onVolume100ButtonTriggered:(SPEvent *)event
{
    [SPAudioEngine setMasterVolume:1.0f];
}

- (void)onSoundCompleted:(SPEvent *)event
{
    mChannelButton.fontColor = 0x0;
}

- (void)dealloc
{
    // This is really IMPORTANT: either stop the sound or remove the event listener!!!
    // Otherwise the sound continues to play, and when it completes, the event handler will
    // already be garbage -> crash!    
    [mSoundChannel stop];
    
    // The music channel has no event listener attached, so technically, this call is not 
    // necessary. But it's a good habit to stop any sound before releasing it (see above.)
    [mMusicChannel stop];
    
    [mSoundChannel release];
    [mMusicChannel release];    
    [super dealloc];
}

@end
