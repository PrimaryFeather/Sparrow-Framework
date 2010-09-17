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

- (id)initWithData:(const void*)imgData properties:(SPTextureProperties)properties
{    
    if (self = [super init])
    {        
        mWidth = properties.width;
        mHeight = properties.height;
        mRepeat = NO;
        mPremultipliedAlpha = properties.premultipliedAlpha;
        mScale = 1.0f;
        
        if (imgData)
        {
            GLenum glTexFormat;                        
            int bitsPerPixel;
            
            switch (properties.format)
            {
                default:
                case SPTextureFormatRGBA:
                    bitsPerPixel = 8;
                    glTexFormat = GL_RGBA;
                    break;
                case SPTextureFormatAlpha:
                    bitsPerPixel = 8;
                    glTexFormat = GL_ALPHA;
                    break;
                case SPTextureFormatPvrtcRGBA2:
                    bitsPerPixel = 2;
                    glTexFormat = GL_COMPRESSED_RGBA_PVRTC_2BPPV1_IMG;
                    break;
                case SPTextureFormatPvrtcRGB2:
                    bitsPerPixel = 2;
                    glTexFormat = GL_COMPRESSED_RGB_PVRTC_2BPPV1_IMG;
                    break;
                case SPTextureFormatPvrtcRGBA4:
                    bitsPerPixel = 4;
                    glTexFormat = GL_COMPRESSED_RGBA_PVRTC_4BPPV1_IMG;
                    break;
                case SPTextureFormatPvrtcRGB4:
                    bitsPerPixel = 4;
                    glTexFormat = GL_COMPRESSED_RGB_PVRTC_4BPPV1_IMG;
                    break;                    
            }
            
            glGenTextures(1, &mTextureID);
            glBindTexture(GL_TEXTURE_2D, mTextureID);
            
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR); 
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, mRepeat ? GL_REPEAT : GL_CLAMP_TO_EDGE); 
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, mRepeat ? GL_REPEAT : GL_CLAMP_TO_EDGE); 
           
            if (bitsPerPixel == 8) // uncompressed image
            {
                glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_NEAREST);
                glTexParameteri(GL_TEXTURE_2D, GL_GENERATE_MIPMAP, GL_TRUE);
                glTexImage2D(GL_TEXTURE_2D, 0, glTexFormat, mWidth, mHeight, 0, glTexFormat, 
                             GL_UNSIGNED_BYTE, imgData);
            }                
            else // compressed image
            {
                glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, properties.numMipmaps == 0 ?
                                GL_LINEAR : GL_LINEAR_MIPMAP_NEAREST);
                
                int levelWidth = mWidth;
                int levelHeight = mHeight;
                unsigned char *levelImgData = (unsigned char *)imgData;
                
                for (int level=0; level<=properties.numMipmaps; ++level)
                {                    
                    int size = MAX(32, levelWidth * levelHeight * bitsPerPixel / 8);
                    glCompressedTexImage2D(GL_TEXTURE_2D, level, glTexFormat, 
                                           levelWidth, levelHeight, 0, size, levelImgData);
                    levelImgData += size;
                    levelWidth  /= 2; 
                    levelHeight /= 2;
                }
            }
            
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
    return [self initWithData:NULL properties:(SPTextureProperties){ .width = 32, .height = 32 }];
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

+ (SPGLTexture*)textureWithData:(const void *)imgData properties:(SPTextureProperties)properties
{
    return [[[SPGLTexture alloc] initWithData:imgData properties:properties] autorelease];
}

- (void)dealloc
{     
    glDeleteTextures(1, &mTextureID); 
    [super dealloc];
}

@end
