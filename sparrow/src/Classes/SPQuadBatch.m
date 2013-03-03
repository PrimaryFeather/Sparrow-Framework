//
//  SPQuadBatch.m
//  Sparrow
//
//  Created by Daniel Sperl on 01.03.13.
//  Copyright 2013 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPQuadBatch.h"
#import "SPTexture.h"
#import "SPImage.h"
#import "SPRenderSupport.h"

#import <GLKit/GLKit.h>

@implementation SPQuadBatch
{
    int mNumQuads;
    BOOL mSyncRequired;
    
    SPTexture *mTexture;
    BOOL mPremultipliedAlpha;
    
    GLKBaseEffect *mBaseEffect;
    SPVertexData *mVertexData;
    uint mVertexBufferName;
    ushort *mIndexData;
    uint mIndexBufferName;
}

@synthesize numQuads = mNumQuads;

- (id)init
{
    if ((self = [super init]))
    {
        mNumQuads = 0;
        mSyncRequired = NO;
        mVertexData = [[SPVertexData alloc] init];
        mBaseEffect = [[GLKBaseEffect alloc] init];
        mBaseEffect.transform.projectionMatrix = GLKMatrix4Identity;
    }
    
    return self;
}

- (void)dealloc
{
    free(mIndexData);
    
    glDeleteBuffers(1, &mVertexBufferName);
    glDeleteBuffers(1, &mIndexBufferName);
}

- (void)reset
{
    mNumQuads = 0;
    mTexture = nil;
    mSyncRequired = YES;
}

- (void)expand
{
    int oldCapacity = self.capacity;
    int newCapacity = oldCapacity ? oldCapacity * 2 : 16;
    int numVertices = newCapacity * 4;
    int numIndices  = newCapacity * 6;
    
    mVertexData.numVertices = numVertices;
    
    if (!mIndexData) mIndexData = malloc(sizeof(ushort) * numIndices);
    else             mIndexData = realloc(mIndexData, sizeof(ushort) * numIndices);
    
    for (int i=oldCapacity; i<newCapacity; ++i)
    {
        mIndexData[i*6  ] = i*4;
        mIndexData[i*6+1] = i*4 + 1;
        mIndexData[i*6+2] = i*4 + 2;
        mIndexData[i*6+3] = i*4 + 1;
        mIndexData[i*6+4] = i*4 + 3;
        mIndexData[i*6+5] = i*4 + 2;
    }
    
    [self createBuffers];
}

- (void)createBuffers
{
    int numVertices = mVertexData.numVertices;
    int numIndices = numVertices / 4 * 6;
    
    if (mVertexBufferName) glDeleteBuffers(1, &mVertexBufferName);
    if (mIndexBufferName)  glDeleteBuffers(1, &mIndexBufferName);
    if (numVertices == 0)  return;
    
    glGenBuffers(1, &mVertexBufferName);
    glGenBuffers(1, &mIndexBufferName);
    
    glBindBuffer(GL_ARRAY_BUFFER, mVertexBufferName);
    glBufferData(GL_ARRAY_BUFFER, sizeof(SPVertex) * numVertices, mVertexData.vertices, GL_STATIC_DRAW);
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, mIndexBufferName);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(ushort) * numIndices, mIndexData, GL_STATIC_DRAW);
    
    mSyncRequired = NO;
}

- (void)syncBuffers
{
    if (!mVertexBufferName)
        [self createBuffers];
    else
    {
        int numVertices = mNumQuads * 4;
        glBindBuffer(GL_ARRAY_BUFFER, mVertexBufferName);
        glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(SPVertex) * numVertices, mVertexData.vertices);
        mSyncRequired = NO;
    }
}

- (void)addQuad:(SPQuad *)quad
{
    [self addQuad:quad texture:nil];
}

- (void)addQuad:(SPQuad *)quad texture:(SPTexture *)texture
{
    [self addQuad:quad texture:texture alpha:quad.alpha];
}

- (void)addQuad:(SPQuad *)quad texture:(SPTexture *)texture alpha:(float)alpha
{
    [self addQuad:quad texture:texture alpha:alpha matrix:nil];
}

- (void)addQuad:(SPQuad *)quad texture:(SPTexture *)texture alpha:(float)alpha matrix:(SPMatrix *)matrix
{
    if (!matrix) matrix = quad.transformationMatrix;
    if (mNumQuads + 1 > self.capacity) [self expand];
    if (mNumQuads == 0)
    {
        mTexture = texture;
        mPremultipliedAlpha = quad.premultipliedAlpha;
        [mVertexData setPremultipliedAlpha:quad.premultipliedAlpha updateVertices:NO];
    }
    
    int vertexID = mNumQuads * 4;
    
    [quad copyVertexDataTo:mVertexData atIndex:vertexID];
    [mVertexData transformVerticesWithMatrix:matrix atIndex:vertexID numVertices:4];
    
    if (alpha != 1.0f)
        [mVertexData scaleAlphaBy:alpha atIndex:vertexID numVertices:4];
    
    mSyncRequired = YES;
    ++mNumQuads;
}

- (BOOL)isStateChangeWithQuad:(SPQuad *)quad texture:(SPTexture *)texture numQuads:(int)numQuads
{
    if (mNumQuads == 0) return NO;
    else if (mNumQuads + numQuads > 8192) return YES; // maximum buffer size
    else if (!mTexture && !texture) return mPremultipliedAlpha != quad.premultipliedAlpha;
    else if (mTexture && texture)
        return mTexture.name != texture.name ||
               mTexture.repeat != texture.repeat ||
               mTexture.smoothing != texture.smoothing;
    else return YES;
}

- (SPRectangle *)boundsInSpace:(SPDisplayObject *)targetSpace
{
    SPMatrix *matrix = targetSpace == self ? nil : [self transformationMatrixToSpace:targetSpace];
    return [mVertexData boundsAfterTransformation:matrix];
}

- (void)render:(SPRenderSupport *)support
{
    if (mNumQuads)
    {
        [support finishQuadBatch];
        [self renderWithAlpha:support.alpha matrix:support.mvpMatrix];
    }
}

- (void)renderWithAlpha:(float)alpha matrix:(SPMatrix *)matrix
{
    if (!mNumQuads) return;
    if (mSyncRequired) [self syncBuffers];
    
    // TODO: alpha
    
    mBaseEffect.texture2d0.enabled = (mTexture != nil);
    mBaseEffect.texture2d0.name = mTexture.name;
    mBaseEffect.transform.modelviewMatrix = [matrix convertToGLKMatrix4];

    [mBaseEffect prepareToDraw];

    if (mPremultipliedAlpha) glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    else                     glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glEnableVertexAttribArray(GLKVertexAttribColor);
    
    if (mTexture)
        glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    else
        glDisableVertexAttribArray(GLKVertexAttribTexCoord0);
    
    glBindBuffer(GL_ARRAY_BUFFER, mVertexBufferName);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, mIndexBufferName);
    
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, sizeof(SPVertex),
                          (void *)(offsetof(SPVertex, position)));
    
    glVertexAttribPointer(GLKVertexAttribColor, 4, GL_UNSIGNED_BYTE, GL_TRUE, sizeof(SPVertex),
                          (void *)(offsetof(SPVertex, color)));
    
    if (mTexture)
    {
        glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(SPVertex),
                              (void *)(offsetof(SPVertex, texCoords)));
    }
    
    int numIndices = mNumQuads * 6;
    glDrawElements(GL_TRIANGLES, numIndices, GL_UNSIGNED_SHORT, 0);
}

- (int)capacity
{
    return mVertexData.numVertices / 4;
}

@end
