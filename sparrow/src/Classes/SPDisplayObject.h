//
//  SPDisplayObject.h
//  Sparrow
//
//  Created by Daniel Sperl on 15.03.09.
//  Copyright 2009 Incognitek. All rights reserved.
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

@interface SPDisplayObject : SPEventDispatcher 
{
  @private
    float mX;
    float mY;
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

@property (nonatomic, assign) float x;
@property (nonatomic, assign) float y;
@property (nonatomic, assign) float scaleX;
@property (nonatomic, assign) float scaleY;
@property (nonatomic, assign) float width;
@property (nonatomic, assign) float height;
@property (nonatomic, assign) float rotation;
@property (nonatomic, assign) float alpha;
@property (nonatomic, assign) BOOL visible;
@property (nonatomic, assign) BOOL touchable;
@property (nonatomic, readonly) SPRectangle *bounds;
@property (nonatomic, readonly) SPDisplayObjectContainer *parent;
@property (nonatomic, readonly) SPDisplayObject *root;
@property (nonatomic, readonly) SPStage *stage;
@property (nonatomic, readonly) SPMatrix *transformationMatrix;
@property (nonatomic, copy) NSString *name;

- (void)render:(SPRenderSupport*)support;
- (void)removeFromParent;
- (SPMatrix*)transformationMatrixToSpace:(SPDisplayObject*)targetCoordinateSpace;
- (SPRectangle*)boundsInSpace:(SPDisplayObject*)targetCoordinateSpace;
- (SPPoint*)localToGlobal:(SPPoint*)localPoint;
- (SPPoint*)globalToLocal:(SPPoint*)globalPoint;
- (SPDisplayObject*)hitTestPoint:(SPPoint*)localPoint forTouch:(BOOL)isTouch;

@end
