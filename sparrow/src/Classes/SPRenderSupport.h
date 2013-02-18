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

#import "SPMatrix.h"

@class SPTexture;
@class SPDisplayObject;

/** ------------------------------------------------------------------------------------------------

 A class that contains helper methods simplifying OpenGL rendering.
 
 An SPRenderSupport instance is passed to any render: method. It saves information about the
 currently bound texture, which allows it to avoid unecessary texture switches.
 
 Furthermore, several static helper methods can be used for different needs whenever some
 OpenGL processing is required.
 
------------------------------------------------------------------------------------------------- */

@interface SPRenderSupport : NSObject

/// -------------
/// @name Methods
/// -------------

/// Binds a texture if it is not already bound. Pass `nil` to unbind any texture.
- (void)bindTexture:(SPTexture *)texture;

/// Converts color and alpha into the format needed by OpenGL. Premultiplies alpha depending on state.
- (uint)convertColor:(uint)color alpha:(float)alpha;

/// Resets matrix stack and blend mode.
- (void)nextFrame;

/// Converts color and alpha into the format needed by OpenGL, optionally premultiplying alpha values.
+ (uint)convertColor:(uint)color alpha:(float)alpha premultiplyAlpha:(BOOL)pma;

/// Clears OpenGL's color buffer.
+ (void)clearWithColor:(uint)color alpha:(float)alpha;

/// Checks for an OpenGL error. If there is one, it is logged an the error code is returned.
+ (uint)checkForOpenGLError;

/// -------------------------
/// @name Matrix Manipulation
/// -------------------------

/// Changes the modelview matrix to the identity matrix.
- (void)loadIdentity;

/// Empties the matrix stack, resets the modelview matrix to the identity matrix.
- (void)resetMatrix;

/// Pushes the current modelview matrix to a stack from which it can be restored later.
- (void)pushMatrix;

/// Restores the modelview matrix that was last pushed to the stack.
- (void)popMatrix;

/// Prepends a matrix to the modelview matrix by multiplying it with another matrix.
- (void)prependMatrix:(SPMatrix *)matrix;

/// Sets up the projection matrix for ortographic 2D rendering.
- (void)setupOrthographicProjectionWithX:(float)x y:(float)y
                                   width:(float)width height:(float)height;

/// Uploads the modelview matrix to OpenGL. Call before rendering!
- (void)uploadMatrix;

/// ----------------
/// @name Properties
/// ----------------

/// Indicates if the bound texture has its alpha channel premultiplied.
@property (nonatomic, readonly) BOOL usingPremultipliedAlpha;

/// Calculates the product of modelview and projection matrix.
/// CAUTION: Use with care! Each call returns the same instance.
@property (nonatomic, readonly) SPMatrix *mvpMatrix;

/// Returns the current modelview matrix.
/// CAUTION: Use with care! Each call returns the same instance.
@property (nonatomic, readonly) SPMatrix *modelViewMatrix;

/// Returns the current projection matrix.
/// CAUTION: Use with care! Each call returns the same instance.
@property (nonatomic, readonly) SPMatrix *projectionMatrix;

@end
