//
//  SPVertexData.m
//  Sparrow
//
//  Created by Daniel Sperl on 18.02.13.
//  Copyright 2013 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPVertexData.h"
#import "SPMatrix.h"
#import "SPRectangle.h"
#import "SPPoint.h"
#import "SPMacros.h"

#define MIN_ALPHA (5.0f / 255.0f)

/// --- C methods ----------------------------------------------------------------------------------

SPVertexColor SPVertexColorMake(unsigned char r, unsigned char g, unsigned char b, unsigned char a)
{
    SPVertexColor vertexColor = { .r = r, .g = g, .b = b, .a = a };
    return vertexColor;
}

SPVertexColor SPVertexColorMakeWithColorAndAlpha(uint rgb, float alpha)
{
    SPVertexColor vertexColor = {
        .r = SP_COLOR_PART_RED(rgb),
        .g = SP_COLOR_PART_GREEN(rgb),
        .b = SP_COLOR_PART_BLUE(rgb),
        .a = (unsigned char)(alpha * 255.0f)
    };
    return vertexColor;
}

SPVertexColor premultiplyAlpha(SPVertexColor color)
{
    float alpha = color.a / 255.0f;
    return SPVertexColorMake(color.r * alpha,
                             color.g * alpha,
                             color.b * alpha,
                             color.a);
}

SPVertexColor unmultiplyAlpha(SPVertexColor color)
{
    float alpha = color.a / 255.0f;
    
    if (alpha != 0.0f)
        return SPVertexColorMake(color.r / alpha,
                                 color.g / alpha,
                                 color.b / alpha,
                                 color.a);
    else
        return color;
}

/// --- Class implementation -----------------------------------------------------------------------

@implementation SPVertexData
{
    SPVertex *mVertices;
    int mNumVertices;
    BOOL mPremultipliedAlpha;
}

@synthesize vertices = mVertices;
@synthesize numVertices = mNumVertices;
@synthesize premultipliedAlpha = mPremultipliedAlpha;

- (id)initWithSize:(int)numVertices premultipliedAlpha:(BOOL)pma
{
    if ((self = [super init]))
    {
        mPremultipliedAlpha = pma;
        self.numVertices = numVertices;
    }
    
    return self;
}

- (id)initWithSize:(int)numVertices
{
    return [self initWithSize:numVertices premultipliedAlpha:NO];
}

- (id)init
{
    return [self initWithSize:0];
}

- (void)dealloc
{
    free(mVertices);
}

- (void)copyToVertexData:(SPVertexData *)target
{
    [self copyToVertexData:target atIndex:0];
}

- (void)copyToVertexData:(SPVertexData *)target atIndex:(int)targetIndex
{
    if (target->mNumVertices - targetIndex < mNumVertices)
        [NSException raise:SP_EXC_INDEX_OUT_OF_BOUNDS format:@"Target too small"];
    
    memcpy(&target->mVertices[targetIndex], mVertices, sizeof(SPVertex) * mNumVertices);
}

- (SPVertex)vertexAtIndex:(int)index
{
    if (index < 0 || index >= mNumVertices)
        [NSException raise:SP_EXC_INDEX_OUT_OF_BOUNDS format:@"Invalid vertex index"];

    return mVertices[index];
}

- (void)setVertex:(SPVertex)vertex atIndex:(int)index
{
    if (index < 0 || index >= mNumVertices)
        [NSException raise:SP_EXC_INDEX_OUT_OF_BOUNDS format:@"Invalid vertex index"];

    mVertices[index] = vertex;
    
    if (mPremultipliedAlpha)
        mVertices[index].color = premultiplyAlpha(vertex.color);
}

- (SPPoint *)positionAtIndex:(int)index
{
    if (index < 0 || index >= mNumVertices)
        [NSException raise:SP_EXC_INDEX_OUT_OF_BOUNDS format:@"Invalid vertex index"];
    
    GLKVector2 position = mVertices[index].position;
    return [[SPPoint alloc] initWithX:position.x y:position.y];
}

- (void)setPosition:(SPPoint *)position atIndex:(int)index
{
    if (index < 0 || index >= mNumVertices)
        [NSException raise:SP_EXC_INDEX_OUT_OF_BOUNDS format:@"Invalid vertex index"];
    
    mVertices[index].position = GLKVector2Make(position.x, position.y);
}

- (SPPoint *)texCoordsAtIndex:(int)index
{
    if (index < 0 || index >= mNumVertices)
        [NSException raise:SP_EXC_INDEX_OUT_OF_BOUNDS format:@"Invalid vertex index"];
    
    GLKVector2 texCoords = mVertices[index].texCoords;
    return [[SPPoint alloc] initWithX:texCoords.x y:texCoords.y];
}

- (void)setTexCoords:(SPPoint *)texCoords atIndex:(int)index
{
    if (index < 0 || index >= mNumVertices)
        [NSException raise:SP_EXC_INDEX_OUT_OF_BOUNDS format:@"Invalid vertex index"];
    
    mVertices[index].texCoords = GLKVector2Make(texCoords.x, texCoords.y);
}

- (void)setColor:(uint)color alpha:(float)alpha atIndex:(int)index
{
    if (index < 0 || index >= mNumVertices)
        [NSException raise:SP_EXC_INDEX_OUT_OF_BOUNDS format:@"Invalid vertex index"];
    
    alpha = SP_CLAMP(alpha, mPremultipliedAlpha ? MIN_ALPHA : 0.0f, 1.0f);
    
    SPVertexColor vertexColor = SPVertexColorMakeWithColorAndAlpha(color, alpha);
    mVertices[index].color = mPremultipliedAlpha ? premultiplyAlpha(vertexColor) : vertexColor;
}

- (uint)colorAtIndex:(int)index
{
    if (index < 0 || index >= mNumVertices)
        [NSException raise:SP_EXC_INDEX_OUT_OF_BOUNDS format:@"Invalid vertex index"];

    SPVertexColor vertexColor = mVertices[index].color;
    if (mPremultipliedAlpha) vertexColor = unmultiplyAlpha(vertexColor);
    return SP_COLOR(vertexColor.r, vertexColor.g, vertexColor.b);
}

- (void)setColor:(uint)color atIndex:(int)index
{
    float alpha = [self alphaAtIndex:index];
    [self setColor:color alpha:alpha atIndex:index];
}

- (void)setAlpha:(float)alpha atIndex:(int)index
{
    uint color = [self colorAtIndex:index];
    [self setColor:color alpha:alpha atIndex:index];
}

- (float)alphaAtIndex:(int)index
{
    if (index < 0 || index >= mNumVertices)
        [NSException raise:SP_EXC_INDEX_OUT_OF_BOUNDS format:@"Invalid vertex index"];
    
    return mVertices[index].color.a / 255.0f;
}

- (void)scaleAlphaBy:(float)factor
{
    [self scaleAlphaBy:factor atIndex:0 numVertices:mNumVertices];
}

- (void)scaleAlphaBy:(float)factor atIndex:(int)index numVertices:(int)count
{
    if (index < 0 || index + count > mNumVertices)
        [NSException raise:SP_EXC_INDEX_OUT_OF_BOUNDS format:@"Invalid index range"];
    
    if (factor == 1.0f) return;
    
    for (int i=index; i<index+count; ++i)
    {
        SPVertex *vertex = &mVertices[i];
        SPVertexColor vertexColor = vertex->color;
        float newAlpha = vertexColor.a / 255.0f * factor;
        
        if (mPremultipliedAlpha)
        {
            vertexColor = unmultiplyAlpha(vertexColor);
            vertexColor.a = (unsigned char)(SP_CLAMP(newAlpha, MIN_ALPHA, 1.0f) * 255.0f);
            vertex->color = premultiplyAlpha(vertexColor);
        }
        else
        {
            vertex->color = SPVertexColorMake(vertexColor.r, vertexColor.g, vertexColor.b,
                                              SP_CLAMP(newAlpha, 0.0f, 1.0f) * 255.0f);
        }
    }
}

- (void)appendVertex:(SPVertex)vertex
{
    self.numVertices += 1;
    
    if (mVertices) // just to shut down an Analyzer warning ... this will never be NULL.
    {
        if (mPremultipliedAlpha) vertex.color = premultiplyAlpha(vertex.color);
        mVertices[mNumVertices-1] = vertex;
    }
}

- (void)transformVerticesWithMatrix:(SPMatrix *)matrix atIndex:(int)index numVertices:(int)count
{
    if (index < 0 || index + count > mNumVertices)
        [NSException raise:SP_EXC_INDEX_OUT_OF_BOUNDS format:@"Invalid index range"];
    
    GLKMatrix3 glkMatrix = [matrix convertToGLKMatrix3];
    
    for (int i=index; i<index+count; ++i)
    {
        GLKVector2 pos = mVertices[i].position;
        mVertices[i].position.x = glkMatrix.m00 * pos.x + glkMatrix.m10 * pos.y + glkMatrix.m20;
        mVertices[i].position.y = glkMatrix.m11 * pos.y + glkMatrix.m01 * pos.x + glkMatrix.m21;
    }
}

- (void)setNumVertices:(int)value
{
    if (value != mNumVertices)
    {
        if (value)
        {
            if (mVertices)
                mVertices = realloc(mVertices, sizeof(SPVertex) * value);
            else
                mVertices = malloc(sizeof(SPVertex) * value);
            
            if (value > mNumVertices)
            {
                memset(&mVertices[mNumVertices], 0, sizeof(SPVertex) * (value - mNumVertices));
                
                for (int i=mNumVertices; i<value; ++i)
                    mVertices[i].color = SPVertexColorMakeWithColorAndAlpha(0, 1.0f);
            }
        }
        else
        {
            free(mVertices);
            mVertices = NULL;
        }
        
        mNumVertices = value;
    }
}

- (SPRectangle *)bounds
{
    return [self boundsAfterTransformation:nil];
}

- (SPRectangle *)boundsAfterTransformation:(SPMatrix *)matrix
{
    float minX = FLT_MAX, maxX = -FLT_MAX, minY = FLT_MAX, maxY = -FLT_MAX;
    
    if (matrix)
    {
        for (int i=0; i<4; ++i)
        {
            GLKVector2 position = mVertices[i].position;
            SPPoint *transformedPoint = [matrix transformPointWithX:position.x y:position.y];
            float tfX = transformedPoint.x;
            float tfY = transformedPoint.y;
            minX = MIN(minX, tfX);
            maxX = MAX(maxX, tfX);
            minY = MIN(minY, tfY);
            maxY = MAX(maxY, tfY);
        }
    }
    else
    {
        for (int i=0; i<4; ++i)
        {
            GLKVector2 position = mVertices[i].position;
            minX = MIN(minX, position.x);
            maxX = MAX(maxX, position.x);
            minY = MIN(minY, position.y);
            maxY = MAX(maxY, position.y);
        }
    }
    
    return [SPRectangle rectangleWithX:minX y:minY width:maxX-minX height:maxY-minY];
}

- (void)setPremultipliedAlpha:(BOOL)value
{
    [self setPremultipliedAlpha:value updateVertices:YES];
}

- (void)setPremultipliedAlpha:(BOOL)value updateVertices:(BOOL)update
{
    if (value == mPremultipliedAlpha) return;
    
    if (update)
    {
        if (value)
        {
            for (int i=0; i<mNumVertices; ++i)
                mVertices[i].color = premultiplyAlpha(mVertices[i].color);
        }
        else
        {
            for (int i=0; i<mNumVertices; ++i)
                mVertices[i].color = unmultiplyAlpha(mVertices[i].color);
        }
    }
    
    mPremultipliedAlpha = value;
}

- (SPVertex *)vertices
{
    return mVertices;
}

@end
