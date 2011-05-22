//
//  SPButton.h
//  Sparrow
//
//  Created by Daniel Sperl on 13.07.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>
#import "SPDisplayObjectContainer.h"

@class SPTexture;
@class SPImage;
@class SPTextField;
@class SPSprite;

#define SP_EVENT_TYPE_TRIGGERED @"triggered"

/** ------------------------------------------------------------------------------------------------

 An SPButton is a simple button composed of an image and, optionally, text.
 
 You can pass a texture for up- and downstate of the button. If you do not provide a down stage,
 the button is simply scaled a little when it is touched.
 
 In addition, you can overlay a text on the button. To customize the text, almost the same options
 as those of SPTextField are provided. In addition, you can move the text to a certain position
 with the help of the `textBounds` property.
 
 To react on touches on a button, there is special event type: `SP_EVENT_TYPE_TRIGGERED`. Use
 this event instead of normal touch events - that way, the button will behave just like standard
 iOS interface buttons.
 
------------------------------------------------------------------------------------------------- */

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

/// ------------------
/// @name Initializers
/// ------------------

/// Initializes a button with textures for up- and down-state. _Designated Initializer_.
- (id)initWithUpState:(SPTexture*)upState downState:(SPTexture*)downState;

/// Initializes a button with an up state texture and text.
- (id)initWithUpState:(SPTexture*)upState text:(NSString*)text;

/// Initializes a button only with an up state.
- (id)initWithUpState:(SPTexture*)upState;

/// Factory method.
+ (SPButton*)buttonWithUpState:(SPTexture*)upState downState:(SPTexture*)downState;

/// Factory method.
+ (SPButton*)buttonWithUpState:(SPTexture*)upState text:(NSString*)text;

/// Factory method.
+ (SPButton*)buttonWithUpState:(SPTexture*)upState;

/// ----------------
/// @name Properties
/// ----------------

/// The scale factor of the button on touch. Per default, a button with a down state texture won't scale.
@property (nonatomic, assign) float scaleWhenDown;

/// The alpha value of the button when it is disabled.
@property (nonatomic, assign) float alphaWhenDisabled;

/// Indicates if the button can be triggered.
@property (nonatomic, assign) BOOL  enabled;

/// The text that is displayed on the button.
@property (nonatomic, copy)   NSString *text;

/// The name of the font displayed on the button. May be a system font or a registered bitmap font.
@property (nonatomic, copy)   NSString *fontName;

/// The size of the font.
@property (nonatomic, assign) float fontSize;

/// The color of the font.
@property (nonatomic, assign) uint fontColor;

/// The texture that is displayed when the button is not being touched.
@property (nonatomic, retain) SPTexture *upState;

/// The texture that is displayed while the button is touched.
@property (nonatomic, retain) SPTexture *downState;

/// The bounds of the textfield on the button. Allows moving the text to a custom position.
@property (nonatomic, copy)   SPRectangle *textBounds;

@end
