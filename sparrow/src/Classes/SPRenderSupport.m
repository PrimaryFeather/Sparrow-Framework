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
{
    uint mBoundTextureID;
    BOOL mPremultipliedAlpha;
    
    SPMatrix *mProjectionMatrix;
    SPMatrix *mModelViewMatrix;
    SPMatrix *mMvpMatrix;
    NSMutableArray *mMatrixStack;
    int mMatrixStackSize;
    float *mGLMatrix;
}

@synthesize usingPremultipliedAlpha = mPremultipliedAlpha;

- (id)init
{
    if ((self = [super init]))
    {
        mProjectionMatrix = [[SPMatrix alloc] init];
        mModelViewMatrix  = [[SPMatrix alloc] init];
        mMvpMatrix        = [[SPMatrix alloc] init];
        mGLMatrix = calloc(16, sizeof(float));
        
        mMatrixStack = [[NSMutableArray alloc] initWithCapacity:16];
        mMatrixStackSize = 0;
        
        [self loadIdentity];
        [self setupOrthographicProjectionWithX:0 y:0 width:320 height:480];
    }
    return self;
}

- (void)dealloc
{
    free(mGLMatrix);
}

- (void)nextFrame
{
    mBoundTextureID = UINT_MAX;
    mPremultipliedAlpha = YES;
    [self bindTexture:nil];
    [self resetMatrix];
}

- (void)bindTexture:(SPTexture *)texture
{
    uint newTextureID = texture.textureID;
    BOOL newPMA = texture.premultipliedAlpha;
    
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

+ (uint)checkForOpenGLError
{
    GLenum error = glGetError();
    if (error != 0) NSLog(@"Warning: There was an OpenGL error: #%d", error);
    return error;
}

#pragma mark - matrix manipulation

- (void)loadIdentity
{
    [mModelViewMatrix identity];
}

- (void)resetMatrix
{
    mMatrixStackSize = 0;
    [self loadIdentity];
}

- (void)pushMatrix
{
    if (mMatrixStack.count < mMatrixStackSize + 1)
        [mMatrixStack addObject:[SPMatrix matrixWithIdentity]];
    
    SPMatrix *currentMatrix = mMatrixStack[mMatrixStackSize++];
    [currentMatrix copyFromMatrix:mModelViewMatrix];
}

- (void)popMatrix
{
    SPMatrix *currentMatrix = mMatrixStack[--mMatrixStackSize];
    [mModelViewMatrix copyFromMatrix:currentMatrix];
}

- (void)setupOrthographicProjectionWithX:(float)x y:(float)y
                                   width:(float)width height:(float)height
{
    [mProjectionMatrix setA:2.0f/width b:0.0f c:0.0f d:-2.0f/height
                         tx:-(2.0f*x + width ) / width
                         ty: (2.0f*y + height) / height];
    
    float glMatrix[16];
    [mProjectionMatrix copyToGLMatrix:glMatrix];
    
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glLoadMatrixf(glMatrix);
    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
}

- (void)prependMatrix:(SPMatrix *)matrix
{
    [mModelViewMatrix prependMatrix:matrix];
}

- (void)uploadMatrix
{
    [mModelViewMatrix copyToGLMatrix:mGLMatrix];
    
    glMatrixMode(GL_MODELVIEW);
    glLoadMatrixf(mGLMatrix);
}

@end
