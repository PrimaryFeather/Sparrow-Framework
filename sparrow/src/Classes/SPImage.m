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

#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

@implementation SPImage

@synthesize texture = mTexture;

- (id)initWithTexture:(SPTexture*)texture
{
    if (!texture) [NSException raise:SP_EXC_INVALID_OPERATION format:@"texture cannot be nil!"];
    
    SPRectangle *frame = texture.frame;    
    float width  = frame ? frame.width  : texture.width;
    float height = frame ? frame.height : texture.height;    
    
    if ((self = [super initWithWidth:width height:height]))
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

- (void)readjustSize
{
    SPRectangle *frame = mTexture.frame;    
    float width  = frame ? frame.width  : mTexture.width;
    float height = frame ? frame.height : mTexture.height;

    mVertexCoords[2] = width; 
    mVertexCoords[5] = height; 
    mVertexCoords[6] = width;
    mVertexCoords[7] = height;
}

- (void)render:(SPRenderSupport *)support
{
    static float texCoords[8];
    static uint colors[4];
    float alpha = self.alpha;
    
    [support bindTexture:mTexture];
    [mTexture adjustTextureCoordinates:mTexCoords saveAtTarget:texCoords numVertices:4];
    
    for (int i=0; i<4; ++i)
    {
        uint vertexColor = mVertexColors[i];
        float vertexAlpha = (vertexColor >> 24) / 255.0f * alpha;
        colors[i] = [support convertColor:vertexColor alpha:vertexAlpha];
    }
    
    SPRectangle *frame = mTexture.frame;
    if (frame)
    {
        glTranslatef(-frame.x, -frame.y, 0.0f);
        glScalef(mTexture.width / frame.width, mTexture.height / frame.height, 1.0f);
    }
    
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);
    
    glTexCoordPointer(2, GL_FLOAT, 0, texCoords);
    glVertexPointer(2, GL_FLOAT, 0, mVertexCoords);
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, colors);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_COLOR_ARRAY);
    
    // Rendering was tested with vertex buffers, too -- but for simple quads and images like these,
    // the overhead seems to outweigh the benefit. The "glDrawArrays"-approach is faster here.
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