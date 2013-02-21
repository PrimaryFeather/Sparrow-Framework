//
//  SPGLTexture.h
//  Sparrow
//
//  Created by Daniel Sperl on 27.06.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#import "SPTexture.h"
#import "SPMacros.h"

@class SPRectangle;

/** ------------------------------------------------------------------------------------------------

 The SPGLTexture class is a concrete implementation of the abstract class SPTexture,
 containing a standard 2D OpenGL texture. 
 
 In most cases, you don't have to use this class directly (the init-methods of the SPTexture class
 should suffice for most needs). However, you can use this class in combination with a
 GLKTextureLoader to load types that Sparrow doesn't support itself.
 
------------------------------------------------------------------------------------------------- */

@interface SPGLTexture : SPTexture

/// ------------------
/// @name Initializers
/// ------------------

/// Initializes a texture with the given properties. Width and height are expected pixel dimensions.
/// _Designated Initializer_.
- (id)initWithName:(uint)name width:(float)width height:(float)height
        containsMipmaps:(BOOL)mipmaps scale:(float)scaleFactor premultipliedAlpha:(BOOL)pma;

/// Initializes an uncompressed texture with with raw pixel data and a set of properties.
/// Width and height are expected pixel dimensions.
- (id)initWithData:(const void *)imgData width:(float)width height:(float)height
   generateMipmaps:(BOOL)mipmaps scale:(float)scale premultipliedAlpha:(BOOL)pma;

/// Initializes a texture with a GLKit texture info object and a certain scale factor.
- (id)initWithTextureInfo:(GLKTextureInfo *)info scale:(float)scale;

/// Initializes a texture with a GLKit texture info object and a certain scale factor.
/// Since the `alphaState` of the texture info only indicates if the alpha value was multiplied
/// during the loading process (not the actual state), you can override that value.
- (id)initWithTextureInfo:(GLKTextureInfo *)info scale:(float)scale premultipliedAlpha:(BOOL)pma;

/// Initializes a texture with a GLKit texture info object and a scale factor of 1.
- (id)initWithTextureInfo:(GLKTextureInfo *)info;

@end