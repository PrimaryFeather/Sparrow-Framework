//
//  SPVertexData.h
//  Sparrow
//
//  Created by Daniel Sperl on 18.02.13.
//  Copyright 2013 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <GLKit/GLKit.h>

@class SPRectangle;
@class SPMatrix;
@class SPPoint;

typedef struct
{
    unsigned char r;
    unsigned char g;
    unsigned char b;
    unsigned char a;
} SPVertexColor;

typedef struct
{
    GLKVector2 position;
    GLKVector2 texCoords;
    SPVertexColor color;
} SPVertex;

SPVertexColor SPVertexColorMake(unsigned char r, unsigned char g, unsigned char b, unsigned char a);
SPVertexColor SPVertexColorMakeWithColorAndAlpha(uint rgb, float alpha);

/** ------------------------------------------------------------------------------------------------
 
 The VertexData class manages a raw list of vertex information, allowing direct upload
 to OpenGL vertex buffers. _You only have to work with this class if you create display
 objects with a custom render function. If you don't plan to do that, you can safely
 ignore it._
 
 To render objects with OpenGL, you have to organize vertex data in so-called
 vertex buffers. Those buffers reside in graphics memory and can be accessed very
 efficiently by the GPU. Before you can move data into vertex buffers, you have to
 set it up in conventional memory - that is, in a byte array. That array contains
 all vertex information (the coordinates, color, and texture coordinates) - one
 vertex after the other.
 
 To simplify creating and working with such a bulky list, the VertexData class was
 created. It contains methods to specify and modify vertex data. The raw array managed
 by the class can then easily be uploaded to a vertex buffer.
 
 **Premultiplied Alpha**
 
 The color values of texture files may contain premultiplied alpha values, which
 means that the `RGB` values were multiplied with the `alpha` value
 before saving them. On rendering, it makes a difference in which way the alpha value is saved;
 for that reason, the VertexData class mimics this behavior. You can choose how the alpha
 values should be handled via the `premultipliedAlpha` property.
 
------------------------------------------------------------------------------------------------- */

@interface SPVertexData : NSObject

/// Initializes a VertexData instance with a certain size. _Designated Initializer_.
- (id)initWithSize:(int)numVertices premultipliedAlpha:(BOOL)pma;

/// Initializes an empty VertexData object. Use the `appendVertex:` method and the `numVertices`
/// property to change its size later.
- (id)initWithSize:(int)numVertices;

/// Copies the vertex data of this instance to another vertex data object,
/// starting at a certain index.
- (void)copyToVertexData:(SPVertexData *)target atIndex:(int)targetIndex;

/// Copies the vertex data of this instance to another vertex data object, starting at element 0.
- (void)copyToVertexData:(SPVertexData *)target;

/// Returns a vertex at a certain position
- (SPVertex)vertexAtIndex:(int)index;

/// Updates the vertex at a certain position.
- (void)setVertex:(SPVertex)vertex atIndex:(int)index;

/// Adds a vertex at the end, raising the number of vertices by one.
- (void)appendVertex:(SPVertex)vertex;

/// Returns the position of a vertex.
- (SPPoint *)positionAtIndex:(int)index;

/// Updates the position of a vertex.
- (void)setPosition:(SPPoint *)position atIndex:(int)index;

/// Returns the texture coordinates of a vertex.
- (SPPoint *)texCoordsAtIndex:(int)index;

/// Updates the texture coordinates of a vertex.
- (void)setTexCoords:(SPPoint *)texCoords atIndex:(int)index;

/// Updates the RGB color and the alpha value of a vertex.
- (void)setColor:(uint)color alpha:(float)alpha atIndex:(int)index;

/// Returns the RGB color of a vertex (without premultiplied alpha).
- (uint)colorAtIndex:(int)index;

/// Sets the RGB color of a vertex. Don't use premutliplied alpha!
- (void)setColor:(uint)color atIndex:(int)index;

/// Returns the alpha value of a vertex.
- (float)alphaAtIndex:(int)index;

/// Updates the alpha value of a vertex.
- (void)setAlpha:(float)alpha atIndex:(int)index;

/// Multiplies all alpha values with a certain factor.
- (void)scaleAlphaBy:(float)factor;

/// Multiplies a range of alpha values with a certain factor.
- (void)scaleAlphaBy:(float)factor atIndex:(int)index numVertices:(int)count;

/// Changes the way alpha and color values are stored.
/// Optionally, all exisiting vertices are updated.
- (void)setPremultipliedAlpha:(BOOL)value updateVertices:(BOOL)update;

/// Transforms the positions of subsequent vertices by multiplication with a transformation matrix.
- (void)transformVerticesWithMatrix:(SPMatrix *)matrix atIndex:(int)index numVertices:(int)count;

/// Calculates the bounding rectangle of all vertices.
- (SPRectangle *)bounds;

/// Calculates the bounding rectangle of all vertices after being transformed by a matrix.
- (SPRectangle *)boundsAfterTransformation:(SPMatrix *)matrix;

/// Returns a pointer to the raw vertex data.
@property (nonatomic, readonly) SPVertex* vertices;

/// Indicates the size of the VertexData object. You can resize the object any time; if you
/// make it bigger, it will be filled up with vertices that have all properties zeroed, except
/// for the alpha value (it's `1`).
@property (nonatomic, assign) int numVertices;

/// Indicates if the rgb values are stored premultiplied with the alpha value. If you change
/// this property, all color data will be updated accordingly.
@property (nonatomic, assign) BOOL premultipliedAlpha;

@end
