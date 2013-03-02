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
#import "SPQuadBatch.h"
#import "SPTexture.h"
#import "SPMacros.h"
#import "SPQuad.h"

#import <GLKit/GLKit.h>

@implementation SPRenderSupport
{
    SPMatrix *mProjectionMatrix;
    SPMatrix *mModelviewMatrix;
    SPMatrix *mMvpMatrix;
    NSMutableArray *mMatrixStack;
    int mMatrixStackSize;
    
    float *mAlphaStack;
    int mAlphaStackSize;
    
    GLKBaseEffect *mBaseEffect;
    uint mBoundTextureName;
    
    NSMutableArray *mQuadBatches;
    int mCurrentQuadBatchID;
}

@synthesize usingPremultipliedAlpha = mPremultipliedAlpha;
@synthesize modelviewMatrix = mModelviewMatrix;
@synthesize projectionMatrix = mProjectionMatrix;

- (id)init
{
    if ((self = [super init]))
    {
        mProjectionMatrix = [[SPMatrix alloc] init];
        mModelviewMatrix  = [[SPMatrix alloc] init];
        mMvpMatrix        = [[SPMatrix alloc] init];
        
        mMatrixStack = [[NSMutableArray alloc] initWithCapacity:16];
        mMatrixStackSize = 0;
        
        mAlphaStack = calloc(SP_MAX_DISPLAY_TREE_DEPTH, sizeof(float));
        mAlphaStack[0] = 1.0f;
        mAlphaStackSize = 1;
        
        mBaseEffect = [[GLKBaseEffect alloc] init];
        
        mQuadBatches = [[NSMutableArray alloc] initWithObjects:[[SPQuadBatch alloc] init], nil];
        mCurrentQuadBatchID = 0;
        
        [self loadIdentity];
        [self setupOrthographicProjectionWithLeft:0 right:320 top:0 bottom:480];
    }
    return self;
}

- (void)dealloc
{
    free(mAlphaStack);
}

- (void)nextFrame
{
    [self resetMatrix];
    mCurrentQuadBatchID = 0;
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
    if (error != 0) NSLog(@"There was an OpenGL error: 0x%x", error);
    return error;
}

#pragma mark - alpha stack

- (float)pushAlpha:(float)alpha
{
    if (mAlphaStackSize < SP_MAX_DISPLAY_TREE_DEPTH)
    {
        float newAlpha = mAlphaStack[mAlphaStackSize-1] * alpha;
        mAlphaStack[mAlphaStackSize++] = newAlpha;
        return newAlpha;
    }
    else
    {
        [NSException raise:SP_EXC_INVALID_OPERATION format:@"The display tree is too deep"];
        return 0.0f;
    }
}

- (float)popAlpha
{
    if (mAlphaStackSize > 0)
        --mAlphaStackSize;
    
    return mAlphaStack[mAlphaStackSize-1];
}

- (float)alpha
{
    return mAlphaStack[mAlphaStackSize-1];
}

#pragma mark - matrix manipulation

- (void)loadIdentity
{
    [mModelviewMatrix identity];
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
    [currentMatrix copyFromMatrix:mModelviewMatrix];
}

- (void)popMatrix
{
    SPMatrix *currentMatrix = mMatrixStack[--mMatrixStackSize];
    [mModelviewMatrix copyFromMatrix:currentMatrix];
}

- (void)setupOrthographicProjectionWithLeft:(float)left right:(float)right
                                        top:(float)top bottom:(float)bottom;
{
    [mProjectionMatrix setA:2.0f/(right-left) b:0.0f c:0.0f d:2.0f/(top-bottom)
                         tx:-(right+left) / (right-left)
                         ty:-(top+bottom) / (top-bottom)];
    
    mBaseEffect.transform.projectionMatrix = [mProjectionMatrix convertToGLKMatrix4];
}

- (void)prependMatrix:(SPMatrix *)matrix
{
    [mModelviewMatrix prependMatrix:matrix];
}

- (SPMatrix *)mvpMatrix
{
    [mMvpMatrix copyFromMatrix:mModelviewMatrix];
    [mMvpMatrix appendMatrix:mProjectionMatrix];
    return mMvpMatrix;
}

#pragma mark - rendering

- (void)batchQuad:(SPQuad *)quad texture:(SPTexture *)texture
{
    if ([self.currentQuadBatch isStateChangeWithQuad:quad texture:texture numQuads:1])
        [self finishQuadBatch];
    
    [self.currentQuadBatch addQuad:quad texture:texture alpha:self.alpha matrix:mModelviewMatrix];
}

- (void)finishQuadBatch
{
    SPQuadBatch *currentBatch = self.currentQuadBatch;
    
    if (currentBatch.numQuads)
    {
        [currentBatch renderWithAlpha:1.0f matrix:mProjectionMatrix];
        [currentBatch reset];
        
        ++mCurrentQuadBatchID;
        
        if (mQuadBatches.count <= mCurrentQuadBatchID)
            [mQuadBatches addObject:[[SPQuadBatch alloc] init]];
    }
}

- (SPQuadBatch *)currentQuadBatch
{
    return mQuadBatches[mCurrentQuadBatchID];
}

@end
