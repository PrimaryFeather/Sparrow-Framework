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

#import <GLKit/GLKit.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

@implementation SPGLTexture
{
    uint mTextureID;
    float mWidth;
    float mHeight;
    float mScale;
    BOOL mRepeat;
    BOOL mPremultipliedAlpha;
    BOOL mMipmaps;
    SPTextureFilter mFilter;
}

@synthesize textureID = mTextureID;
@synthesize repeat = mRepeat;
@synthesize premultipliedAlpha = mPremultipliedAlpha;
@synthesize scale = mScale;
@synthesize filter = mFilter;

- (id)initWithTextureID:(uint)textureID width:(float)width height:(float)height
        containsMipmaps:(BOOL)mipmaps scale:(float)scale premultipliedAlpha:(BOOL)pma
{
    if ((self = [super init]))
    {
        mTextureID = textureID;
        mWidth = width;
        mHeight = height;
        mMipmaps = mipmaps;
        mScale = scale;
        mPremultipliedAlpha = pma;
        
        self.repeat = NO;
        self.filter = SPTextureFilterBilinear;
    }
    
    return self;
}

- (id)initWithData:(const void *)imgData width:(float)width height:(float)height
   generateMipmaps:(BOOL)mipmaps colorSpace:(SPColorSpace)colorSpace
             scale:(float)scale premultipliedAlpha:(BOOL)pma
{
    GLenum glTexType = GL_UNSIGNED_BYTE;
    GLenum glTexFormat = colorSpace == SPColorSpaceRGBA ? GL_RGBA : GL_ALPHA;
    GLuint textureID;
    
    glGenTextures(1, &textureID);
    glBindTexture(GL_TEXTURE_2D, textureID);
    
    glTexParameteri(GL_TEXTURE_2D, GL_GENERATE_MIPMAP, mipmaps);
    glTexImage2D(GL_TEXTURE_2D, 0, glTexFormat, width, height, 0, glTexFormat, glTexType, imgData);
    glBindTexture(GL_TEXTURE_2D, 0);

    return [self initWithTextureID:textureID width:width height:height containsMipmaps:mipmaps
                             scale:scale premultipliedAlpha:pma];
}

- (id)initWithTextureInfo:(GLKTextureInfo *)info scale:(float)scale
{
    return [self initWithTextureID:info.name width:info.width height:info.height
                   containsMipmaps:info.containsMipmaps scale:scale
                premultipliedAlpha:(info.alphaState == GLKTextureInfoAlphaStatePremultiplied)];
}

- (id)initWithTextureInfo:(GLKTextureInfo *)info
{
    return [self initWithTextureInfo:info scale:1.0f];
}

- (id)init
{
    return [self initWithData:NULL width:32 height:32 generateMipmaps:NO colorSpace:SPColorSpaceRGBA
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
    glBindTexture(GL_TEXTURE_2D, mTextureID);    
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, mRepeat ? GL_REPEAT : GL_CLAMP_TO_EDGE);     
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, mRepeat ? GL_REPEAT : GL_CLAMP_TO_EDGE); 
}

- (void)setFilter:(SPTextureFilter)filterType
{
    mFilter = filterType;
    glBindTexture(GL_TEXTURE_2D, mTextureID); 
    
    int magFilter, minFilter;
    
    if (filterType == SPTextureFilterNearestNeighbor)
    {
        magFilter = GL_NEAREST;
        minFilter = mMipmaps ? GL_NEAREST_MIPMAP_NEAREST : GL_NEAREST;
    }
    else if (filterType == SPTextureFilterBilinear)
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
    glDeleteTextures(1, &mTextureID); 
}

@end
