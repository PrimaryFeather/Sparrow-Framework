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
{
  @private
    float mA, mB, mC, mD;
    float mTx, mTy;
}

/// -----------------
/// @name Intializers
/// -----------------

/// Initializes a matrix with the specified components. _Designated Initializer_.
- (id)initWithA:(float)a b:(float)b c:(float)c d:(float)d tx:(float)tx ty:(float)ty;

/// Initializes an identity matrix.
- (id)init;

/// Factory method.
+ (SPMatrix*)matrixWithA:(float)a b:(float)b c:(float)c d:(float)d tx:(float)tx ty:(float)ty;

/// Factory method.
+ (SPMatrix*)matrixWithIdentity;

/// -------------
/// @name Methods
/// -------------

/// Sets all components simultaneously.
- (void)setA:(float)a b:(float)b c:(float)c d:(float)d tx:(float)tx ty:(float)ty;

/// Compares two matrices.
- (BOOL)isEqual:(id)other;

/// Concatenates a matrix with the current matrix, combining the geometric effects of the two.
- (void)concatMatrix:(SPMatrix*)matrix;

/// Translates the matrix along the x and y axes.
- (void)translateXBy:(float)dx yBy:(float)dy;

/// Applies a scaling transformation to the matrix.
- (void)scaleXBy:(float)sx yBy:(float)sy;

/// Applies a uniform scaling transformation to the matrix.
- (void)scaleBy:(float)scale;

/// Applies a rotation on the matrix (angle in RAD).
- (void)rotateBy:(float)angle;

/// Sets each matrix property to a value that causes a null transformation.
- (void)identity;

/// Performs the opposite transformation of the matrix.
- (void)invert;

/// Applies the geometric transformation represented by the matrix to the specified point.
- (SPPoint*)transformPoint:(SPPoint*)point;

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
