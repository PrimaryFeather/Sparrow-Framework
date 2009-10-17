//
//  SPQuad.m
//  Sparrow
//
//  Created by Daniel Sperl on 15.03.09.
//  Copyright 2009 Incognitek. All rights reserved.
//

#import "SPQuad.h"
#import "SPRectangle.h"
#import "SPMacros.h"
#import "SPPoint.h"

@implementation SPQuad

- (id)initWithWidth:(float)width height:(float)height
{
    if (self = [super init])
    {
        mWidth = width;
        mHeight = height;
        self.color = SP_WHITE;
    }
    return self;    
}

- (id)init
{    
    return [self initWithWidth:32 height:32];
}

- (SPRectangle*)boundsInSpace:(SPDisplayObject*)targetCoordinateSpace
{
    SPMatrix *transformationMatrix = [self transformationMatrixToSpace:targetCoordinateSpace];
    SPPoint *point = [[SPPoint alloc] init];    
    float coords[] = { 0.0f, 0.0f, mWidth, 0.0f, mWidth, mHeight, 0.0f, mHeight };
    float minX = FLT_MAX, maxX = -FLT_MAX, minY = FLT_MAX, maxY = -FLT_MAX;
    for (int i=0; i<4; ++i)
    {
        point.x = coords[2*i];
        point.y = coords[2*i+1];
        SPPoint *transformedPoint = [transformationMatrix transformPoint:point];
        minX = MIN(minX, transformedPoint.x);
        maxX = MAX(maxX, transformedPoint.x);
        minY = MIN(minY, transformedPoint.y);
        maxY = MAX(maxY, transformedPoint.y);
    }
    [point release];
    return [SPRectangle rectangleWithX:minX y:minY width:maxX-minX height:maxY-minY];    
}

- (void)setColor:(uint)color ofVertex:(int)vertexID
{
    vertexID = MAX(0, MIN(3, vertexID));
    mVertexColors[vertexID] = color;
}

- (uint)colorOfVertex:(int)vertexID
{
    vertexID = MAX(0, MIN(3, vertexID));
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

@end
