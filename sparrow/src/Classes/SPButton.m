//
//  SPButton.m
//  Sparrow
//
//  Created by Daniel Sperl on 13.07.09.
//  Copyright 2009 Incognitek. All rights reserved.
//

#import "SPButton.h"
#import "SPTouchEvent.h"
#import "SPTexture.h"
#import "SPStaticTexture.h"
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
@synthesize isEnabled = mEnabled;
@synthesize upState = mUpState;
@synthesize downState = mDownState;

#define MAX_DRAG_DIST 40

- (id)initWithUpState:(SPTexture*)upState downState:(SPTexture*)downState;
{
    if (self = [super init])
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

- (id)initWithUpState:(SPTexture*)upState;
{
    self = [self initWithUpState:upState downState:upState];
    mScaleWhenDown = 0.9f;
    return self;
}

- (id)init
{
    SPTexture *texture = [[[SPStaticTexture alloc] init] autorelease];
    return [self initWithUpState:texture];   
}

#pragma mark -

- (void)onTouch:(SPTouchEvent*)touchEvent
{    
    if (!mEnabled) return;    
    SPTouch *touch = [[touchEvent touchesWithTarget:self] anyObject];
    
    if (touch.phase == SPTouchPhaseBegan)
    {
        mBackground.texture = mDownState;
        mContents.scaleX = mContents.scaleY = mScaleWhenDown;
        mContents.x = (1.0f - mScaleWhenDown) / 2.0f * mDownState.width;
        mContents.y = (1.0f - mScaleWhenDown) / 2.0f * mDownState.height;
        mIsDown = YES;
    }
    else if (touch.phase == SPTouchPhaseMoved && mIsDown)
    {
        // reset button when user dragged to far away after pushing
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
}

- (void)resetContents
{
    mIsDown = NO;
    mBackground.texture = mUpState;
    mContents.x = mContents.y = 0;        
    mContents.scaleX = mContents.scaleY = 1.0f;
}

- (void)setIsEnabled:(BOOL)value
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

#pragma mark -

- (void)setUpState:(SPTexture*)upState
{
    [mUpState release];
    mUpState = [upState retain];
    if (!mIsDown) mBackground.texture = upState;
    mTextField.width = upState.width;
    mTextField.height = upState.height;
}

- (void)setDownState:(SPTexture*)downState
{
    [mDownState release];
    mDownState = [downState retain];
    if (mIsDown) mBackground.texture = downState;
}

#pragma mark -

- (void)createTextField
{
    if (!mTextField)
    {
        mTextField = [[SPTextField alloc] initWithWidth:mUpState.width height:mUpState.height text:@""];
        mTextField.vAlign = SPVAlignCenter;
        mTextField.hAlign = SPHAlignCenter;
        [mContents addChild:mTextField];        
    }
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
    if (mTextField) return mTextField.fontColor;
    else return SP_DEFAULT_FONT_COLOR;
}

- (void)setFontColor:(uint)value
{
    [self createTextField];
    mTextField.fontColor = value;
}

#pragma mark -

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

#pragma mark -

- (void)dealloc
{
    [self removeEventListenersAtObject:self forType:SP_EVENT_TYPE_TOUCH];
    [mUpState release];
    [mDownState release];
    [mBackground release];
    [mTextField release];
    [mContents release];
    [super dealloc];
}

@end
