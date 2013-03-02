//
//  SPImage.m
//  Sparrow
//
//  Created by Daniel Sperl on 19.06.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPImage.h"
#import "SPPoint.h"
#import "SPTexture.h"
#import "SPGLTexture.h"
#import "SPRenderSupport.h"
#import "SPMacros.h"
#import "SPVertexData.h"

@implementation SPImage
{
    SPVertexData *mVertexDataCache;
    BOOL mVertexDataCacheInvalid;
}

@synthesize texture = mTexture;

- (id)initWithTexture:(SPTexture*)texture
{
    if (!texture) [NSException raise:SP_EXC_INVALID_OPERATION format:@"texture cannot be nil!"];
    
    SPRectangle *frame = texture.frame;    
    float width  = frame ? frame.width  : texture.width;
    float height = frame ? frame.height : texture.height;
    BOOL pma = texture.premultipliedAlpha;
    
    if ((self = [super initWithWidth:width height:height color:SP_WHITE premultipliedAlpha:pma]))
    {
        mVertexData.vertices[1].texCoords.x = 1.0f;
        mVertexData.vertices[2].texCoords.y = 1.0f;
        mVertexData.vertices[3].texCoords.x = 1.0f;
        mVertexData.vertices[3].texCoords.y = 1.0f;
        
        mTexture = texture;
        mVertexDataCache = [[SPVertexData alloc] initWithSize:4 premultipliedAlpha:pma];
        mVertexDataCacheInvalid = YES;
    }
    return self;
}

- (id)initWithContentsOfFile:(NSString *)path generateMipmaps:(BOOL)mipmaps
{
    return [self initWithTexture:[SPTexture textureWithContentsOfFile:path generateMipmaps:mipmaps]];
}

- (id)initWithContentsOfFile:(NSString*)path
{
    return [self initWithContentsOfFile:path generateMipmaps:NO];
}

- (id)initWithWidth:(float)width height:(float)height
{
    return [self initWithTexture:[SPTexture textureWithWidth:width height:height draw:NULL]];
}

- (void)setTexCoords:(SPPoint*)coords ofVertex:(int)vertexID
{
    [mVertexData setTexCoords:coords atIndex:vertexID];
    [self vertexDataDidChange];
}

- (SPPoint*)texCoordsOfVertex:(int)vertexID
{
    return [mVertexData texCoordsAtIndex:vertexID];
}

- (void)readjustSize
{
    SPRectangle *frame = mTexture.frame;    
    float width  = frame ? frame.width  : mTexture.width;
    float height = frame ? frame.height : mTexture.height;

    mVertexData.vertices[1].position.x = width;
    mVertexData.vertices[2].position.y = height;
    mVertexData.vertices[3].position.x = width;
    mVertexData.vertices[3].position.y = height;
    
    [self vertexDataDidChange];
}

- (void)vertexDataDidChange
{
    mVertexDataCacheInvalid = YES;
}

- (void)copyVertexDataTo:(SPVertexData *)targetData atIndex:(int)targetIndex
{
    if (mVertexDataCacheInvalid)
    {
        mVertexDataCacheInvalid = NO;
        [mVertexData copyToVertexData:mVertexDataCache];
        [mTexture adjustVertexData:mVertexDataCache atIndex:0 numVertices:4];
    }
    
    [mVertexDataCache copyToVertexData:targetData atIndex:targetIndex];
}

- (void)render:(SPRenderSupport *)support
{
    [support batchQuad:self texture:mTexture];
}

- (void)setTexture:(SPTexture *)value
{
    if (value == nil)
    {
        [NSException raise:SP_EXC_INVALID_OPERATION format:@"texture cannot be nil!"];
    }
    else if (value != mTexture)
    {
        mTexture = value;
        [mVertexData setPremultipliedAlpha:mTexture.premultipliedAlpha updateVertices:YES];
        [mVertexDataCache setPremultipliedAlpha:mTexture.premultipliedAlpha updateVertices:NO];
        [self vertexDataDidChange];
    }
}

+ (id)imageWithTexture:(SPTexture*)texture
{
    return [[self alloc] initWithTexture:texture];
}

+ (id)imageWithContentsOfFile:(NSString*)path
{
    return [[self alloc] initWithContentsOfFile:path];
}

@end