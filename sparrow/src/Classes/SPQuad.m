//
//  SPQuad.m
//  Sparrow
//
//  Created by Daniel Sperl on 15.03.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPQuad.h"
#import "SPRectangle.h"
#import "SPMacros.h"
#import "SPPoint.h"

@implementation SPQuad

- (id)initWithWidth:(float)width height:(float)height color:(uint)color
{
    if ((self = [super init]))
    {
        mVertexCoords[2] = width; 
        mVertexCoords[5] = height; 
        mVertexCoords[6] = width;
        mVertexCoords[7] = height;
        
        self.color = color;
    }
    return self;    
}

- (id)initWithWidth:(float)width height:(float)height
{
    return [self initWithWidth:width height:height color:SP_WHITE];
}

- (id)init
{    
    return [self initWithWidth:32 height:32];
}

- (SPRectangle*)boundsInSpace:(SPDisplayObject*)targetCoordinateSpace
{
    float minX = FLT_MAX, maxX = -FLT_MAX, minY = FLT_MAX, maxY = -FLT_MAX;
    
    if (targetCoordinateSpace == self) // optimization
    {
        for (int i=0; i<4; ++i)
        {
            float x = mVertexCoords[2*i];
            float y = mVertexCoords[2*i+1];
            minX = MIN(minX, x);
            maxX = MAX(maxX, x);
            minY = MIN(minY, y);
            maxY = MAX(maxY, y);
        }        
    }
    else
    {
        SPMatrix *transformationMatrix = [self transformationMatrixToSpace:targetCoordinateSpace];
        SPPoint *point = [[SPPoint alloc] init];
            
        for (int i=0; i<4; ++i)
        {
            point.x = mVertexCoords[2*i];
            point.y = mVertexCoords[2*i+1];
            SPPoint *transformedPoint = [transformationMatrix transformPoint:point];
            float tfX = transformedPoint.x; 
            float tfY = transformedPoint.y;
            minX = MIN(minX, tfX);
            maxX = MAX(maxX, tfX);
            minY = MIN(minY, tfY);
            maxY = MAX(maxY, tfY);
        }
        
        [point release];
    }
    
    return [SPRectangle rectangleWithX:minX y:minY width:maxX-minX height:maxY-minY];    
}

- (void)setColor:(uint)color ofVertex:(int)vertexID
{
    if (vertexID < 0 || vertexID > 3)
        [NSException raise:SP_EXC_INDEX_OUT_OF_BOUNDS format:@"invalid vertex id"];
    
    mVertexColors[vertexID] = color;
}

- (uint)colorOfVertex:(int)vertexID
{
    if (vertexID < 0 || vertexID > 3)
        [NSException raise:SP_EXC_INDEX_OUT_OF_BOUNDS format:@"invalid vertex id"];
    
    return mVertexColors[vertexID];    
}

- (void)setColor:(uint)color
{
    for (int i=0; i<4; ++i) [self setColor:color ofVertex:i];
}

- (uint)color
{
    return [self colorOfVertex:0];
}

+ (SPQuad*)quadWithWidth:(float)width height:(float)height
{
    return [[[SPQuad alloc] initWithWidth:width height:height] autorelease];
}

+ (SPQuad*)quadWithWidth:(float)width height:(float)height color:(uint)color
{
    return [[[SPQuad alloc] initWithWidth:width height:height color:color] autorelease];
}

+ (SPQuad*)quad
{
    return [[[SPQuad alloc] init] autorelease];
}

@end
