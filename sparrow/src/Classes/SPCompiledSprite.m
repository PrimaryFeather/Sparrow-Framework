//
//  SPCompiledContainer.m
//  Sparrow
//
//  Created by Daniel Sperl on 15.07.10.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPCompiledSprite.h"
#import "SPDisplayObjectContainer.h"
#import "SPPoint.h"
#import "SPMatrix.h"
#import "SPImage.h"
#import "SPQuad.h"
#import "SPTexture.h"
#import "SPRenderSupport.h"
#import "SPMacros.h"

#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

// --- SPQuad extension ----------------------------------------------------------------------------

@interface SPQuad (SPCompiledSprite_Extension)

- (void)copyVertexCoords:(float *)vertexCoords colors:(uint *)colors textureCoords:(float *)texCoords;

@end

@implementation SPQuad (SPCompiledSprite_Extension)

- (void)copyVertexCoords:(float *)vertexCoords colors:(uint *)colors textureCoords:(float *)texCoords
{
    if (vertexCoords) memcpy(vertexCoords, mVertexCoords, 8 * sizeof(float));
    if (colors)       memcpy(colors, mVertexColors, 4 * sizeof(uint));    
}

@end

// --- SPImage extension ---------------------------------------------------------------------------

@implementation SPImage (SPCompiledSprite_Extension)

- (void)copyVertexCoords:(float *)vertexCoords colors:(uint *)colors textureCoords:(float *)texCoords
{
    [super copyVertexCoords:vertexCoords colors:colors textureCoords:texCoords];    
    if (texCoords) memcpy(texCoords, mTexCoords, 8 * sizeof(float));
}

@end

// --- private interface ---------------------------------------------------------------------------

@interface SPCompiledSprite ()

- (BOOL)processVerticesOfObject:(SPDisplayObject *)object withMatrices:(NSMutableArray *)matrices
                     vertexData:(NSMutableData *)vertexData buffer:(void *)buffer;
- (BOOL)processColorsOfObject:(SPDisplayObject *)object withAlpha:(float)alpha
                    colorData:(NSMutableData *)colorData buffer:(void *)buffer;
- (BOOL)processTexturesOfObject:(SPDisplayObject *)object withTextures:(NSMutableArray *)textures
                   texCoordData:(NSMutableData *)texCoordData buffer:(void *)buffer;
- (void)updateColorData;
- (void)deleteBuffers;

@end

// --- class implementation ------------------------------------------------------------------------

@implementation SPCompiledSprite

- (id)init
{
    return [super init];
}

+ (SPCompiledSprite *)sprite
{
    return [[[SPCompiledSprite alloc] init] autorelease];
}

- (void)dealloc
{
    free(mCurrentColors);
    [mTextureSwitches release];
    [mColorData release];    
    [self deleteBuffers];
    [super dealloc];
}

- (BOOL)compile
{    
    SP_CREATE_POOL(pool);

    [self deleteBuffers];
    [mTextureSwitches release];
    [mColorData release];    
    
    free(mCurrentColors);
    mCurrentColors = nil;
    
    // inform all children about upcoming compilation
    [self broadcastEvent:[SPEvent eventWithType:SP_EVENT_TYPE_COMPILE]];
    
    void *scratchBuffer = malloc(MAX(8 * sizeof(float), 4 * sizeof(uint)));    
    
    NSMutableData *vertexData   = [[NSMutableData alloc] init];    
    NSMutableData *colorData    = [[NSMutableData alloc] init];
    NSMutableData *texCoordData = [[NSMutableData alloc] init];
    
    NSMutableArray *matrices = [[NSMutableArray alloc] initWithObjects:
                                [SPMatrix matrixWithIdentity], nil];    
    NSMutableArray *textures = [[NSMutableArray alloc] initWithObjects:
                                [NSNull null], [NSNumber numberWithInt:0], nil];    

    BOOL success;
    
    do
    {
        // compilation is done with an alpha of 1.0f, to get unscaled color data
        float originalAlpha = self.alpha;
        self.alpha = 1.0f;
        
        success = [self processVerticesOfObject:self withMatrices:matrices 
                                     vertexData:vertexData buffer:scratchBuffer];
        if (!success) break;
   
        success = [self processColorsOfObject:self withAlpha:self.alpha 
                                    colorData:colorData buffer:scratchBuffer];        
        if (!success) break;
        
        success = [self processTexturesOfObject:self withTextures:textures 
                                   texCoordData:texCoordData buffer:scratchBuffer];
        
        self.alpha = originalAlpha;
        
    } while (NO);
    
    if (success)
    {
        glGenBuffers(4, &mIndexBuffer);
        
        int numVertices = [vertexData length] / sizeof(float) / 2; 
        int numQuads = numVertices / 4;
        int indexBufferSize = numQuads * 6; // 4 + 2 for degenerate triangles
        GLushort *indices = malloc(indexBufferSize * sizeof(GLushort));
        
        int pos = 0;
        for (int i=0; i<numQuads; ++i)
        {
            indices[pos++] = (GLushort)(i*4);
            for (int j=0; j<4; ++j) indices[pos++] = (GLushort)(i*4 + j);
            indices[pos++] = (GLushort)(i*4 + 3);
        }
        
        // index buffer
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, mIndexBuffer);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, indexBufferSize * sizeof(GLushort), indices, GL_STATIC_DRAW);                
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
        free(indices);
        
        // vertex buffer
        glBindBuffer(GL_ARRAY_BUFFER, mVertexBuffer);
        glBufferData(GL_ARRAY_BUFFER, vertexData.length, vertexData.bytes, GL_STATIC_DRAW);

        // color buffer
        glBindBuffer(GL_ARRAY_BUFFER, mColorBuffer);
        glBufferData(GL_ARRAY_BUFFER, colorData.length, colorData.bytes, GL_DYNAMIC_DRAW);
                
        // texture coordinate buffer
        glBindBuffer(GL_ARRAY_BUFFER, mTexCoordBuffer);
        glBufferData(GL_ARRAY_BUFFER, texCoordData.length, texCoordData.bytes, GL_STATIC_DRAW);        
        
        glBindBuffer(GL_ARRAY_BUFFER, 0);
    }
    else
    {
        [textures release];
        [colorData release];
        textures = nil;
        colorData = nil;
    }
    
    mTextureSwitches = textures;
    mColorData = colorData;
    
    [matrices release];
    [vertexData release];    
    [texCoordData release];
    
    free(scratchBuffer);    
    
    SP_RELEASE_POOL(pool);    
    return success;
}

- (BOOL)processVerticesOfObject:(SPDisplayObject *)object withMatrices:(NSMutableArray *)matrices
                     vertexData:(NSMutableData *)vertexData buffer:(void *)buffer
{
    if (object.alpha == 0.0f || !object.visible) return YES;
    SPMatrix *currentMatrix = [matrices lastObject]; 
    BOOL success = YES;        
        
    if ([object isKindOfClass:[SPDisplayObjectContainer class]])
    {
        for (SPDisplayObject *child in (SPDisplayObjectContainer *)object)
        {
            SPMatrix *childMatrix = child.transformationMatrix;
            [childMatrix concatMatrix:currentMatrix];
            [matrices addObject:childMatrix];
            
            success = [self processVerticesOfObject:child withMatrices:matrices vertexData:vertexData
                                             buffer:buffer];
            [matrices removeLastObject];            
            if (!success) break;
        }
    }
    else if ([object isKindOfClass:[SPQuad class]])
    {
        SPQuad *quad = (SPQuad *)object;
        float *vertexCoords = (float *)buffer;
        [quad copyVertexCoords:vertexCoords colors:NULL textureCoords:NULL];            
        
        // if texture has a frame, adjust vertices accordingly
        float offsetX = 0.0f, offsetY = 0.0f, scaleX = 1.0f, scaleY = 1.0f;        
        if ([object isKindOfClass:[SPImage class]])
        {
            SPTexture *texture = ((SPImage *)object).texture;
            SPRectangle *frame = texture.frame;
            if (frame)
            {
                offsetX = -frame.x; scaleX = texture.width  / frame.width; 
                offsetY = -frame.y; scaleY = texture.height / frame.height;                 
            }
        }
        
        for (int i=0; i<4; ++i)
        {
            float x = vertexCoords[2*i]   * scaleX + offsetX;
            float y = vertexCoords[2*i+1] * scaleY + offsetY;
            SPPoint *vertex = [currentMatrix transformPoint:[SPPoint pointWithX:x y:y]];
            vertexCoords[2*i  ] = vertex.x;
            vertexCoords[2*i+1] = vertex.y;            
        }
        
        [vertexData appendBytes:buffer length:8 * sizeof(float)];
    }
    else
    {
        NSLog(@"Objects of type '%@' are not supported for compilation", [object class]);
        success = NO;
    }
    
    return success;
}

- (BOOL)processColorsOfObject:(SPDisplayObject *)object withAlpha:(float)alpha
                    colorData:(NSMutableData *)colorData buffer:(void *)buffer
{
    if (alpha == 0.0f || !object.visible) return YES;
    BOOL success = YES;
    
    if ([object isKindOfClass:[SPDisplayObjectContainer class]])
    {
        for (SPDisplayObject *child in (SPDisplayObjectContainer *)object)
        {
            success = [self processColorsOfObject:child withAlpha:alpha * child.alpha
                                        colorData:colorData buffer:buffer];
            if (!success) break;            
        }        
    }
    else if ([object isKindOfClass:[SPQuad class]])
    {
        SPQuad *quad = (SPQuad *)object;
        uint *colors = (uint *)buffer;            
        [quad copyVertexCoords:NULL colors:colors textureCoords:NULL];
        uint alphaBits = (GLubyte)(alpha * 255) << 24;
        
        // add alpha information
        for (int i=0; i<4; ++i)        
            colors[i] |= alphaBits;            
        
        [colorData appendBytes:colors length:4 * sizeof(uint)];
    }
    else
    {            
        success = NO;
    }    
    
    return success;
}

- (BOOL)processTexturesOfObject:(SPDisplayObject *)object withTextures:(NSMutableArray *)textures
                   texCoordData:(NSMutableData *)texCoordData buffer:(void *)buffer
{
    if (object.alpha == 0.0f || !object.visible) return YES;
    BOOL success = YES;    
        
    if ([object isKindOfClass:[SPDisplayObjectContainer class]])
    {
        for (SPDisplayObject *child in (SPDisplayObjectContainer *)object)
        {
            success = [self processTexturesOfObject:child withTextures:textures
                                       texCoordData:texCoordData buffer:buffer];
        }
    }
    else if ([object isKindOfClass:[SPQuad class]])
    {
        SPQuad *quad = (SPQuad *)object;
        SPImage *image = [object isKindOfClass:[SPImage class]] ? (SPImage *)object : nil;
                
        // process texture switches
        // (textureData contains "texture, vertexCount, texture, vertexCount, etc.")
        
        id texture = image.texture;
        id lastTexture = [textures objectAtIndex:textures.count-2];
        if ([lastTexture isKindOfClass:[NSNull class]]) lastTexture = nil;
        
        uint textureID = [texture textureID];
        uint lastTextureID = [lastTexture textureID];
        uint lastTextureVertexCount = [[textures lastObject] intValue];
        
        if (textureID != lastTextureID)
        {
            [textures addObject:texture ? texture : [NSNull null]];
            [textures addObject:[NSNumber numberWithInt:4]];
        }
        else
        {
            [textures removeLastObject];
            [textures addObject:[NSNumber numberWithInt:lastTextureVertexCount + 4]];
        }
        
        float *texCoords = (float *)buffer;
        [quad copyVertexCoords:NULL colors:NULL textureCoords:texCoords];
        
        if (textureID)
            [texture adjustTextureCoordinates:texCoords saveAtTarget:texCoords numVertices:4];
        
        [texCoordData appendBytes:texCoords length:8 * sizeof(float)];
    }
    else
    {            
        success = NO;
    }
        
    return success;    
}

- (void)setAlpha:(float)value
{
    if (value != self.alpha)
    {
        mAlphaChanged = YES;
        [super setAlpha:value];
    }
}

- (void)render:(SPRenderSupport *)support
{
    if (!mTextureSwitches) [self compile];
    if (!mCurrentColors || mAlphaChanged) [self updateColorData];
    
    int vertexOffset = 0;
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, mIndexBuffer);
    
    for (int i=0; i<mTextureSwitches.count; i+=2)
    {
        int numVertices = [[mTextureSwitches objectAtIndex:i+1] intValue];        
        if (!numVertices) continue;
        
        id texture = [mTextureSwitches objectAtIndex:i];
        if ([texture isKindOfClass:[NSNull class]]) texture = nil;
        
        int renderedVertices = (numVertices / 4) * 6;        
        [support bindTexture:texture];        
        
        if (texture)
        {        
            glBindBuffer(GL_ARRAY_BUFFER, mTexCoordBuffer);
            glEnableClientState(GL_TEXTURE_COORD_ARRAY);
            glTexCoordPointer(2, GL_FLOAT, 0, 0);
        }
        
        glBindBuffer(GL_ARRAY_BUFFER, mVertexBuffer);
        glEnableClientState(GL_VERTEX_ARRAY);
        glVertexPointer(2, GL_FLOAT, 0, 0);
        
        glBindBuffer(GL_ARRAY_BUFFER, mColorBuffer);
        glEnableClientState(GL_COLOR_ARRAY);
        glColorPointer(4, GL_UNSIGNED_BYTE, 0, 0);                
        
        glDrawElements(GL_TRIANGLE_STRIP, renderedVertices, GL_UNSIGNED_SHORT, 
                       (void *)(vertexOffset * sizeof(GLushort)));
        
        glDisableClientState(GL_VERTEX_ARRAY);
        glDisableClientState(GL_COLOR_ARRAY);
        glDisableClientState(GL_TEXTURE_COORD_ARRAY);
        
        vertexOffset += renderedVertices;
    }
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
}

- (void)updateColorData
{
    if (!mCurrentColors) 
        mCurrentColors = malloc(mColorData.length * sizeof(uint));        
    
    const uint *origColors = (const uint *)mColorData.bytes;
    uint *newColors = mCurrentColors;
    float alpha = self.alpha;
    
    for (int i=0; i<mTextureSwitches.count; i+=2)
    {
        int numVertices = [[mTextureSwitches objectAtIndex:i+1] intValue];        
        if (!numVertices) continue;
        
        id texture = [mTextureSwitches objectAtIndex:i];
        if ([texture isKindOfClass:[NSNull class]]) texture = nil;
        BOOL pma = [texture hasPremultipliedAlpha];              
        
        for (int i=0; i<numVertices; ++i)
        {
            uint origColor = *origColors;
            float vertexAlpha = (origColor >> 24) / 255.0f * alpha;
            *newColors = [SPRenderSupport convertColor:origColor alpha:vertexAlpha premultiplyAlpha:pma];
            ++origColors;
            ++newColors;
        }
    }
    
    // update buffer
    glBindBuffer(GL_ARRAY_BUFFER, mColorBuffer);
    glBufferSubData(GL_ARRAY_BUFFER, 0, mColorData.length, mCurrentColors);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    mAlphaChanged = NO;
}

- (void)deleteBuffers
{    
    glDeleteBuffers(4, &mIndexBuffer);
    mIndexBuffer = mVertexBuffer = mColorBuffer = mTexCoordBuffer = 0;
}                   

@end
