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
#import "SPVertexData.h"
#import "SPTexture.h"
#import "SPMacros.h"
#import "SPQuad.h"

#import <GLKit/GLKit.h>

@implementation SPRenderSupport
{
    SPMatrix *mProjectionMatrix;
    SPMatrix *mModelViewMatrix;
    SPMatrix *mMvpMatrix;
    NSMutableArray *mMatrixStack;
    int mMatrixStackSize;
    
    GLKBaseEffect *mBaseEffect;
    uint mBoundTextureName;
    uint mFrameCount;
}

@synthesize usingPremultipliedAlpha = mPremultipliedAlpha;

- (id)init
{
    if ((self = [super init]))
    {
        mProjectionMatrix = [[SPMatrix alloc] init];
        mModelViewMatrix  = [[SPMatrix alloc] init];
        mMvpMatrix        = [[SPMatrix alloc] init];
        
        mMatrixStack = [[NSMutableArray alloc] initWithCapacity:16];
        mMatrixStackSize = 0;
        
        mBaseEffect = [[GLKBaseEffect alloc] init];
        
        [self loadIdentity];
        [self setupOrthographicProjectionWithLeft:0 right:320 top:0 bottom:480];
    }
    return self;
}

- (void)nextFrame
{
    [self resetMatrix];
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
    if (error != 0) NSLog(@"Warning: There was an OpenGL error: 0x%x", error);
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

- (void)setupOrthographicProjectionWithLeft:(float)left right:(float)right
                                        top:(float)top bottom:(float)bottom;
{
    [mProjectionMatrix setA:2.0f/(right-left) b:0.0f c:0.0f d:2.0f/(top-bottom)
                         tx:-(right+left) / (right-left)
                         ty:-(top+bottom) / (top-bottom)];
    
    mBaseEffect.transform.projectionMatrix = [mProjectionMatrix convertToGLKMatrix];
}

- (void)prependMatrix:(SPMatrix *)matrix
{
    [mModelViewMatrix prependMatrix:matrix];
}

#pragma mark - rendering

- (void)renderQuad:(SPQuad *)quad parentAlpha:(float)parentAlpha texture:(SPTexture *)texture
{
    static SPVertexData *vertexData = nil;
    if (!vertexData) vertexData = [[SPVertexData alloc] initWithSize:4];
    
    [vertexData setPremultipliedAlpha:quad.premultipliedAlpha updateVertices:NO];
    [quad copyVertexDataTo:vertexData atIndex:0];
    
    uint textureName = texture.name;
    
    if (textureName != mBoundTextureName || mFrameCount == 0)
    {
        mBaseEffect.texture2d0.enabled = (texture != nil);
        mBaseEffect.texture2d0.name = textureName;
        mBoundTextureName = textureName;
        
        if (quad.premultipliedAlpha) glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
        else                         glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        
        glEnableVertexAttribArray(GLKVertexAttribPosition);
        glEnableVertexAttribArray(GLKVertexAttribColor);
        
        if (texture)
            glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
        else
            glDisableVertexAttribArray(GLKVertexAttribTexCoord0);
    }
    
    mBaseEffect.transform.modelviewMatrix = [mModelViewMatrix convertToGLKMatrix];
    [mBaseEffect prepareToDraw];
    
    long vertices = (long)vertexData.vertices;
    
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, sizeof(SPVertex),
                          (void *)(vertices + offsetof(SPVertex, position)));
    
    glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, sizeof(SPVertex),
                          (void *)(vertices + offsetof(SPVertex, color)));
    
    if (texture)
    {
        glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(SPVertex),
                              (void *)(vertices + offsetof(SPVertex, texCoords)));
    }
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    ++mFrameCount;
}

@end
