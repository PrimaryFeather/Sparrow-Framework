//
//  SoundScene.h
//  Demo
//
//  Created by Daniel Sperl on 28.05.10.
//  Copyright 2010 Incognitek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface SoundScene : SPSprite <AVAudioPlayerDelegate> 
{
    SPSoundChannel *mMusicChannel;
    SPSoundChannel *mSoundChannel;
    SPButton *mChannelButton;
}


@end
