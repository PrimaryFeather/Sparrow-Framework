//
//  SPQuad.h
//  Sparrow
//
//  Created by Daniel Sperl on 15.03.09.
//  Copyright 2009 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>
#import "SPDisplayObject.h"

/** ------------------------------------------------------------------------------------------------

 An SPQuad displays a single, colored rectangle.
 It renders a rectangular area with a single color or a color gradient. 
 
 You can set one color per vertex. The colors will smoothly fade into each other over the area
 of the quad. To display a simple linear color gradient, assign one color to vertices 0 and 1 and 
 another color to vertices 2 and 3.
 
 The indices of the vertices are arranged like this:
 
	0 - 1
	| / |
	2 - 3
 
 *Colors*
 
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
  @protected
    float mVertexCoords[8];
    uint mVertexColors[4];
}

/// --------------------
/// @name Initialization
/// --------------------

/// Initializes a quad with a certain size and color. _Designated Initializer_.
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

/// Factory method.
+ (SPQuad*)quadWithWidth:(float)width height:(float)height;

/// Factory method.
+ (SPQuad*)quadWithWidth:(float)width height:(float)height color:(uint)color;

/// ----------------
/// @name Properties
/// ----------------

/// Sets the colors of all vertices simultaneously. Returns the color of vertex '0'.
@property (nonatomic, assign) uint color;

@end
