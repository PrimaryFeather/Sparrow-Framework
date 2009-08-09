//
//  SPDisplayObject.h
//  Sparrow
//
//  Created by Daniel Sperl on 15.03.09.
//  Copyright 2009 Incognitek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPEventDispatcher.h"
#import "SPRectangle.h"
#import "SPMatrix.h"

@class SPDisplayObjectContainer;
@class SPStage;

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
    
    SPDisplayObjectContainer *mParent;    
    double mLastTouchTimestamp;
}

@property (nonatomic, assign) float x;
@property (nonatomic, assign) float y;
@property (nonatomic, assign) float scaleX;
@property (nonatomic, assign) float scaleY;
@property (nonatomic, assign) float width;
@property (nonatomic, assign) float height;
@property (nonatomic, assign) float rotationZ;
@property (nonatomic, assign) float alpha;
@property (nonatomic, assign) BOOL isVisible;
@property (nonatomic, readonly) SPRectangle *bounds;
@property (nonatomic, readonly) SPDisplayObjectContainer *parent;
@property (nonatomic, readonly) SPDisplayObject *root;
@property (nonatomic, readonly) SPStage *stage;
@property (nonatomic, readonly) SPMatrix *transformationMatrix;

- (void)render;
- (void)removeFromParent;
- (SPMatrix*)transformationMatrixToSpace:(SPDisplayObject*)targetCoordinateSpace;
- (SPRectangle*)boundsInSpace:(SPDisplayObject*)targetCoordinateSpace;
- (SPPoint*)localToGlobal:(SPPoint*)localPoint;
- (SPPoint*)globalToLocal:(SPPoint*)globalPoint;
- (BOOL)hitTestPoint:(SPPoint*)globalPoint;

@end
