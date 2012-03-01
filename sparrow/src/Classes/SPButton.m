//
//  SPButton.m
//  Sparrow
//
//  Created by Daniel Sperl on 13.07.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPButton.h"
#import "SPTouchEvent.h"
#import "SPTexture.h"
#import "SPGLTexture.h"
#import "SPImage.h"
#import "SPStage.h"
#import "SPSprite.h"
#import "SPTextField.h"

// --- private interface ---------------------------------------------------------------------------

@interface SPButton()

- (void)resetContents;
- (void)createTextField;

@end


// --- class implementation ------------------------------------------------------------------------

@implementation SPButton

@synthesize scaleWhenDown = mScaleWhenDown;
@synthesize alphaWhenDisabled = mAlphaWhenDisabled;
@synthesize enabled = mEnabled;
@synthesize upState = mUpState;
@synthesize downState = mDownState;
@synthesize textBounds = mTextBounds;

#define MAX_DRAG_DIST 40

- (id)initWithUpState:(SPTexture*)upState downState:(SPTexture*)downState
{
    if ((self = [super init]))
    {
        mUpState = [upState retain];
        mDownState = [downState retain];
        mContents = [[SPSprite alloc] init];
        mBackground = [[SPImage alloc] initWithTexture:upState];
        mTextField = nil;
        mScaleWhenDown = 1.0f;
        mAlphaWhenDisabled = 0.5f;
        mEnabled = YES;
        mIsDown = NO;
        mTextBounds = [[SPRectangle alloc] initWithX:0 y:0 width:mUpState.width height:mUpState.height];
        
        [mContents addChild:mBackground];
        [self addChild:mContents];
        [self addEventListener:@selector(onTouch:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
    }
    return self;
}

- (id)initWithUpState:(SPTexture*)upState text:(NSString*)text
{
    self = [self initWithUpState:upState];
    self.text = text;
    return self;
}

- (id)initWithUpState:(SPTexture*)upState
{
    self = [self initWithUpState:upState downState:upState];
    mScaleWhenDown = 0.9f;
    return self;
}

- (id)init
{
    SPTexture *texture = [[[SPGLTexture alloc] init] autorelease];
    return [self initWithUpState:texture];   
}

- (void)onTouch:(SPTouchEvent*)touchEvent
{    
    if (!mEnabled) return;    
    SPTouch *touch = [[touchEvent touchesWithTarget:self] anyObject];
    
    if (touch.phase == SPTouchPhaseBegan && !mIsDown)
    {
        mBackground.texture = mDownState;
        mContents.scaleX = mContents.scaleY = mScaleWhenDown;
        mContents.x = (1.0f - mScaleWhenDown) / 2.0f * mBackground.width;
        mContents.y = (1.0f - mScaleWhenDown) / 2.0f * mBackground.height;
        mIsDown = YES;
    }
    else if (touch.phase == SPTouchPhaseMoved && mIsDown)
    {
        // reset button when user dragged too far away after pushing
        SPRectangle *buttonRect = [self boundsInSpace:self.stage];
        if (touch.globalX < buttonRect.x - MAX_DRAG_DIST ||
            touch.globalY < buttonRect.y - MAX_DRAG_DIST ||
            touch.globalX > buttonRect.x + buttonRect.width + MAX_DRAG_DIST ||
            touch.globalY > buttonRect.y + buttonRect.height + MAX_DRAG_DIST)
        {
            [self resetContents];
        }            
    }
    else if (touch.phase == SPTouchPhaseEnded && mIsDown)
    {
        [self resetContents];
        [self dispatchEvent:[SPEvent eventWithType:SP_EVENT_TYPE_TRIGGERED]];
    }    
    else if (touch.phase == SPTouchPhaseCancelled && mIsDown)
    {
        [self resetContents];
    }
}

- (void)resetContents
{
    mIsDown = NO;
    mBackground.texture = mUpState;
    mContents.x = mContents.y = 0;        
    mContents.scaleX = mContents.scaleY = 1.0f;
}

- (void)setEnabled:(BOOL)value
{
    mEnabled = value;
    if (mEnabled) 
    {
        mContents.alpha = 1.0f;
    }
    else
    {
        mContents.alpha = mAlphaWhenDisabled;
        [self resetContents];
    }    
}

- (void)setUpState:(SPTexture*)upState
{
    if (upState != mUpState)
    {    
        [mUpState release];
        mUpState = [upState retain];
        if (!mIsDown) mBackground.texture = upState;
    }
}

- (void)setDownState:(SPTexture*)downState
{
    if (downState != mDownState)
    {    
        [mDownState release];
        mDownState = [downState retain];
        if (mIsDown) mBackground.texture = downState;
    }
}

- (void)createTextField
{
    if (!mTextField)
    {
        mTextField = [[SPTextField alloc] init];
        mTextField.vAlign = SPVAlignCenter;
        mTextField.hAlign = SPHAlignCenter;
        mTextField.touchable = NO;
        [mContents addChild:mTextField];
    }

    mTextField.width  = mTextBounds.width;
    mTextField.height = mTextBounds.height;
    mTextField.x = mTextBounds.x;
    mTextField.y = mTextBounds.y;
}

- (NSString*)text
{
    if (mTextField) return mTextField.text;
    else return @"";
}

- (void)setText:(NSString*)value
{
    [self createTextField];
    mTextField.text = value;   
}

- (void)setTextBounds:(SPRectangle *)value
{
    [mTextBounds autorelease];
    
    float scaleX = mBackground.scaleX;
    float scaleY = mBackground.scaleY;
    
    mTextBounds = [[SPRectangle alloc] initWithX:value.x/scaleX y:value.y/scaleY 
                                           width:value.width/scaleX height:value.height/scaleY];
    
    [self createTextField];
}

- (SPRectangle *)textBounds
{
    float scaleX = mBackground.scaleX;
    float scaleY = mBackground.scaleY;
    
    return [SPRectangle rectangleWithX:mTextBounds.x*scaleX y:mTextBounds.y*scaleY 
                                 width:mTextBounds.width*scaleX height:mTextBounds.height*scaleY];
}

- (NSString*)fontName
{
    if (mTextField) return mTextField.fontName;
    else return SP_DEFAULT_FONT_NAME;
}

- (void)setFontName:(NSString*)value
{
    [self createTextField];
    mTextField.fontName = value;
}

- (float)fontSize
{
    if (mTextField) return mTextField.fontSize;
    else return SP_DEFAULT_FONT_SIZE;
}

- (void)setFontSize:(float)value
{
    [self createTextField];
    mTextField.fontSize = value;    
}

- (uint)fontColor
{
    if (mTextField) return mTextField.color;
    else return SP_DEFAULT_FONT_COLOR;
}

- (void)setFontColor:(uint)value
{
    [self createTextField];
    mTextField.color = value;
}

- (void)setWidth:(float)width
{
    // a button behaves just like a textfield: when changing width & height,
    // the textfield is not stretched, but will have more room for its chars.
    
    mBackground.width = width;
    [self createTextField];
}

- (float)width
{
    return mBackground.width;
}

- (void)setHeight:(float)height
{
    mBackground.height = height;    
    [self createTextField];
}

- (float)height
{
    return mBackground.height;
}
 
+ (SPButton*)buttonWithUpState:(SPTexture*)upState downState:(SPTexture*)downState
{
    return [[[SPButton alloc] initWithUpState:upState downState:downState] autorelease];
}

+ (SPButton*)buttonWithUpState:(SPTexture*)upState text:(NSString*)text
{
    return [[[SPButton alloc] initWithUpState:upState text:text] autorelease];
}

+ (SPButton*)buttonWithUpState:(SPTexture*)upState
{
    return [[[SPButton alloc] initWithUpState:upState] autorelease];
}

- (void)dealloc
{
    [self removeEventListenersAtObject:self forType:SP_EVENT_TYPE_TOUCH];
    [mTextBounds release];
    [mUpState release];
    [mDownState release];
    [mBackground release];
    [mTextField release];
    [mContents release];
    [super dealloc];
}

@end
