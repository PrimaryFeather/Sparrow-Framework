//
//  SPTextField.h
//  Sparrow
//
//  Created by Daniel Sperl on 29.06.09.
//  Copyright 2009 Incognitek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPQuad.h"

@class SPTexture;

#define SP_DEFAULT_FONT_NAME  @"Helvetica"
#define SP_DEFAULT_FONT_SIZE  14.0f
#define SP_DEFAULT_FONT_COLOR SP_BLACK

typedef enum {
    SPHAlignLeft = 0,
    SPHAlignCenter,
    SPHAlignRight
} SPHAlign;

typedef enum {
    SPVAlignTop = 0,
    SPVAlignCenter,
    SPVAlignBottom
} SPVAlign;

@interface SPTextField : SPQuad 
{
  @private
    NSString *mText;
    NSString *mFontName;
    float mFontSize;
    SPHAlign mHAlign;
    SPVAlign mVAlign;    
    BOOL mBorder;
    
    BOOL mRequiresRedraw;    
    SPTexture *mTexture;
}

@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *fontName;
@property (nonatomic, assign) float fontSize;
@property (nonatomic, assign) SPHAlign hAlign;
@property (nonatomic, assign) SPVAlign vAlign;
@property (nonatomic, assign) BOOL border;
@property (nonatomic, readonly) float textWidth;
@property (nonatomic, readonly) float textHeight;

// designated initializer
- (id)initWithWidth:(float)width height:(float)height text:(NSString*)text fontName:(NSString*)name
           fontSize:(float)size color:(uint)color ;
- (id)initWithWidth:(float)width height:(float)height text:(NSString*)text;

+ (SPTextField*)textFieldWithWidth:(float)width height:(float)height text:(NSString*)text 
                          fontName:(NSString*)name fontSize:(float)size color:(uint)color;
+ (SPTextField*)textFieldWithWidth:(float)width height:(float)height text:(NSString*)text;

@end
