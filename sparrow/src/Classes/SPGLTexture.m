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

        GLenum glTexType = GL_UNSIGNED_BYTE;
        GLenum glTexFormat;
        int bitsPerPixel;
        BOOL compressed = NO;
        
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
                compressed = YES;
                bitsPerPixel = 2;
                glTexFormat = GL_COMPRESSED_RGBA_PVRTC_2BPPV1_IMG;
                break;
            case SPTextureFormatPvrtcRGB2:
                compressed = YES;
                bitsPerPixel = 2;
                glTexFormat = GL_COMPRESSED_RGB_PVRTC_2BPPV1_IMG;
                break;
            case SPTextureFormatPvrtcRGBA4:
                compressed = YES;
                bitsPerPixel = 4;
                glTexFormat = GL_COMPRESSED_RGBA_PVRTC_4BPPV1_IMG;
                break;
            case SPTextureFormatPvrtcRGB4:
                compressed = YES;
                bitsPerPixel = 4;
                glTexFormat = GL_COMPRESSED_RGB_PVRTC_4BPPV1_IMG;
                break;
            case SPTextureFormat565:
                bitsPerPixel = 16;
                glTexFormat = GL_RGB;
                glTexType = GL_UNSIGNED_SHORT_5_6_5;
                break;
            case SPTextureFormat5551:
                bitsPerPixel = 16;                    
                glTexFormat = GL_RGBA;
                glTexType = GL_UNSIGNED_SHORT_5_5_5_1;                    
                break;
            case SPTextureFormat4444:
                bitsPerPixel = 16;
                glTexFormat = GL_RGBA;
                glTexType = GL_UNSIGNED_SHORT_4_4_4_4;                    
                break;
        }
        
        glGenTextures(1, &mTextureID);
        glBindTexture(GL_TEXTURE_2D, mTextureID);
        
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR); 
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, mRepeat ? GL_REPEAT : GL_CLAMP_TO_EDGE); 
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, mRepeat ? GL_REPEAT : GL_CLAMP_TO_EDGE); 
       
        if (!compressed)
        {       
            if (properties.numMipmaps > 0 || properties.generateMipmaps)
                glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_NEAREST);
            else
                glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            
            if (properties.numMipmaps == 0 && properties.generateMipmaps)
                glTexParameteri(GL_TEXTURE_2D, GL_GENERATE_MIPMAP, GL_TRUE);  
            
            int levelWidth = mWidth;
            int levelHeight = mHeight;
            unsigned char *levelData = (unsigned char *)imgData;
            
            for (int level=0; level<=properties.numMipmaps; ++level)
            {                    
                int size = levelWidth * levelHeight * bitsPerPixel / 8;
                glTexImage2D(GL_TEXTURE_2D, level, glTexFormat, levelWidth, levelHeight, 
                             0, glTexFormat, glTexType, levelData);
                levelData += size;
                levelWidth  /= 2; 
                levelHeight /= 2;
            }            
        }
        else
        {
            // 'generateMipmaps' not supported for compressed textures
            
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, properties.numMipmaps == 0 ?
                            GL_LINEAR : GL_LINEAR_MIPMAP_NEAREST);
            
            int levelWidth = mWidth;
            int levelHeight = mHeight;
            unsigned char *levelData = (unsigned char *)imgData;
            
            for (int level=0; level<=properties.numMipmaps; ++level)
            {                    
                int size = MAX(32, levelWidth * levelHeight * bitsPerPixel / 8);
                glCompressedTexImage2D(GL_TEXTURE_2D, level, glTexFormat, 
                                       levelWidth, levelHeight, 0, size, levelData);
                levelData += size;
                levelWidth  /= 2; 
                levelHeight /= 2;
            }
        }
        
        glBindTexture(GL_TEXTURE_2D, 0);            

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
