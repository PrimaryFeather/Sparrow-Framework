//
//  SPRenderTexture.h
//  Sparrow
//
//  Created by Daniel Sperl on 04.12.10.
//  Copyright 2010 Incognitek. All rights reserved.
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
- (void)drawBundled:(SPDrawingBlock)block;
- (void)clearWithColor:(uint)color alpha:(float)alpha;

+ (SPRenderTexture *)textureWithWidth:(float)width height:(float)height;
+ (SPRenderTexture *)textureWithWidth:(float)width height:(float)height fillColor:(uint)argb;

@end
