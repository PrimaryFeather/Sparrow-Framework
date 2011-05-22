//
//  SPRenderSupport.m
//  Sparrow
//
//  Created by Daniel Sperl on 28.09.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPRenderSupport.h"
#import "SPDisplayObject.h"
#import "SPTexture.h"
#import "SPMacros.h"

#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

@implementation SPRenderSupport

@synthesize usingPremultipliedAlpha = mPremultipliedAlpha;

- (id)init
{
    if ((self = [super init]))
    {
        [self reset];
    }
    return self;
}

- (void)reset
{
    mBoundTextureID = UINT_MAX;
    mPremultipliedAlpha = YES;
    [self bindTexture:nil];
}

- (void)bindTexture:(SPTexture *)texture
{
    uint newTextureID = texture.textureID;
    BOOL newPMA = texture.hasPremultipliedAlpha;
    
    if (newTextureID != mBoundTextureID)
        glBindTexture(GL_TEXTURE_2D, newTextureID);        
    
    if (newPMA != mPremultipliedAlpha || !mBoundTextureID)
    {
        if (newPMA) glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
        else        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    }
    
    mBoundTextureID = newTextureID;
    mPremultipliedAlpha = newPMA;
}

- (uint)convertColor:(uint)color alpha:(float)alpha
{
    return [SPRenderSupport convertColor:color alpha:alpha premultiplyAlpha:mPremultipliedAlpha];
}

+ (uint)convertColor:(uint)color alpha:(float)alpha premultiplyAlpha:(BOOL)pma
{
    if (pma)
    {
        return (GLubyte)(SP_COLOR_PART_RED(color) * alpha) |
               (GLubyte)(SP_COLOR_PART_GREEN(color) * alpha) << 8 |
               (GLubyte)(SP_COLOR_PART_BLUE(color) * alpha) << 16 |
               (GLubyte)(alpha * 255) << 24;
    }
    else
    {
        return (GLubyte)SP_COLOR_PART_RED(color) |
               (GLubyte)SP_COLOR_PART_GREEN(color) << 8 |
               (GLubyte)SP_COLOR_PART_BLUE(color) << 16 |
               (GLubyte)(alpha * 255) << 24;
    }
}

+ (void)clearWithColor:(uint)color alpha:(float)alpha;
{
    float red   = SP_COLOR_PART_RED(color)   / 255.0f;
    float green = SP_COLOR_PART_GREEN(color) / 255.0f;
    float blue  = SP_COLOR_PART_BLUE(color)  / 255.0f;
    
    glClearColor(red, green, blue, alpha);
    glClear(GL_COLOR_BUFFER_BIT);
}

+ (void)transformMatrixForObject:(SPDisplayObject *)object
{
    float x = object.x;
    float y = object.y;
    float rotation = object.rotation;
    float scaleX = object.scaleX;
    float scaleY = object.scaleY;
    float pivotX = object.pivotX;
    float pivotY = object.pivotY;
    
    if (x != 0.0f || y != 0.0f)           glTranslatef(x, y, 0.0f);
    if (rotation != 0.0f)                 glRotatef(SP_R2D(rotation), 0.0f, 0.0f, 1.0f);
    if (scaleX != 1.0f || scaleY != 1.0f) glScalef(scaleX, scaleY, 1.0f);
    if (pivotX != 0.0f || pivotY != 0.0f) glTranslatef(-pivotX, -pivotY, 0.0f);    
}

+ (void)setupOrthographicRenderingWithLeft:(float)left right:(float)right 
                                    bottom:(float)bottom top:(float)top
{
    glDisable(GL_CULL_FACE);
    glDisable(GL_LIGHTING);
    glDisable(GL_DEPTH_TEST);
    
    glEnable(GL_TEXTURE_2D);
    glEnable(GL_BLEND);
    
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrthof(left, right, bottom, top, -1.0f, 1.0f);
    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();  
}

+ (uint)checkForOpenGLError
{
    GLenum error = glGetError();
    if (error != 0) NSLog(@"Warning: There was an OpenGL error: #%d", error);
    return error;
}

@end
