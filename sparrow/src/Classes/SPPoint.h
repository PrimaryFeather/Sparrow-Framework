//
//  SPPoint.h
//  Sparrow
//
//  Created by Daniel Sperl on 23.03.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>
#import "SPPoolObject.h"

/** The SPPoint class describes a two dimensional point or vector. */

@interface SPPoint : SPPoolObject <NSCopying>
{
  @private
    float mX;
    float mY;
}

/// ------------------
/// @name Initializers
/// ------------------

/// Initializes a point with its x and y components. _Designated Initializer_.
- (id)initWithX:(float)x y:(float)y;

/// Initializes a point with the distance and angle in respect to the origin.
- (id)initWithPolarLength:(float)length angle:(float)angle;

/// Factory method.
+ (SPPoint *)pointWithPolarLength:(float)length angle:(float)angle;

/// Factory method.
+ (SPPoint *)pointWithX:(float)x y:(float)y;

/// Factory method.
+ (SPPoint *)point;

/// -------------
/// @name Methods
// --------------

/// Returns the negation of this point
- (SPPoint *)negate;

/// Adds a point to the current point and returns the resulting point.
- (SPPoint *)addPoint:(SPPoint *)point;

/// Adds a point to the current point and returns the resulting point.
- (SPPoint *)addX:(float)x y:(float)y;

/// Substracts a point from the current point and returns the resulting point.
- (SPPoint *)subtractPoint:(SPPoint *)point;

/// Substracts a point from the current point and returns the resulting point.
- (SPPoint *)subtractX:(float)x y:(float)y;

/// Scales the point by a certain factor and returns the resulting point.
- (SPPoint *)scaleBy:(float)scalar;

/// Rotates the point by the given angle (in radians) and returns the resulting point.
- (SPPoint *)rotateBy:(float)angle;

/// Scales the line segment between the origin and the current point to one.
- (SPPoint *)normalize;

/// Returns the dot-product of this vector and the given vector
- (float)dot:(SPPoint *)other;

/// Returns the angle between this vector and the given vector
- (float)angleBetween:(SPPoint *)other;

/// Compares two points.
- (BOOL)isEqual:(id)other;

/// Calculates the distance between two points.
+ (float)distanceFromPoint:(SPPoint *)p1 toPoint:(SPPoint *)p2;

/// Determines a point between two specified points. `ratio = 0 -> p1, ratio = 1 -> p2`
+ (SPPoint *)interpolateFromPoint:(SPPoint *)p1 toPoint:(SPPoint *)p2 ratio:(float)ratio;

/// ----------------
/// @name Properties
/// ----------------

/// Point component.
@property (nonatomic, assign) float x;
@property (nonatomic, assign) float y;

/// The squared distance to the origin (or the squared length of the vector)
@property (readonly) float lengthSq;

/// The distance to the origin (or the length of the vector).
@property (readonly) float length;

/// The angle between the origin and the point (in RAD).
@property (readonly) float angle;

/// Returns true if this is the zero-vector
@property (readonly) BOOL isZero;

@end
