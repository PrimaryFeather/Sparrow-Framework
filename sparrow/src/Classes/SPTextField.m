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
#import "SPTextField_Internal.h"
#import "SPImage.h"
#import "SPTexture.h"
#import "SPSubTexture.h"
#import "SPGLTexture.h"
#import "SPEnterFrameEvent.h"
#import "SPQuad.h"
#import "SPBitmapFont.h"
#import "SPStage.h"
#import "SparrowClass.h"

#import <UIKit/UIKit.h>

static NSMutableDictionary *bitmapFonts = nil;

// --- class implementation ------------------------------------------------------------------------

@implementation SPTextField
{
    float mFontSize;
    uint mColor;
    NSString *mText;
    NSString *mFontName;
    SPHAlign mHAlign;
    SPVAlign mVAlign;
    BOOL mBorder;
    BOOL mRequiresRedraw;
    BOOL mIsRenderedText;
	BOOL mKerning;
    
    SPQuad *mHitArea;
    SPQuad *mTextArea;
    SPDisplayObject *mContents;
}

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
        
        mTextArea = [[SPQuad alloc] initWithWidth:width height:height];
        mTextArea.visible = NO;        
        [self addChild:mTextArea];
        
        mRequiresRedraw = YES;
        // TODO: add 'flatten' listener
        // [self addEventListener:@selector(onCompile:) atObject:self forType:SP_EVENT_TYPE_COMPILE];
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

- (SPRectangle *)textBounds
{
    if (mRequiresRedraw) [self redrawContents];    
    return [mTextArea boundsInSpace:self.parent];
}

- (SPRectangle *)boundsInSpace:(SPDisplayObject *)targetSpace
{
    return [mHitArea boundsInSpace:targetSpace];
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
        mText = [text copy];
        mRequiresRedraw = YES;
    }
}

- (void)setFontName:(NSString *)fontName
{
    if (![fontName isEqualToString:mFontName])
    {
        mFontName = [fontName copy];
        mRequiresRedraw = YES;        
        mIsRenderedText = !bitmapFonts[mFontName];
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

+ (id)textFieldWithWidth:(float)width height:(float)height text:(NSString*)text
                          fontName:(NSString*)name fontSize:(float)size color:(uint)color
{
    return [[self alloc] initWithWidth:width height:height text:text fontName:name
                                     fontSize:size color:color];
}

+ (id)textFieldWithWidth:(float)width height:(float)height text:(NSString*)text
{
    return [[self alloc] initWithWidth:width height:height text:text];
}

+ (id)textFieldWithText:(NSString*)text
{
    return [[self alloc] initWithText:text];
}

+ (NSString *)registerBitmapFontFromFile:(NSString*)path texture:(SPTexture *)texture name:(NSString *)fontName
{
    if (!bitmapFonts) bitmapFonts = [[NSMutableDictionary alloc] init];
    
    SPBitmapFont *bitmapFont = [[SPBitmapFont alloc] initWithContentsOfFile:path texture:texture];
    if (!fontName) fontName = bitmapFont.name;
    bitmapFonts[fontName] = bitmapFont;
    
    return fontName;
}

+ (NSString *)registerBitmapFontFromFile:(NSString *)path texture:(SPTexture *)texture
{
    return [SPTextField registerBitmapFontFromFile:path texture:texture name:nil];
}

+ (NSString *)registerBitmapFontFromFile:(NSString *)path name:(NSString *)fontName
{
    return [SPTextField registerBitmapFontFromFile:path texture:nil name:fontName];
}

+ (NSString *)registerBitmapFontFromFile:(NSString *)path
{
    return [SPTextField registerBitmapFontFromFile:path texture:nil name:nil];
}

+ (void)unregisterBitmapFont:(NSString *)name
{
    [bitmapFonts removeObjectForKey:name];
    
    if (bitmapFonts.count == 0)
        bitmapFonts = nil;
}

+ (SPBitmapFont *)getRegisteredBitmapFont:(NSString *)name
{
    return bitmapFonts[name];
}

- (void)dealloc
{
    //[self removeEventListenersAtObject:self forType:SP_EVENT_TYPE_COMPILE];
}

@end

@implementation SPTextField (Internal)

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
    
  #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000
    NSLineBreakMode lbm = NSLineBreakByTruncatingTail;
  #else
    UILineBreakMode lbm = UILineBreakModeTailTruncation;
  #endif
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
    
    SPTexture *texture = [[SPTexture alloc] initWithWidth:width height:height generateMipmaps:YES
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
    
    return image;
}

- (SPDisplayObject *)createComposedContents
{
    SPBitmapFont *bitmapFont = bitmapFonts[mFontName];
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

@end
