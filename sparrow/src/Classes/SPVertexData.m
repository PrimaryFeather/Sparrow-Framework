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
#import "SPFunctions.h"

/// --- C methods ----------------------------------------------------------------------------------

void premultiplyAlpha(SPVertex *vertex)
{
    GLKVector4 color = vertex->color;
    vertex->color.r = color.r * color.a;
    vertex->color.g = color.g * color.a;
    vertex->color.b = color.b * color.a;
}

void unmultiplyAlpha(SPVertex *vertex)
{
    GLKVector4 color = vertex->color;
    if (color.a != 0.0f)
    {
        vertex->color.r = color.r / color.a;
        vertex->color.g = color.g / color.a;
        vertex->color.b = color.b / color.a;
    }
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
        mNumVertices = numVertices;
        mVertices = calloc(numVertices, sizeof(SPVertex));
        mPremultipliedAlpha = pma;
        
        for (int i=0; i<numVertices; ++i)
            mVertices[i].color.a = 1.0f; // alpha should be '1' per default
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

- (void)copyToVertexData:(SPVertexData *)target
{
    [self copyToVertexData:target atIndex:0];
}

- (void)copyToVertexData:(SPVertexData *)target atIndex:(int)targetIndex
{
    if (target.numVertices - targetIndex < mNumVertices)
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
        premultiplyAlpha(&mVertices[index]);
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

- (void)setColor:(int)color alpha:(float)alpha atIndex:(int)index
{
    if (index < 0 || index >= mNumVertices)
        [NSException raise:SP_EXC_INDEX_OUT_OF_BOUNDS format:@"Invalid vertex index"];
    
    alpha = SP_CLAMP(alpha, 0.0f, 1.0f);
    float multiplier = 1.0f / 255.0f;
    
    if (mPremultipliedAlpha)
    {
        alpha = MAX(0.001f, alpha); // zero alpha would wipe out all color data
        multiplier *= alpha;
    }
    
    mVertices[index].color.r = SP_COLOR_PART_RED(color)   * multiplier;
    mVertices[index].color.g = SP_COLOR_PART_GREEN(color) * multiplier;
    mVertices[index].color.b = SP_COLOR_PART_BLUE(color)  * multiplier;
    mVertices[index].color.a = alpha;
}

- (uint)colorAtIndex:(int)index
{
    if (index < 0 || index >= mNumVertices)
        [NSException raise:SP_EXC_INDEX_OUT_OF_BOUNDS format:@"Invalid vertex index"];

    GLKVector4 color = mVertices[index].color;
    float alpha = color.a;
    
    if (mPremultipliedAlpha && alpha != 0.0f)
    {
        color.r /= alpha;
        color.g /= alpha;
        color.b /= alpha;
    }
    
    return GLKVector4ToSPColor(color);
}

- (void)setColor:(uint)color atIndex:(int)index
{
    float alpha = mVertices[index].color.a;
    [self setColor:color alpha:alpha atIndex:index];
}

- (void)setAlpha:(float)alpha atIndex:(int)index
{
    if (index < 0 || index >= mNumVertices)
        [NSException raise:SP_EXC_INDEX_OUT_OF_BOUNDS format:@"Invalid vertex index"];
    
    if (mPremultipliedAlpha)
    {
        uint color = [self colorAtIndex:index];
        [self setColor:color alpha:alpha atIndex:index];
    }
    else
    {
        mVertices[index].color.a = alpha;
    }
}

- (float)alphaAtIndex:(int)index
{
    if (index < 0 || index >= mNumVertices)
        [NSException raise:SP_EXC_INDEX_OUT_OF_BOUNDS format:@"Invalid vertex index"];
    
    return mVertices[index].color.a;
}

- (void)appendVertex:(SPVertex)vertex
{
    self.numVertices += 1;
    mVertices[mNumVertices-1] = vertex;
    
    if (mPremultipliedAlpha)
        premultiplyAlpha(&mVertices[mNumVertices-1]);
}

- (void)setNumVertices:(int)value
{
    if (value != mNumVertices)
    {
        mVertices = realloc(mVertices, sizeof(SPVertex) * value);
        
        if (value > mNumVertices)
        {
            memset(&mVertices[mNumVertices], 0, sizeof(SPVertex) * (value - mNumVertices));

            for (int i=mNumVertices; i<value; ++i)
                mVertices[i].color.a = 1.0f; // alpha should be '1' per default
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
                premultiplyAlpha(&mVertices[i]);
        }
        else
        {
            for (int i=0; i<mNumVertices; ++i)
                unmultiplyAlpha(&mVertices[i]);
        }
    }
    
    mPremultipliedAlpha = value;
}

- (SPVertex *)vertices
{
    return mNumVertices ? mVertices : NULL;
}

@end
