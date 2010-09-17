//
//  SPGLTexture.h
//  Sparrow
//
//  Created by Daniel Sperl on 27.06.09.
//  Copyright 2009 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>

#import "SPTexture.h"
#import "SPMacros.h"

@class SPRectangle;

typedef enum 
{
    SPTextureFormatRGBA,
    SPTextureFormatAlpha,
    SPTextureFormatPvrtcRGB2,
    SPTextureFormatPvrtcRGBA2,
    SPTextureFormatPvrtcRGB4,
    SPTextureFormatPvrtcRGBA4    
} SPTextureFormat;

typedef struct
{
    SPTextureFormat format;
    int width;
    int height;
    int numMipmaps;
    BOOL premultipliedAlpha;
} SPTextureProperties;

@interface SPGLTexture : SPTexture
{
  @private
    uint mTextureID;
    float mWidth;
    float mHeight;
    float mScale;
    BOOL mRepeat;
    BOOL mPremultipliedAlpha;    
}

- (id)initWithData:(const void *)imgData properties:(SPTextureProperties)properties;

+ (SPGLTexture*)textureWithData:(const void *)imgData properties:(SPTextureProperties)properties;

@property (nonatomic, assign) BOOL repeat;
@property (nonatomic, assign) float scale;

@end