//
//  SPTextField.m
//  Sparrow
//
//  Created by Daniel Sperl on 29.06.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPTextField.h"
#import "SPImage.h"
#import "SPTexture.h"
#import "SPSubTexture.h"
#import "SPGLTexture.h"
#import "SPEnterFrameEvent.h"
#import "SPQuad.h"
#import "SPBitmapFont.h"
#import "SPStage.h"
#import "SPCompiledSprite.h"

#import <UIKit/UIKit.h>

static NSMutableDictionary *bitmapFonts = nil;

// --- private interface ---------------------------------------------------------------------------

@interface SPTextField()

- (void)redrawContents;
- (SPDisplayObject *)createRenderedContents;
- (SPDisplayObject *)createComposedContents;

@end

// --- class implementation ------------------------------------------------------------------------

@implementation SPTextField

@synthesize text = mText;
@synthesize fontName = mFontName;
@synthesize fontSize = mFontSize;
@synthesize hAlign = mHAlign;
@synthesize vAlign = mVAlign;
@synthesize border = mBorder;
@synthesize color = mColor;
@synthesize kerning = mKerning;

- (id)initWithWidth:(float)width height:(float)height text:(NSString*)text fontName:(NSString*)name 
          fontSize:(float)size color:(uint)color 
{
    if ((self = [super init]))
    {        
        mText = [text copy];
        mFontSize = size;
        mColor = color;
        mHAlign = SPHAlignCenter;
        mVAlign = SPVAlignCenter;
        mBorder = NO;        
		mKerning = YES;
        self.fontName = name;
        
        mHitArea = [[SPQuad alloc] initWithWidth:width height:height];
        mHitArea.alpha = 0.0f;
        [self addChild:mHitArea];
        [mHitArea release];
        
        mTextArea = [[SPQuad alloc] initWithWidth:width height:height];
        mTextArea.visible = NO;        
        [self addChild:mTextArea];
        [mTextArea release];
        
        mRequiresRedraw = YES;
        [self addEventListener:@selector(onCompile:) atObject:self forType:SP_EVENT_TYPE_COMPILE];
    }
    return self;
} 

- (id)initWithWidth:(float)width height:(float)height text:(NSString*)text
{
    return [self initWithWidth:width height:height text:text fontName:SP_DEFAULT_FONT_NAME
                     fontSize:SP_DEFAULT_FONT_SIZE color:SP_DEFAULT_FONT_COLOR];   
}

- (id)initWithWidth:(float)width height:(float)height
{
    return [self initWithWidth:width height:height text:@""];
}

- (id)initWithText:(NSString *)text
{
    return [self initWithWidth:128 height:128 text:text];
}

- (id)init
{
    return [self initWithText:@""];
}

- (void)onCompile:(SPEvent *)event
{
    if (mRequiresRedraw) [self redrawContents];
}

- (void)render:(SPRenderSupport *)support
{
    if (mRequiresRedraw) [self redrawContents];    
    [super render:support];
}

- (void)redrawContents
{
    [mContents removeFromParent];
    
    mContents = mIsRenderedText ? [self createRenderedContents] : [self createComposedContents];
    mContents.touchable = NO;    
    mRequiresRedraw = NO;
    
    [self addChild:mContents];
}

- (SPDisplayObject *)createRenderedContents
{
    float width = mHitArea.width;
    float height = mHitArea.height;    
    float fontSize = mFontSize == SP_NATIVE_FONT_SIZE ? SP_DEFAULT_FONT_SIZE : mFontSize;
    
    UILineBreakMode lbm = UILineBreakModeTailTruncation;
    CGSize textSize = [mText sizeWithFont:[UIFont fontWithName:mFontName size:fontSize] 
                        constrainedToSize:CGSizeMake(width, height) lineBreakMode:lbm];
    
    float xOffset = 0;
    if (mHAlign == SPHAlignCenter)      xOffset = (width - textSize.width) / 2.0f;
    else if (mHAlign == SPHAlignRight)  xOffset =  width - textSize.width;
    
    float yOffset = 0;
    if (mVAlign == SPVAlignCenter)      yOffset = (height - textSize.height) / 2.0f;
    else if (mVAlign == SPVAlignBottom) yOffset =  height - textSize.height;
    
    mTextArea.x = xOffset; 
    mTextArea.y = yOffset;
    mTextArea.width = textSize.width; 
    mTextArea.height = textSize.height;
    
    SPTexture *texture = [[SPTexture alloc] initWithWidth:width height:height
                                                    scale:[SPStage contentScaleFactor]
                                               colorSpace:SPColorSpaceAlpha
                                                     draw:^(CGContextRef context)
    {
        if (mBorder)
        {
            CGContextSetGrayStrokeColor(context, 1.0f, 1.0f);
            CGContextSetLineWidth(context, 1.0f);
            CGContextStrokeRect(context, CGRectMake(0.5f, 0.5f, width-1, height-1));
        }
        
        CGContextSetGrayFillColor(context, 1.0f, 1.0f);        
        
        [mText drawInRect:CGRectMake(0, yOffset, width, height)
                 withFont:[UIFont fontWithName:mFontName size:fontSize] 
            lineBreakMode:lbm alignment:(UITextAlignment)mHAlign];
    }];
    
    SPImage *image = [SPImage imageWithTexture:texture];
    image.color = mColor;
    [texture release];
    
    return image;
}

- (SPDisplayObject *)createComposedContents
{
    SPBitmapFont *bitmapFont = [bitmapFonts objectForKey:mFontName];
    if (!bitmapFont)     
        [NSException raise:SP_EXC_INVALID_OPERATION 
                    format:@"bitmap font %@ not registered!", mFontName];       
 
    SPDisplayObject *contents = [bitmapFont createDisplayObjectWithWidth:mHitArea.width 
        height:mHitArea.height text:mText fontSize:mFontSize color:mColor
        hAlign:mHAlign vAlign:mVAlign border:mBorder kerning:mKerning];    
    
    SPRectangle *textBounds = [(SPDisplayObjectContainer *)contents childAtIndex:0].bounds;
    mTextArea.x = textBounds.x; mTextArea.y = textBounds.y;
    mTextArea.width = textBounds.width; mTextArea.height = textBounds.height;    
    
    return contents;    
}

- (SPRectangle *)textBounds
{
    if (mRequiresRedraw) [self redrawContents];    
    return [mTextArea boundsInSpace:self.parent];
}

- (SPRectangle*)boundsInSpace:(SPDisplayObject*)targetCoordinateSpace
{
    return [mHitArea boundsInSpace:targetCoordinateSpace];
}

- (void)setWidth:(float)width
{
    // other than in SPDisplayObject, changing the size of the object should not change the scaling;
    // changing the size should just make the texture bigger/smaller, 
    // keeping the size of the text/font unchanged. (this applies to setHeight:, as well.)
    
    mHitArea.width = width;
    mRequiresRedraw = YES;
}

- (void)setHeight:(float)height
{
    mHitArea.height = height;
    mRequiresRedraw = YES;
}

- (void)setText:(NSString *)text
{
    if (![text isEqualToString:mText])
    {
        [mText release];
        mText = [text copy];
        mRequiresRedraw = YES;
    }
}

- (void)setFontName:(NSString *)fontName
{
    if (![fontName isEqualToString:mFontName])
    {
        [mFontName release];
        mFontName = [fontName copy];
        mRequiresRedraw = YES;        
        mIsRenderedText = ![bitmapFonts objectForKey:mFontName];
    }
}

- (void)setFontSize:(float)fontSize
{
    if (fontSize != mFontSize)
    {
        mFontSize = fontSize;
        mRequiresRedraw = YES;
    }
}
 
- (void)setBorder:(BOOL)border
{
    if (border != mBorder)
    {
        mBorder = border;
        mRequiresRedraw = YES;
    }
}
 
- (void)setHAlign:(SPHAlign)hAlign
{
    if (hAlign != mHAlign)
    {
        mHAlign = hAlign;
        mRequiresRedraw = YES;
    }
}

- (void)setVAlign:(SPVAlign)vAlign
{
    if (vAlign != mVAlign)
    {
        mVAlign = vAlign;
        mRequiresRedraw = YES;
    }
}

- (void)setColor:(uint)color
{
    if (color != mColor)
    {
        mColor = color;
        if (mIsRenderedText) 
            [(SPImage *)mContents setColor:color];
        else 
            mRequiresRedraw = YES;
    }
}

- (void)setKerning:(BOOL)kerning
{
	if (kerning != mKerning)
	{
		mKerning = kerning;
		mRequiresRedraw = YES;
	}
}

+ (SPTextField*)textFieldWithWidth:(float)width height:(float)height text:(NSString*)text 
                          fontName:(NSString*)name fontSize:(float)size color:(uint)color
{
    return [[[SPTextField alloc] initWithWidth:width height:height text:text fontName:name 
                                     fontSize:size color:color] autorelease];
}

+ (SPTextField*)textFieldWithWidth:(float)width height:(float)height text:(NSString*)text
{
    return [[[SPTextField alloc] initWithWidth:width height:height text:text] autorelease];
}

+ (SPTextField*)textFieldWithText:(NSString*)text
{
    return [[[SPTextField alloc] initWithText:text] autorelease];
}

+ (NSString *)registerBitmapFontFromFile:(NSString*)path texture:(SPTexture *)texture
{
    if (!bitmapFonts) bitmapFonts = [[NSMutableDictionary alloc] init];
    
    SPBitmapFont *bitmapFont = [[SPBitmapFont alloc] initWithContentsOfFile:path texture:texture];
    NSString *fontName = bitmapFont.name;
    [bitmapFonts setObject:bitmapFont forKey:fontName];
    [bitmapFont release];
    
    return fontName;
}

+ (NSString *)registerBitmapFontFromFile:(NSString *)path
{
    return [SPTextField registerBitmapFontFromFile:path texture:nil];
}

+ (void)unregisterBitmapFont:(NSString *)name
{
    [bitmapFonts removeObjectForKey:name];
    
    if (bitmapFonts.count == 0)
    {
        [bitmapFonts release];
        bitmapFonts = nil;
    }
}

- (void)dealloc
{
    [self removeEventListenersAtObject:self forType:SP_EVENT_TYPE_COMPILE];
    [mText release];
    [mFontName release];
    [super dealloc];
}

@end
