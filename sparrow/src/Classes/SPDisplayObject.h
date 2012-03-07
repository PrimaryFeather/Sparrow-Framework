//
//  SPDisplayObject.h
//  Sparrow
//
//  Created by Daniel Sperl on 15.03.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>
#import "SPEventDispatcher.h"
#import "SPRectangle.h"
#import "SPMatrix.h"

@class SPDisplayObjectContainer;
@class SPStage;
@class SPRenderSupport;

/** ------------------------------------------------------------------------------------------------

 The SPDisplayObject class is the base class for all objects that are rendered on the screen.
 
 In Sparrow, all displayable objects are organized in a display tree. Only objects that are part of
 the display tree will be displayed (rendered). 
 
 The display tree consists of leaf nodes (SPImage, SPQuad) that will be rendered directly to
 the screen, and of container nodes (subclasses of SPDisplayObjectContainer, like SPSprite).
 A container is simply a display object that has child nodes - which can, again, be either leaf
 nodes or other containers. 
 
 At the root of the display tree, there is the SPStage, which is a container, too. To create a
 Sparrow application, you let your main class inherit from SPStage, and build up your display
 tree from there.
 
 A display object has properties that define its position in relation to its parent
 (`x`, `y`), as well as its rotation and scaling factors (`scaleX`, `scaleY`). Use the `alpha` and
 `visible` properties to make an object translucent or invisible.
 
 Every display object may be the target of touch events. If you don't want an object to be
 touchable, you can disable the `touchable` property. When it's disabled, neither the object
 nor its children will receive any more touch events.
 
 **Points vs. Pixels**
 
 All sizes and distances are measured in points. What this means in pixels depends on the 
 contentScaleFactor of the stage. On a low resolution device (up to iPhone 3GS), one point is one
 pixel. On devices with a retina display, one point may be 2 pixels.
 
 **Transforming coordinates**
 
 Within the display tree, each object has its own local coordinate system. If you rotate a container,
 you rotate that coordinate system - and thus all the children of the container.
 
 Sometimes you need to know where a certain point lies relative to another coordinate system. 
 That's the purpose of the method `transformationMatrixToSpace:`. It will create a matrix that
 represents the transformation of a point in one coordinate system to another. 
 
 **Subclassing SPDisplayObject**
 
 As SPDisplayObject is an abstract class, you can't instantiate it directly, but have to use one of 
 its subclasses instead. There are already a lot of them available, and most of the time they will
 suffice. 
 
 However, you can create custom subclasses as well. That's especially useful when you want to 
 create an object with a custom render function.
 
 You will need to implement the following methods when you subclass SPDisplayObject:
 
	- (void)render:(SPRenderSupport*)support;
	- (SPRectangle*)boundsInSpace:(SPDisplayObject*)targetCoordinateSpace;
 
 Have a look at SPQuad for a sample implementation of those methods. 
 
------------------------------------------------------------------------------------------------- */

@interface SPDisplayObject : SPEventDispatcher 
{
  @private
    float mX;
    float mY;
    float mPivotX;
    float mPivotY;
    float mScaleX;
    float mScaleY;
    float mRotationZ;
    float mAlpha;
    BOOL mVisible;
    BOOL mTouchable;
    
    SPDisplayObjectContainer *mParent;    
    double mLastTouchTimestamp;
    NSString *mName;
}

/// -------------
/// @name Methods
/// -------------

/// Renders the display object with the help of a support object. 
- (void)render:(SPRenderSupport*)support;

/// Removes the object from its parent, if it has one.
- (void)removeFromParent;

/// Creates a matrix that represents the transformation from the local coordinate system to another.
- (SPMatrix*)transformationMatrixToSpace:(SPDisplayObject*)targetCoordinateSpace;

/// Returns a rectangle that completely encloses the object as it appears in another coordinate system.
- (SPRectangle*)boundsInSpace:(SPDisplayObject*)targetCoordinateSpace;

/// Transforms a point from the local coordinate system to global (stage) coordinates.
- (SPPoint*)localToGlobal:(SPPoint*)localPoint;

/// Transforms a point from global (stage) coordinates to the local coordinate system.
- (SPPoint*)globalToLocal:(SPPoint*)globalPoint;

/// Returns the object that is found topmost on a point in local coordinates, or nil if the test fails.
- (SPDisplayObject*)hitTestPoint:(SPPoint*)localPoint forTouch:(BOOL)isTouch;

/// Dispatches an event on all children (recursively). The event must not bubble. */
- (void)broadcastEvent:(SPEvent *)event;

/// ----------------
/// @name Properties
/// ----------------

/// The x coordinate of the object relative to the local coordinates of the parent.
@property (nonatomic, assign) float x;

/// The y coordinate of the object relative to the local coordinates of the parent.
@property (nonatomic, assign) float y;

/// The x coordinate of the object's origin in its own coordinate space (default: 0).
@property (nonatomic, assign) float pivotX;

/// The y coordinate of the object's origin in its own coordinate space (default: 0).
@property (nonatomic, assign) float pivotY;

/// The horizontal scale factor. "1" means no scale, negative values flip the object.
@property (nonatomic, assign) float scaleX;

/// The vertical scale factor. "1" means no scale, negative values flip the object.
@property (nonatomic, assign) float scaleY;

/// The width of the object in points.
@property (nonatomic, assign) float width;

/// The height of the object in points.
@property (nonatomic, assign) float height;

/// The rotation of the object in radians. (In Sparrow, all angles are measured in radians.)
@property (nonatomic, assign) float rotation;

/// The opacity of the object. 0 = transparent, 1 = opaque.
@property (nonatomic, assign) float alpha;

/// The visibility of the object. An invisible object will be untouchable.
@property (nonatomic, assign) BOOL visible;

/// Indicates if this object (and its children) will receive touch events.
@property (nonatomic, assign) BOOL touchable;

/// The bounds of the object relative to the local coordinates of the parent.
@property (nonatomic, readonly) SPRectangle *bounds;

/// The display object container that contains this display object.
@property (nonatomic, readonly) SPDisplayObjectContainer *parent;

/// The topmost object in the display tree the object is part of.
@property (nonatomic, readonly) SPDisplayObject *root;

/// The stage the display object is connected to, or nil if it is not connected to a stage.
@property (nonatomic, readonly) SPStage *stage;

/// The transformation matrix of the object relative to its parent.
@property (nonatomic, readonly) SPMatrix *transformationMatrix;

/// The name of the display object (default: nil). Used by `childByName:` of display object containers.
@property (nonatomic, copy) NSString *name;

@end
