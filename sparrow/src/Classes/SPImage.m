//
//  SPImage.m
//  Sparrow
//
//  Created by Daniel Sperl on 19.06.09.
//  Copyright 2009 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPImage.h"
#import "SPPoint.h"
#import "SPTexture.h"
#import "SPGLTexture.h"

@implementation SPImage

@synthesize texture = mTexture;

- (id)initWithTexture:(SPTexture*)texture;
{
    if (!texture) [NSException raise:SP_EXC_INVALID_OPERATION format:@"texture cannot be nil!"];
    
    if (self = [super initWithWidth:texture.width height:texture.height])
    {
        self.texture = texture;
        mTexCoords[0] = 0.0f; mTexCoords[1] = 0.0f;
        mTexCoords[2] = 1.0f; mTexCoords[3] = 0.0f;
        mTexCoords[4] = 0.0f; mTexCoords[5] = 1.0f;
        mTexCoords[6] = 1.0f; mTexCoords[7] = 1.0f;
    }
    return self;
}

- (id)initWithContentsOfFile:(NSString*)path
{
    return [self initWithTexture:[SPTexture textureWithContentsOfFile:path]];
}

- (id)initWithWidth:(float)width height:(float)height
{
    SPTextureProperties properties = { .width = width, .height = height };
    return [self initWithTexture:[SPGLTexture textureWithData:NULL properties:properties]];
}

- (void)setTexCoords:(SPPoint*)coords ofVertex:(int)vertexID
{
    if (vertexID < 0 || vertexID > 3)
        [NSException raise:SP_EXC_INDEX_OUT_OF_BOUNDS format:@"invalid vertex id"];
    
    mTexCoords[2*vertexID  ] = coords.x;
    mTexCoords[2*vertexID+1] = coords.y;    
}

- (SPPoint*)texCoordsOfVertex:(int)vertexID
{
    if (vertexID < 0 || vertexID > 3)
        [NSException raise:SP_EXC_INDEX_OUT_OF_BOUNDS format:@"invalid vertex id"];
    
    return [SPPoint pointWithX:mTexCoords[vertexID*2] y:mTexCoords[vertexID*2+1]];
}

+ (SPImage*)imageWithTexture:(SPTexture*)texture
{
    return [[[SPImage alloc] initWithTexture:texture] autorelease];
}

+ (SPImage*)imageWithContentsOfFile:(NSString*)path
{
    return [[[SPImage alloc] initWithContentsOfFile:path] autorelease];
}

- (void)dealloc
{
    [mTexture release];
    [super dealloc];
}

@end