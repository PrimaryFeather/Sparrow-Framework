//
//  SPRenderTexture.m
//  Sparrow
//
//  Created by Daniel Sperl on 04.12.10.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPRenderTexture.h"
#import "SPGLTexture.h"
#import "SPMacros.h"
#import "SPUtils.h"
#import "SPStage.h"

@interface SPRenderTexture ()

- (void)createFramebuffer;
- (void)destroyFramebuffer;
- (void)renderToFramebuffer:(SPDrawingBlock)block;

@end

@implementation SPRenderTexture

- (id)initWithWidth:(float)width height:(float)height fillColor:(uint)argb scale:(float)scale
{
    if ((self = [super init]))
    {
        int legalWidth  = [SPUtils nextPowerOfTwo:width  * scale];
        int legalHeight = [SPUtils nextPowerOfTwo:height * scale];
        
        SPTextureProperties properties = {    
            .format = SPTextureFormatRGBA,
            .width  = legalWidth,
            .height = legalHeight,
            .generateMipmaps = NO,
            .premultipliedAlpha = NO
        };        
        
        SPGLTexture *glTexture = [[SPGLTexture alloc] initWithData:NULL properties:properties];    
        glTexture.scale = scale;
        
        SPRectangle *region = [SPRectangle rectangleWithX:0 y:0 width:width height:height];
        mTexture = [[SPTexture alloc] initWithRegion:region ofTexture:glTexture];
        [glTexture release];        
        
        mRenderSupport = [[SPRenderSupport alloc] init];
        
        [self createFramebuffer];        
        [self clearWithColor:argb alpha:SP_COLOR_PART_ALPHA(argb)];
    }
    return self;
}

- (id)initWithWidth:(float)width height:(float)height fillColor:(uint)argb
{
    return [self initWithWidth:width height:height fillColor:argb scale:[SPStage contentScaleFactor]];
}

- (id)initWithWidth:(float)width height:(float)height
{
    return [self initWithWidth:width height:height fillColor:0x0];
}

- (id)init
{
    return [self initWithWidth:256 height:256];    
}

- (void)dealloc
{
    [mTexture release];
    [mRenderSupport release];
    [self destroyFramebuffer];
    [super dealloc];
}

- (void)createFramebuffer 
{
    // create framebuffer
    glGenFramebuffersOES(1, &mFramebuffer);
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, mFramebuffer);
    
    // attach renderbuffer
    glFramebufferTexture2DOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_TEXTURE_2D, 
                              mTexture.textureID, 0);
    
    if (glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES)
        NSLog(@"failed to create frame buffer for render texture");
    
    // unbind frame buffer
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, 0);
}

- (void)destroyFramebuffer 
{
    glDeleteFramebuffersOES(1, &mFramebuffer);
    mFramebuffer = 0;
}

- (void)renderToFramebuffer:(SPDrawingBlock)block
{
    if (!block) return;
    
    // the block may call a draw-method again, so we're making sure that the frame buffer switching
    // happens only in the outermost block.
    
    int stdFramebuffer = -1;
    
    if (!mFramebufferIsActive)
    {
        mFramebufferIsActive = YES;
        
        // remember standard frame buffer        
        glGetIntegerv(GL_FRAMEBUFFER_BINDING_OES, &stdFramebuffer);
        
        // switch to the texture's framebuffer for rendering
        glBindFramebufferOES(GL_FRAMEBUFFER_OES, mFramebuffer);
        
        // prepare viewport and OpenGL matrices
        glViewport(0, 0, mTexture.width * mTexture.scale, mTexture.height * mTexture.scale);
        [SPRenderSupport setupOrthographicRenderingWithLeft:0 right:mTexture.width
                                                     bottom:0 top:mTexture.height];
        
        // reset texture binding
        [mRenderSupport reset];
    }    
   
    block();
    
    if (stdFramebuffer != -1)
    {
        mFramebufferIsActive = NO;
        
        // return to standard frame buffer
        glBindFramebufferOES(GL_FRAMEBUFFER_OES, stdFramebuffer);
    }
}

- (void)drawObject:(SPDisplayObject *)object
{
    [self renderToFramebuffer:^
     {
         glPushMatrix();
         
         [SPRenderSupport transformMatrixForObject:object];         
         [object render:mRenderSupport];
         
         glPopMatrix();
     }];
}

- (void)bundleDrawCalls:(SPDrawingBlock)block
{
    [self renderToFramebuffer:block];
}

- (void)clearWithColor:(uint)color alpha:(float)alpha
{
    [self renderToFramebuffer:^
     {
         [SPRenderSupport clearWithColor:color alpha:alpha];
     }];
}

- (void)adjustTextureCoordinates:(const float *)texCoords saveAtTarget:(float *)targetTexCoords 
                     numVertices:(int)numVertices
{
    [mTexture adjustTextureCoordinates:texCoords saveAtTarget:targetTexCoords numVertices:numVertices];
}

- (float)width
{
    return mTexture.width;
}

- (float)height
{
    return mTexture.height;
}

- (void)setRepeat:(BOOL)value
{
    mTexture.repeat = value;
}

- (BOOL)repeat
{
    return mTexture.repeat;
}

- (SPTextureFilter)filter
{
    return mTexture.filter;
}

- (void)setFilter:(SPTextureFilter)value
{
    mTexture.filter = value;
}

- (uint)textureID
{
    return mTexture.textureID;
}

- (BOOL)hasPremultipliedAlpha
{
    return mTexture.hasPremultipliedAlpha;
}

- (float)scale
{
    return mTexture.scale;
}

+ (SPRenderTexture *)textureWithWidth:(float)width height:(float)height
{
    return [[[SPRenderTexture alloc] initWithWidth:width height:height] autorelease];    
}

+ (SPRenderTexture *)textureWithWidth:(float)width height:(float)height fillColor:(uint)argb
{
    return [[[SPRenderTexture alloc] initWithWidth:width height:height fillColor:argb] autorelease];
}

@end
