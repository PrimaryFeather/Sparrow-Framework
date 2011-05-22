//
//  SPRenderSupport.h
//  Sparrow
//
//  Created by Daniel Sperl on 28.09.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>

@class SPTexture;
@class SPDisplayObject;

/** ------------------------------------------------------------------------------------------------

 A class that contains helper methods simplifying OpenGL rendering.
 
 An SPRenderSupport instance is passed to any render: method. It saves information about the currently
 bound texture, which allows it to avoid unecessary texture switches.
 
 Furthermore, several static helper methods can be used for different needs whenever some
 OpenGL processing is required.
 
------------------------------------------------------------------------------------------------- */

@interface SPRenderSupport : NSObject 
{
  @private
    uint mBoundTextureID;
    BOOL mPremultipliedAlpha;
}

/// -------------
/// @name Methods
/// -------------

/// Binds a texture if it is not already bound. Pass `nil` to unbind any texture.
- (void)bindTexture:(SPTexture *)texture;

/// Converts color and alpha into the format needed by OpenGL. Premultiplies alpha depending on state.
- (uint)convertColor:(uint)color alpha:(float)alpha;

/// Resets texture binding and alpha settings.
- (void)reset;

/// Converts color and alpha into the format needed by OpenGL, optionally premultiplying alpha values.
+ (uint)convertColor:(uint)color alpha:(float)alpha premultiplyAlpha:(BOOL)pma;

/// Clears OpenGL's color buffer.
+ (void)clearWithColor:(uint)color alpha:(float)alpha;

/// Transforms OpenGL's matrix into the local coordinate system of the object.
+ (void)transformMatrixForObject:(SPDisplayObject *)object;

/// Sets up OpenGL's projection matrix for 2D rendering.
+ (void)setupOrthographicRenderingWithLeft:(float)left right:(float)right 
                                    bottom:(float)bottom top:(float)top;

/// Checks for an OpenGL error. If there is one, it is logged an the error code is returned.
+ (uint)checkForOpenGLError;

/// ----------------
/// @name Properties
/// ----------------

/// Indicates if the bound texture has its alpha channel premultiplied.
@property (nonatomic, readonly) BOOL usingPremultipliedAlpha;

@end
