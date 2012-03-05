//
//  SPGLTexture.h
//  Sparrow
//
//  Created by Daniel Sperl on 27.06.09.
//  Copyright 2011 Gamua. All rights reserved.
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
    SPTextureFormatPvrtcRGBA4,
    SPTextureFormat565,
    SPTextureFormat888,
    SPTextureFormat5551,
    SPTextureFormat4444,
    SPTextureFormatAI88,
    SPTextureFormatI8
} SPTextureFormat;

typedef struct
{
    SPTextureFormat format;
    int width;
    int height;
    int numMipmaps;
    BOOL generateMipmaps;
    BOOL premultipliedAlpha;
} SPTextureProperties;

/** ------------------------------------------------------------------------------------------------

 The SPGLTexture class is a concrete implementation of the abstract class SPTexture,
 containing a standard 2D OpenGL texture. 
 
 Don't use this class directly, but load textures with the init-methods of SPTexture instead.
 
------------------------------------------------------------------------------------------------- */

@interface SPGLTexture : SPTexture
{
  @private
    uint mTextureID;
    float mWidth;
    float mHeight;
    float mScale;
    BOOL mRepeat;
    BOOL mPremultipliedAlpha;
    BOOL mMipmaps;
    SPTextureFilter mFilter;
}

/// ------------------
/// @name Initializers
/// ------------------

/// Initializes a texture with raw pixel data and a set of properties.
- (id)initWithData:(const void *)imgData properties:(SPTextureProperties)properties;

/// Factory method.
+ (SPGLTexture*)textureWithData:(const void *)imgData properties:(SPTextureProperties)properties;

/// ----------------
/// @name Properties
/// ----------------

/// The filter type influences how the texture appears when it is scaled up or down. 
/// Default: `SPTextureFilterLinear`.
@property (nonatomic, assign) SPTextureFilter filter;

/// The scale factor, which influences `width` and `height` properties.
@property (nonatomic, assign) float scale;

@end