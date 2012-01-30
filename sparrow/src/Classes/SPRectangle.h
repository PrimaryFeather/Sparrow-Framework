//
//  SPRectangle.h
//  Sparrow
//
//  Created by Daniel Sperl on 21.03.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>
#import "SPPoolObject.h"
#import "SPPoint.h"

/// The SPRectangle class describes a rectangle by its top-left corner point (x, y) and by 
/// its width and height.

@interface SPRectangle : SPPoolObject <NSCopying>
{
  @private
    float mX;
    float mY;
    float mWidth;
    float mHeight;
}

/// ------------------
/// @name Initializers
/// ------------------

/// Initializes a rectangle with the specified components. _Designated Initializer_.
- (id)initWithX:(float)x y:(float)y width:(float)width height:(float)height;

/// Factory method.
+ (SPRectangle*)rectangleWithX:(float)x y:(float)y width:(float)width height:(float)height;

/// -------------
/// @name Methods
/// -------------

/// Determines if a point is within the rectangle.
- (BOOL)containsX:(float)x y:(float)y;

/// Determines if a point is within the rectangle.
- (BOOL)containsPoint:(SPPoint*)point;

/// Determines if another rectangle is within the rectangle.
- (BOOL)containsRectangle:(SPRectangle*)rectangle;

/// Determines if another rectangle contains or intersects the rectangle.
- (BOOL)intersectsRectangle:(SPRectangle*)rectangle;

/// If the specified rectangle intersects with the rectangle, returns the area of intersection.
- (SPRectangle*)intersectionWithRectangle:(SPRectangle*)rectangle;

/// Adds two rectangles together to create a new Rectangle object (by filling in the space between 
/// the two rectangles).
- (SPRectangle*)uniteWithRectangle:(SPRectangle*)rectangle; 

/// Sets width and height components to zero.
- (void)setEmpty;

/// Sets the bounds of the rectangle.
- (void)setX:(float)x y:(float)y width:(float)width height:(float)height;

/// Expands the bounds of this rectangle to contain the specified point.
- (void)addX:(float)x y:(float)y;

/// Expands the bounds of this rectangle to contain the specified point.
- (void)addPoint:(SPPoint *)p;

/// ----------------
/// @name Properties
/// ----------------

/// Rectangle component.
@property (nonatomic, assign) float x;
@property (nonatomic, assign) float y;
@property (nonatomic, assign) float width;
@property (nonatomic, assign) float height;

@property (nonatomic, readonly) float minX;
@property (nonatomic, readonly) float minY;
@property (nonatomic, readonly) float maxX;
@property (nonatomic, readonly) float maxY;
@property (nonatomic, readonly) float centerX;
@property (nonatomic, readonly) float centerY;
@property (nonatomic, readonly) SPPoint *min;
@property (nonatomic, readonly) SPPoint *max;
@property (nonatomic, readonly) SPPoint *center;

/// Determines if a rectangle has an empty area.
@property (nonatomic, readonly) BOOL isEmpty;

@end