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

#import <Availability.h>

#ifndef __IPHONE_5_0
#warning "This project uses features only available in iOS SDK 5.0 and later."
#endif

#define SPARROW_VERSION @"2.0"

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
#import "SPMovieClip.h"
#import "SPTexture.h"
#import "SPSubTexture.h"
#import "SPRenderTexture.h"
#import "SPGLTexture.h"
#import "SPTextureAtlas.h"
#import "SPEvent.h"
#import "SPTouchEvent.h"
#import "SPEnterFrameEvent.h"
#import "SPResizeEvent.h"
#import "SPJuggler.h"
#import "SPTransitions.h"
#import "SPTween.h"
#import "SPDelayedInvocation.h"
#import "SPRectangle.h"
#import "SPMacros.h"
#import "SPUtils.h"
#import "SPViewController.h"
#import "SPOverlayView.h"
#import "SPRenderSupport.h"
#import "SPAudioEngine.h"
#import "SPSound.h"
#import "SPSoundChannel.h"
#import "SparrowClass.h"
