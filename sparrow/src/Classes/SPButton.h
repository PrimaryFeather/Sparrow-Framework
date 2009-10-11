//
//  SPButton.h
//  Sparrow
//
//  Created by Daniel Sperl on 13.07.09.
//  Copyright 2009 Incognitek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPDisplayObjectContainer.h"

@class SPTexture;
@class SPImage;
@class SPTextField;
@class SPSprite;

#define SP_EVENT_TYPE_TRIGGERED @"triggered"

@interface SPButton : SPDisplayObjectContainer
{
  @private    
    SPTexture *mUpState;
    SPTexture *mDownState;
    
    SPSprite *mContents;
    SPImage *mBackground;
    SPTextField *mTextField;
    SPRectangle *mTextBounds;
  
    float mScaleWhenDown;
    float mAlphaWhenDisabled;
    BOOL mEnabled;
    BOOL mIsDown;
}

@property (nonatomic, assign) float scaleWhenDown;
@property (nonatomic, assign) float alphaWhenDisabled;
@property (nonatomic, assign) BOOL  isEnabled;
@property (nonatomic, copy)   NSString *text;
@property (nonatomic, copy)   NSString *fontName;
@property (nonatomic, assign) float fontSize;
@property (nonatomic, assign) uint fontColor;
@property (nonatomic, retain) SPTexture *upState;
@property (nonatomic, retain) SPTexture *downState;
@property (nonatomic, copy)   SPRectangle *textBounds;

- (id)initWithUpState:(SPTexture*)upState downState:(SPTexture*)downState; // designated initializer
- (id)initWithUpState:(SPTexture*)upState text:(NSString*)text;
- (id)initWithUpState:(SPTexture*)upState;

+ (SPButton*)buttonWithUpState:(SPTexture*)upState downState:(SPTexture*)downState;
+ (SPButton*)buttonWithUpState:(SPTexture*)upState text:(NSString*)text;
+ (SPButton*)buttonWithUpState:(SPTexture*)upState;

@end
