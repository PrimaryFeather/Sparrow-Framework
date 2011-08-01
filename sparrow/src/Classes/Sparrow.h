//
//  Sparrow.h
//  Sparrow
//
//  Created by Daniel Sperl on 21.03.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#define SPARROW_VERSION @"1.2"


----------------------------------------------------------------------------------------------------
Attention:

Sparrow is switching the main development to the master branch, as is the common practice on git 
projects. Access to the latest release version is still possible via tags. This is done to prevent
confusion of new users. 

The development branch will stay for a while, so that existing users have the time to switch, but
eventually it will be deleted. This message is written outside of comments to generate compile 
errors that should draw your attention.

To switch to the master branch and get the latest version, open the terminal and type:

git checkout master
git pull

Sorry for the inconvenience!
----------------------------------------------------------------------------------------------------


#import "SPNSExtensions.h"
#import "SPEventDispatcher.h"
#import "SPDisplayObject.h"
#import "SPDisplayObjectContainer.h"
#import "SPQuad.h"
#import "SPImage.h"
#import "SPTextField.h"
#import "SPBitmapFont.h"
#import "SPButton.h"
#import "SPStage.h"
#import "SPSprite.h"
#import "SPCompiledSprite.h"
#import "SPMovieClip.h"
#import "SPTexture.h"
#import "SPSubTexture.h"
#import "SPRenderTexture.h"
#import "SPGLTexture.h"
#import "SPTextureAtlas.h"
#import "SPEvent.h"
#import "SPTouchEvent.h"
#import "SPEnterFrameEvent.h"
#import "SPJuggler.h"
#import "SPTransitions.h"
#import "SPTween.h"
#import "SPDelayedInvocation.h"
#import "SPRectangle.h"
#import "SPMacros.h"
#import "SPUtils.h"
#import "SPView.h"
#import "SPRenderSupport.h"
#import "SPAudioEngine.h"
#import "SPSound.h"
#import "SPSoundChannel.h"
