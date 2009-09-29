//
//  SPStaticTexture.h
//  Sparrow
//
//  Created by Daniel Sperl on 27.06.09.
//  Copyright 2009 Incognitek. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SPTexture.h"
#import "SPMakros.h"

typedef enum 
{
    SPTextureFormatRGBA,
    SPTextureFormatAlpha
} SPTextureFormat;

@class SPRectangle;

@interface SPStaticTexture : SPTexture
{
  @private
    uint mTextureID;
    float mWidth;
    float mHeight;
    BOOL mRepeat;
}

- (id)initWithData:(const void*)imgData width:(int)width height:(int)height 
            format:(SPTextureFormat)format premultipliedAlpha:(BOOL)pma;
- (id)initWithContentsOfFile:(NSString*)path;
+ (SPStaticTexture*)textureWithContentsOfFile:(NSString*)path;
+ (SPStaticTexture*)textureWithData:(const void*)imgData width:(int)width height:(int)height
                             format:(SPTextureFormat)format premultipliedAlpha:(BOOL)pma;

@property (nonatomic, assign) BOOL repeat;

@end