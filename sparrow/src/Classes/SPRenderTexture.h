//
//  SPRenderTexture.h
//  Sparrow
//
//  Created by Daniel Sperl on 04.12.10.
//  Copyright 2010 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#import "SPDisplayObject.h"
#import "SPTexture.h"
#import "SPRenderSupport.h"

typedef void (^SPDrawingBlock)();

@interface SPRenderTexture : SPTexture 
{
  @private
    GLuint mFramebuffer;
    BOOL   mFramebufferIsActive;
    SPTexture *mTexture;
    SPRenderSupport *mRenderSupport;    
}

- (id)initWithWidth:(float)width height:(float)height;
- (id)initWithWidth:(float)width height:(float)height fillColor:(uint)argb;
- (id)initWithWidth:(float)width height:(float)height fillColor:(uint)argb scale:(float)scale;

- (void)drawObject:(SPDisplayObject *)object;
- (void)bundleDrawCalls:(SPDrawingBlock)block;
- (void)clearWithColor:(uint)color alpha:(float)alpha;

+ (SPRenderTexture *)textureWithWidth:(float)width height:(float)height;
+ (SPRenderTexture *)textureWithWidth:(float)width height:(float)height fillColor:(uint)argb;

@end
