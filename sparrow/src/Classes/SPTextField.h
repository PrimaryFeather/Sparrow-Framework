//
//  SPTextField.h
//  Sparrow
//
//  Created by Daniel Sperl on 29.06.09.
//  Copyright 2009 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>
#import "SPDisplayObjectContainer.h"
#import "SPMacros.h"

@class SPTexture;
@class SPQuad;

#define SP_DEFAULT_FONT_NAME  @"Helvetica"
#define SP_DEFAULT_FONT_SIZE  14.0f
#define SP_DEFAULT_FONT_COLOR SP_BLACK

#define SP_NATIVE_FONT_SIZE -1.0f

typedef enum 
{
    SPHAlignLeft = 0,
    SPHAlignCenter,
    SPHAlignRight
} SPHAlign;

typedef enum 
{
    SPVAlignTop = 0,
    SPVAlignCenter,
    SPVAlignBottom
} SPVAlign;

@interface SPTextField : SPDisplayObjectContainer
{
  @private
    float mFontSize;
    uint mColor;
    NSString *mText;
    NSString *mFontName;    
    SPHAlign mHAlign;
    SPVAlign mVAlign;
    BOOL mBorder;    
    BOOL mRequiresRedraw;
    BOOL mIsRenderedText;
    
    SPQuad *mHitArea;
    SPDisplayObject *mContents;
}

@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *fontName;
@property (nonatomic, assign) float fontSize;
@property (nonatomic, assign) SPHAlign hAlign;
@property (nonatomic, assign) SPVAlign vAlign;
@property (nonatomic, assign) BOOL border;
@property (nonatomic, assign) uint color;

// designated initializer
- (id)initWithWidth:(float)width height:(float)height text:(NSString*)text fontName:(NSString*)name
           fontSize:(float)size color:(uint)color ;
- (id)initWithWidth:(float)width height:(float)height text:(NSString*)text;
- (id)initWithText:(NSString *)text;

+ (SPTextField *)textFieldWithWidth:(float)width height:(float)height text:(NSString*)text 
                          fontName:(NSString*)name fontSize:(float)size color:(uint)color;
+ (SPTextField *)textFieldWithWidth:(float)width height:(float)height text:(NSString*)text;
+ (SPTextField *)textFieldWithText:(NSString *)text;

+ (NSString *)registerBitmapFontFromFile:(NSString*)path texture:(SPTexture *)texture;
+ (NSString *)registerBitmapFontFromFile:(NSString*)path;
+ (void)unregisterBitmapFont:(NSString *)name;

@end
