//
//  SPGLTexture.m
//  Sparrow
//
//  Created by Daniel Sperl on 27.06.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPGLTexture.h"
#import "SPMacros.h"
#import "SPRectangle.h"

@implementation SPGLTexture
{
    uint mName;
    float mWidth;
    float mHeight;
    float mScale;
    BOOL mRepeat;
    BOOL mPremultipliedAlpha;
    BOOL mMipmaps;
    SPTextureSmoothing mSmoothing;
}

@synthesize name = mName;
@synthesize repeat = mRepeat;
@synthesize premultipliedAlpha = mPremultipliedAlpha;
@synthesize scale = mScale;
@synthesize smoothing = mSmoothing;

- (id)initWithName:(uint)name width:(float)width height:(float)height
        containsMipmaps:(BOOL)mipmaps scale:(float)scale premultipliedAlpha:(BOOL)pma
{
    if ((self = [super init]))
    {
        mName = name;
        mWidth = width;
        mHeight = height;
        mMipmaps = mipmaps;
        mScale = scale;
        mPremultipliedAlpha = pma;
        
        self.repeat = NO;
        self.smoothing = SPTextureSmoothingBilinear;
    }
    
    return self;
}

- (id)initWithData:(const void *)imgData width:(float)width height:(float)height
   generateMipmaps:(BOOL)mipmaps scale:(float)scale premultipliedAlpha:(BOOL)pma
{
    GLenum glTexType = GL_UNSIGNED_BYTE;
    GLenum glTexFormat = GL_RGBA;
    GLuint glTexName;
    
    glGenTextures(1, &glTexName);
    glBindTexture(GL_TEXTURE_2D, glTexName);
    glTexImage2D(GL_TEXTURE_2D, 0, glTexFormat, width, height, 0, glTexFormat, glTexType, imgData);
    
    if (mipmaps)
        glGenerateMipmap(GL_TEXTURE_2D);
    
    glBindTexture(GL_TEXTURE_2D, 0);

    return [self initWithName:glTexName width:width height:height containsMipmaps:mipmaps
                             scale:scale premultipliedAlpha:pma];
}

- (id)initWithTextureInfo:(GLKTextureInfo *)info scale:(float)scale
{
    return [self initWithTextureInfo:info scale:scale
                  premultipliedAlpha:info.alphaState == GLKTextureInfoAlphaStatePremultiplied];
}

- (id)initWithTextureInfo:(GLKTextureInfo *)info scale:(float)scale premultipliedAlpha:(BOOL)pma;
{
    return [self initWithName:info.name width:info.width height:info.height
                   containsMipmaps:info.containsMipmaps scale:scale
                premultipliedAlpha:pma];
}

- (id)initWithTextureInfo:(GLKTextureInfo *)info
{
    return [self initWithTextureInfo:info scale:1.0f];
}

- (id)init
{
    return [self initWithData:NULL width:32 height:32 generateMipmaps:NO
                        scale:1.0f premultipliedAlpha:NO];
}

- (float)width
{
    return mWidth / mScale;
}

- (float)height
{
    return mHeight / mScale;
}

- (void)setRepeat:(BOOL)value
{
    mRepeat = value;
    glBindTexture(GL_TEXTURE_2D, mName);    
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, mRepeat ? GL_REPEAT : GL_CLAMP_TO_EDGE);     
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, mRepeat ? GL_REPEAT : GL_CLAMP_TO_EDGE); 
}

- (void)setSmoothing:(SPTextureSmoothing)filterType
{
    mSmoothing = filterType;
    glBindTexture(GL_TEXTURE_2D, mName); 
    
    int magFilter, minFilter;
    
    if (filterType == SPTextureSmoothingNone)
    {
        magFilter = GL_NEAREST;
        minFilter = mMipmaps ? GL_NEAREST_MIPMAP_NEAREST : GL_NEAREST;
    }
    else if (filterType == SPTextureSmoothingBilinear)
    {
        magFilter = GL_LINEAR;
        minFilter = mMipmaps ? GL_LINEAR_MIPMAP_NEAREST : GL_LINEAR;
    }
    else
    {
        magFilter = GL_LINEAR;
        minFilter = mMipmaps ? GL_LINEAR_MIPMAP_LINEAR : GL_LINEAR;
    }
    
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, magFilter); 
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, minFilter);
}

- (void)dealloc
{     
    glDeleteTextures(1, &mName); 
}

@end
