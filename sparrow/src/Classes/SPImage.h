//
//  SPImage.h
//  Sparrow
//
//  Created by Daniel Sperl on 19.06.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>
#import "SPQuad.h"

@class SPTexture;
@class SPPoint;

/** ------------------------------------------------------------------------------------------------

 An SPImage displays a quad with a texture mapped onto it.
 
 Sparrow uses the SPTexture class to represent textures. To display a texture, you have to map
 it on a quad - and that's what SPImage is for.
 
 As SPImage inherits from SPQuad, you can give it a color. For each pixel, the resulting color will
 be the result of the multiplication of the color of the texture with the color of the quad. That 
 way, you can easily tint textures with a certain color. 
 
 Furthermore, SPImage allows the manipulation of texture coordinates. That way, you can move a 
 texture inside an image without changing any vertex coordinates of the quad. You can also use 
 this feature as a very efficient way to create a rectangular mask.
 
------------------------------------------------------------------------------------------------- */

@interface SPImage : SPQuad 
{
  @protected
    SPTexture *mTexture;
    float mTexCoords[8];
}

/// --------------------
/// @name Initialization
/// --------------------

/// Initialize a quad with a texture mapped onto it. _Designated Initializer_.
- (id)initWithTexture:(SPTexture*)texture;

/// Initialize a quad with a texture loaded from a file.
- (id)initWithContentsOfFile:(NSString*)path;

/// Factory method.
+ (SPImage*)imageWithTexture:(SPTexture*)texture;

/// Factory method.
+ (SPImage*)imageWithContentsOfFile:(NSString*)path;

/// -------------
/// @name Methods
/// -------------

/// Sets the texture coordinates of a vertex. Coordinates are in the range [0, 1].
- (void)setTexCoords:(SPPoint*)coords ofVertex:(int)vertexID;

/// Gets the texture coordinates of a vertex.
- (SPPoint*)texCoordsOfVertex:(int)vertexID;

/// ----------------
/// @name Properties
/// ----------------

/// The texture that is displayed on the quad.
@property (nonatomic, retain) SPTexture *texture;

@end
