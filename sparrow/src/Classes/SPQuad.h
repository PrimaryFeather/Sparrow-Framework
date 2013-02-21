//
//  SPQuad.h
//  Sparrow
//
//  Created by Daniel Sperl on 15.03.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>
#import "SPDisplayObject.h"

@class SPVertexData;

/** ------------------------------------------------------------------------------------------------

 An SPQuad represents a rectangle with a uniform color or a color gradient. 
 
 You can set one color per vertex. The colors will smoothly fade into each other over the area
 of the quad. To display a simple linear color gradient, assign one color to vertices 0 and 1 and 
 another color to vertices 2 and 3.
 
 The indices of the vertices are arranged like this:
 
	0 - 1
	| / |
	2 - 3
 
 **Colors**
 
 Colors in Sparrow are defined as unsigned integers, that's exactly 8 bit per color. The easiest
 way to define a color is by writing it as a hexadecimal number. A color has the following
 structure:
 
	0xRRGGBB
 
 That means that you can create the base colors like this:
 
	0xFF0000 -> red
 	0x00FF00 -> green
 	0x0000FF -> blue
 
 Other simple colors:
 
	0x000000 or 0x0 -> black
	0xFFFFFF        -> white
	0x808080        -> 50% gray
 
 If you're not comfortable with that, there is also a utility macro available that takes the
 values for R, G and B separately:
 
	uint red = SP_COLOR(255, 0, 0)
 
------------------------------------------------------------------------------------------------- */

@interface SPQuad : SPDisplayObject
{
    SPVertexData *mVertexData;
}

/// --------------------
/// @name Initialization
/// --------------------

/// Initializes a quad with a certain size and color. The `pma` parameter indicates how the colors
/// of the object are stored. _Designated Initializer_.
- (id)initWithWidth:(float)width height:(float)height color:(uint)color premultipliedAlpha:(BOOL)pma;

/// Initializes a quad with a certain size and color, using premultiplied alpha values.
- (id)initWithWidth:(float)width height:(float)height color:(uint)color;

/// Initializes a white quad with a certain size.
- (id)initWithWidth:(float)width height:(float)height; 

/// -------------
/// @name Methods
/// -------------

/// Sets the color of a vertex.
- (void)setColor:(uint)color ofVertex:(int)vertexID;

/// Returns the color of a vertex.
- (uint)colorOfVertex:(int)vertexID;

/// Sets the alpha value of a vertex.
- (void)setAlpha:(float)alpha ofVertex:(int)vertexID;

/// Returns the alpha value of a vertex.
- (float)alphaOfVertex:(int)vertexID;

/// Copies the raw vertex data to a VertexData instance.
- (void)copyVertexDataTo:(SPVertexData *)targetData atIndex:(int)targetIndex;

/// Call this method after manually changing the contents of 'mVertexData'.
- (void)vertexDataDidChange;

/// Factory method.
+ (id)quadWithWidth:(float)width height:(float)height;

/// Factory method.
+ (id)quadWithWidth:(float)width height:(float)height color:(uint)color;

/// Factory method. Creates a 32x32 quad.
+ (id)quad;

/// ----------------
/// @name Properties
/// ----------------

/// Sets the colors of all vertices simultaneously. Returns the color of vertex '0'.
@property (nonatomic, assign) uint color;

/// Indicates if the rgb values are stored premultiplied with the alpha value. This can have
/// effect on the rendering. (Most developers don't have to care, though.)
@property (nonatomic, readonly) BOOL premultipliedAlpha;

@end
