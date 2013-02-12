//
//  SPSubTexture.h
//  Sparrow
//
//  Created by Daniel Sperl on 27.06.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>
#import "SPTexture.h"

/** ------------------------------------------------------------------------------------------------
 
 An SPSubTexture represents a section of another texture. This is achieved solely by 
 manipulation of texture coordinates, making the class very efficient. 
 
 Note that it is OK to create subtextures of subtextures.
 
------------------------------------------------------------------------------------------------- */

@interface SPSubTexture : SPTexture

/// ------------------
/// @name Initializers
/// ------------------

/// Initializes a subtexture with a region (in points) of another texture, using a frame rectangle
/// to place the texture within an image. _Designated Initializer_.
- (id)initWithRegion:(SPRectangle *)region frame:(SPRectangle *)frame ofTexture:(SPTexture *)texture;

/// Initializes a subtexture with a region (in points) of another texture.
- (id)initWithRegion:(SPRectangle *)region ofTexture:(SPTexture *)texture;

/// Factory method.
+ (id)textureWithRegion:(SPRectangle *)region ofTexture:(SPTexture *)texture;

/// ----------------
/// @name Properties
/// ----------------

/// The texture which the subtexture is based on.
@property (nonatomic, readonly) SPTexture *baseTexture;

/// The clipping rectangle, which is the region provided on initialization, scaled into [0.0, 1.0].
@property (nonatomic, readonly) SPRectangle *clipping;

@end
