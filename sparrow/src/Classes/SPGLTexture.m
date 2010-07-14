//
//  SPGLTexture.m
//  Sparrow
//
//  Created by Daniel Sperl on 27.06.09.
//  Copyright 2009 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPGLTexture.h"
#import "SPMacros.h"
#import "SPRectangle.h"

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

@implementation SPGLTexture

@synthesize textureID = mTextureID;
@synthesize repeat = mRepeat;
@synthesize hasPremultipliedAlpha = mPremultipliedAlpha;
@synthesize scale = mScale;

- (id)initWithData:(const void*)imgData width:(int)width height:(int)height
            format:(SPTextureFormat)format premultipliedAlpha:(BOOL)pma
{
    if (self = [super init])
    {        
        mWidth = width;
        mHeight = height;
        mRepeat = NO;
        mPremultipliedAlpha = pma;
        mScale = 1.0f;
        
        if (imgData)
        {
            GLenum glTexFormat;            
            if (format == SPTextureFormatRGBA) glTexFormat = GL_RGBA;            
            else                               glTexFormat = GL_ALPHA;
            
            glGenTextures(1, &mTextureID);
            glBindTexture(GL_TEXTURE_2D, mTextureID);    
            
            glTexParameteri(GL_TEXTURE_2D, GL_GENERATE_MIPMAP, GL_TRUE);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_NEAREST);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);   
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, mRepeat ? GL_REPEAT : GL_CLAMP_TO_EDGE); 
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, mRepeat ? GL_REPEAT : GL_CLAMP_TO_EDGE); 
           
            glTexImage2D(GL_TEXTURE_2D, 0, glTexFormat, width, height, 0, glTexFormat, 
                         GL_UNSIGNED_BYTE, imgData);
            
            glBindTexture(GL_TEXTURE_2D, 0);
            
        }
        else
        {
            mTextureID = 0;
        }
    }
    return self; 
}

- (id)init
{
    return [self initWithData:NULL width:32 height:32 
                       format:SPTextureFormatRGBA premultipliedAlpha:NO];
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
    glBindTexture(GL_TEXTURE_2D, 0);  
}

+ (SPGLTexture*)textureWithData:(const void*)imgData width:(int)width height:(int)height
                             format:(SPTextureFormat)format premultipliedAlpha:(BOOL)pma
{
    return [[[SPGLTexture alloc] initWithData:imgData width:width height:height 
                                           format:format premultipliedAlpha:pma] autorelease];
}

- (void)dealloc
{     
    glDeleteTextures(1, &mTextureID); 
    [super dealloc];
}

@end
