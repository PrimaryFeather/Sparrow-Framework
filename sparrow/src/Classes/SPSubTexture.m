//
//  SPSubTexture.m
//  Sparrow
//
//  Created by Daniel Sperl on 27.06.09.
//  Copyright 2009 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPSubTexture.h"
#import "SPRectangle.h"

@implementation SPSubTexture

@synthesize baseTexture = mBaseTexture;
@synthesize clipping = mClipping;

- (id)initWithRegion:(SPRectangle*)region ofTexture:(SPTexture*)texture
{
    if (self = [super init])
    {
        mBaseTexture = [texture retain];
        
        // convert region to clipping rectangle (which has values between 0 and 1)        
        self.clipping = [SPRectangle rectangleWithX:region.x/texture.width
                                                  y:region.y/texture.height
                                              width:region.width/texture.width
                                             height:region.height/texture.height];               
    }
    return self;
}

- (id)init
{
    [self release];
    return nil;
}

- (void)setClipping:(SPRectangle *)clipping
{
    [mClipping release];
    mClipping = [clipping copy];
    
    // if the base texture is a sub texture as well, calculate clipping 
    // in reference to the root texture         
    [mRootClipping release];
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

- (void)adjustTextureCoordinates:(const float *)texCoords saveAtTarget:(float *)targetTexCoords 
                     numVertices:(int)numVertices
{    
    float clipX = mRootClipping.x;
    float clipY = mRootClipping.y;
    float clipWidth = mRootClipping.width;
    float clipHeight = mRootClipping.height;
    
    for (int i=0; i<numVertices; ++i)
    {
        targetTexCoords[2*i]   = clipX + texCoords[2*i]   * clipWidth; 
        targetTexCoords[2*i+1] = clipY + texCoords[2*i+1] * clipHeight;        
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

- (uint)textureID
{
    return mBaseTexture.textureID;
}

- (BOOL)hasPremultipliedAlpha
{
    return mBaseTexture.hasPremultipliedAlpha;
}

- (float)scale
{
    return mBaseTexture.scale;
}

+ (SPSubTexture*)textureWithRegion:(SPRectangle*)region ofTexture:(SPTexture*)texture
{
    return [[[SPSubTexture alloc] initWithRegion:region ofTexture:texture] autorelease];
}

- (void)dealloc
{
    [mClipping release];
    [mRootClipping release];
    [mBaseTexture release];
    [super dealloc];
}

@end
