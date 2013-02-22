//
//  SPSubTexture.m
//  Sparrow
//
//  Created by Daniel Sperl on 27.06.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPSubTexture.h"
#import "SPVertexData.h"
#import "SPRectangle.h"
#import "SPMacros.h"

@implementation SPSubTexture
{
    SPTexture *mBaseTexture;
    SPRectangle *mClipping;
    SPRectangle *mRootClipping;
    SPRectangle *mFrame;
}

@synthesize baseTexture = mBaseTexture;
@synthesize clipping = mClipping;
@synthesize frame = mFrame;

- (id)initWithRegion:(SPRectangle*)region ofTexture:(SPTexture*)texture
{
    return [self initWithRegion:region frame:nil ofTexture:texture];
}

- (id)initWithRegion:(SPRectangle *)region frame:(SPRectangle *)frame ofTexture:(SPTexture *)texture
{
    if ((self = [super init]))
    {
        mBaseTexture = texture;
        mFrame = [frame copy];
        
        // convert region to clipping rectangle (which has values between 0 and 1)
        if (region)
            self.clipping = [SPRectangle rectangleWithX:region.x/texture.width
                                                      y:region.y/texture.height
                                                  width:region.width/texture.width
                                                 height:region.height/texture.height];
        else
            self.clipping = [SPRectangle rectangleWithX:0.0f y:0.0f width:1.0f height:1.0f];
    }
    return self;
}

- (id)init
{
    return nil;
}

- (void)setClipping:(SPRectangle *)clipping
{
    // private method! Only called via the constructor - thus we don't need to create a copy.
    mClipping = clipping;
    
    // if the base texture is a sub texture as well, calculate clipping 
    // in reference to the root texture         
    mRootClipping = [mClipping copy];
    SPTexture *baseTexture = mBaseTexture;
    while ([baseTexture isKindOfClass:[SPSubTexture class]])
    {
        SPSubTexture *baseSubTexture = (SPSubTexture *)baseTexture;
        SPRectangle *baseClipping = baseSubTexture->mClipping;
        
        mRootClipping.x = baseClipping.x + mRootClipping.x * baseClipping.width;
        mRootClipping.y = baseClipping.y + mRootClipping.y * baseClipping.height;
        mRootClipping.width *= baseClipping.width;
        mRootClipping.height *= baseClipping.height;
        
        baseTexture = baseSubTexture.baseTexture;
    } 
}

- (void)adjustVertexData:(SPVertexData *)vertexData atIndex:(int)index numVertices:(int)count
{
    if (mFrame)
    {
        if (count != 4)
            [NSException raise:SP_EXC_INVALID_OPERATION
                        format:@"Textures with a frame can only be used on quads"];
        
        float deltaRight  = mFrame.width  + mFrame.x - self.width;
        float deltaBottom = mFrame.height + mFrame.y - self.height;
        
        vertexData.vertices[index].position.x -= mFrame.x;
        vertexData.vertices[index].position.y -= mFrame.y;
        
        vertexData.vertices[index+1].position.x -= deltaRight;
        vertexData.vertices[index+1].position.y -= mFrame.y;

        vertexData.vertices[index+2].position.x -= mFrame.x;
        vertexData.vertices[index+2].position.y -= deltaBottom;
        
        vertexData.vertices[index+3].position.x -= deltaRight;
        vertexData.vertices[index+3].position.y -= deltaBottom;
    }
    
    float clipX = mRootClipping.x;
    float clipY = mRootClipping.y;
    float clipWidth = mRootClipping.width;
    float clipHeight = mRootClipping.height;
    
    for (int i=index; i<index+count; ++i)
    {
        GLKVector2 texCoords = vertexData.vertices[i].texCoords;
        vertexData.vertices[i].texCoords.x = clipX + texCoords.x * clipWidth;
        vertexData.vertices[i].texCoords.y = clipY + texCoords.y * clipHeight;
    }
}

- (float)width
{
    return mBaseTexture.width * mClipping.width;
}

- (float)height
{
    return mBaseTexture.height * mClipping.height;
}

- (uint)name
{
    return mBaseTexture.name;
}

- (void)setRepeat:(BOOL)value
{
    mBaseTexture.repeat = value;
}

- (BOOL)repeat
{
    return mBaseTexture.repeat;
}

- (SPTextureSmoothing)smoothing
{    
    return mBaseTexture.smoothing;
}

- (void)setSmoothing:(SPTextureSmoothing)value
{
    mBaseTexture.smoothing = value;
}

- (BOOL)premultipliedAlpha
{
    return mBaseTexture.premultipliedAlpha;
}

- (float)scale
{
    return mBaseTexture.scale;
}

+ (id)textureWithRegion:(SPRectangle*)region ofTexture:(SPTexture*)texture
{
    return [[self alloc] initWithRegion:region ofTexture:texture];
}

@end
