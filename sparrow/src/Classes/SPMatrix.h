//
//  SPMatrix.h
//  Sparrow
//
//  Created by Daniel Sperl on 26.03.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#import "SPPoolObject.h"

@class SPPoint;

/** ------------------------------------------------------------------------------------------------
 
 The SPMatrix class describes an affine, 2D transformation Matrix. It provides methods to
 manipulate the matrix in convenient ways, and can be used to transform points.
 
 The matrix has the following form:

 	|a c tx|
 	|b d ty|
 	|0 0  1| 
 
------------------------------------------------------------------------------------------------- */

@interface SPMatrix : SPPoolObject <NSCopying>

/// -----------------
/// @name Intializers
/// -----------------

/// Initializes a matrix with the specified components. _Designated Initializer_.
- (id)initWithA:(float)a b:(float)b c:(float)c d:(float)d tx:(float)tx ty:(float)ty;

/// Initializes an identity matrix.
- (id)init;

/// Factory method.
+ (id)matrixWithA:(float)a b:(float)b c:(float)c d:(float)d tx:(float)tx ty:(float)ty;

/// Factory method.
+ (id)matrixWithIdentity;

/// -------------
/// @name Methods
/// -------------

/// Sets all components simultaneously.
- (void)setA:(float)a b:(float)b c:(float)c d:(float)d tx:(float)tx ty:(float)ty;

/// Compares two matrices.
- (BOOL)isEquivalent:(SPMatrix *)other;

/// Appends the matrix by multiplying another matrix by the current matrix.
- (void)appendMatrix:(SPMatrix *)lhs;

/// Prepends a matrix by multiplying the current matrix by another matrix.
- (void)prependMatrix:(SPMatrix *)rhs;

/// Translates the matrix along the x and y axes.
- (void)translateXBy:(float)dx yBy:(float)dy;

/// Applies a scaling transformation to the matrix.
- (void)scaleXBy:(float)sx yBy:(float)sy;

/// Appends a skew transformation to a matrix (angles in radians).
/// The skew matrix has the following form:
///
/// 	| cos(skewY)  -sin(skewX)  0 |
/// 	| sin(skewY)   cos(skewX)  0 |
/// 	|     0            0       1 |
- (void)skewXBy:(float)sx yBy:(float)sy;

/// Applies a uniform scaling transformation to the matrix.
- (void)scaleBy:(float)scale;

/// Applies a rotation on the matrix (angle in RAD).
- (void)rotateBy:(float)angle;

/// Sets each matrix property to a value that causes a null transformation.
- (void)identity;

/// Performs the opposite transformation of the matrix.
- (void)invert;

// Copies all of the matrix data from the source object into the calling Matrix object.
- (void)copyFromMatrix:(SPMatrix *)matrix;

/// Creates a 3D GLKit matrix that is equivalent to this instance.
- (GLKMatrix4)convertToGLKMatrix4;

/// Creates a 2D GLKit matrix that is equivalent to this instance.
- (GLKMatrix3)convertToGLKMatrix3;

/// Applies the geometric transformation represented by the matrix to the specified point.
- (SPPoint *)transformPoint:(SPPoint*)point;

/// Applies the geometric transformation represented by the matrix to the specified coordinates.
- (SPPoint *)transformPointWithX:(float)x y:(float)y;

/// ----------------
/// @name Properties
/// ----------------

/// The a component of the matrix.
@property (nonatomic, assign) float a;

/// The b component of the matrix.
@property (nonatomic, assign) float b;

/// The c component of the matrix.
@property (nonatomic, assign) float c;

/// The d component of the matrix.
@property (nonatomic, assign) float d;

/// The tx component of the matrix.
@property (nonatomic, assign) float tx;

/// The ty component of the matrix.
@property (nonatomic, assign) float ty;

/// The determinant of the matrix.
@property (nonatomic, readonly) float determinant;

@end
