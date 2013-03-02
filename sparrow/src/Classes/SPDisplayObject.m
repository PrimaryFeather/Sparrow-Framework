//
//  SPDisplayObject.m
//  Sparrow
//
//  Created by Daniel Sperl on 15.03.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPDisplayObject.h"
#import "SPDisplayObject_Internal.h"
#import "SPDisplayObjectContainer.h"
#import "SPStage.h"
#import "SPMacros.h"
#import "SPTouchEvent.h"

float square(float value) { return value * value; }

// --- class implementation ------------------------------------------------------------------------

@implementation SPDisplayObject
{
    float mX;
    float mY;
    float mPivotX;
    float mPivotY;
    float mScaleX;
    float mScaleY;
    float mSkewX;
    float mSkewY;
    float mRotation;
    float mAlpha;
    BOOL mVisible;
    BOOL mTouchable;
    BOOL mOrientationChanged;
    
    SPDisplayObjectContainer *__weak mParent;
    SPMatrix *mTransformationMatrix;
    double mLastTouchTimestamp;
    NSString *mName;
}

@synthesize x = mX;
@synthesize y = mY;
@synthesize pivotX = mPivotX;
@synthesize pivotY = mPivotY;
@synthesize scaleX = mScaleX;
@synthesize scaleY = mScaleY;
@synthesize skewX  = mSkewX;
@synthesize skewY  = mSkewY;
@synthesize rotation = mRotation;
@synthesize parent = mParent;
@synthesize alpha = mAlpha;
@synthesize visible = mVisible;
@synthesize touchable = mTouchable;
@synthesize name = mName;

- (id)init
{    
    #ifdef DEBUG    
    if ([self isMemberOfClass:[SPDisplayObject class]]) 
    {
        [NSException raise:SP_EXC_ABSTRACT_CLASS 
                    format:@"Attempting to initialize abstract class SPDisplayObject."];        
        return nil;
    }    
    #endif
    
    if ((self = [super init]))
    {
        mAlpha = 1.0f;
        mScaleX = 1.0f;
        mScaleY = 1.0f;
        mVisible = YES;
        mTouchable = YES;
        mTransformationMatrix = [[SPMatrix alloc] init];
        mOrientationChanged = NO;
    }
    return self;
}

- (void)render:(SPRenderSupport*)support
{
    // override in subclass
}

- (void)removeFromParent
{
    [mParent removeChild:self];
}

- (SPMatrix *)transformationMatrixToSpace:(SPDisplayObject *)targetSpace
{           
    if (targetSpace == self)
    {
        return [SPMatrix matrixWithIdentity];
    }
    else if (targetSpace == mParent || (!targetSpace && !mParent))
    {
        return [self.transformationMatrix copy];
    }
    else if (!targetSpace || targetSpace == self.base)
    {
        // targetSpace 'nil' represents the target coordinate of the base object.
        // -> move up from self to base
        SPMatrix *selfMatrix = [[SPMatrix alloc] init];
        SPDisplayObject *currentObject = self;
        while (currentObject != targetSpace)
        {
            [selfMatrix appendMatrix:currentObject.transformationMatrix];
            currentObject = currentObject->mParent;
        }        
        return selfMatrix; 
    }
    else if (targetSpace->mParent == self)
    {
        SPMatrix *targetMatrix = [targetSpace.transformationMatrix copy];
        [targetMatrix invert];
        return targetMatrix;
    }
    
    // 1.: Find a common parent of self and the target coordinate space.
    //
    // This method is used very often during touch testing, so we optimized the code. 
    // Instead of using an NSSet or NSArray (which would make the code much cleaner), we 
    // use a C array here to save the ancestors.
    
    static SPDisplayObject *ancestors[SP_MAX_DISPLAY_TREE_DEPTH];
    
    int count = 0;
    SPDisplayObject *commonParent = nil;
    SPDisplayObject *currentObject = self;
    while (currentObject && count < SP_MAX_DISPLAY_TREE_DEPTH)
    {
        ancestors[count++] = currentObject;
        currentObject = currentObject->mParent;
    }

    currentObject = targetSpace;    
    while (currentObject && !commonParent)
    {        
        for (int i=0; i<count; ++i)
        {
            if (currentObject == ancestors[i])
            {
                commonParent = ancestors[i];
                break;                
            }            
        }
        currentObject = currentObject->mParent;
    }
    
    if (!commonParent)
        [NSException raise:SP_EXC_NOT_RELATED format:@"Object not connected to target"];
    
    // 2.: Move up from self to common parent
    SPMatrix *selfMatrix = [[SPMatrix alloc] init];
    currentObject = self;    
    while (currentObject != commonParent)
    {
        [selfMatrix appendMatrix:currentObject.transformationMatrix];
        currentObject = currentObject->mParent;
    }
    
    // 3.: Now move up from target until we reach the common parent
    SPMatrix *targetMatrix = [[SPMatrix alloc] init];
    currentObject = targetSpace;
    while (currentObject && currentObject != commonParent)
    {
        [targetMatrix appendMatrix:currentObject.transformationMatrix];
        currentObject = currentObject->mParent;
    }    
    
    // 4.: Combine the two matrices
    [targetMatrix invert];
    [selfMatrix appendMatrix:targetMatrix];
    
    return selfMatrix;
}

- (SPRectangle*)boundsInSpace:(SPDisplayObject*)targetSpace
{
    [NSException raise:SP_EXC_ABSTRACT_METHOD 
                format:@"Method needs to be implemented in subclass"];
    return nil;
}

- (SPRectangle *)bounds
{
    return [self boundsInSpace:mParent];
}

- (SPDisplayObject *)hitTestPoint:(SPPoint *)localPoint forTouch:(BOOL)isTouch
{
    // on a touch test, invisible or untouchable objects cause the test to fail
    if (isTouch && (!mVisible || !mTouchable)) return nil;
    
    // otherwise, check bounding box
    if ([[self boundsInSpace:self] containsPoint:localPoint]) return self; 
    else return nil;
}

- (SPPoint *)localToGlobal:(SPPoint *)localPoint
{
    SPMatrix *matrix = [self transformationMatrixToSpace:self.base];
    return [matrix transformPoint:localPoint];
}

- (SPPoint *)globalToLocal:(SPPoint *)globalPoint
{
    SPMatrix *matrix = [self transformationMatrixToSpace:self.base];
    [matrix invert];
    return [matrix transformPoint:globalPoint];
}

- (void)dispatchEvent:(SPEvent*)event
{
    // on one given moment, there is only one set of touches -- thus, 
    // we process only one touch event with a certain timestamp
    if ([event isKindOfClass:[SPTouchEvent class]])
    {
        SPTouchEvent *touchEvent = (SPTouchEvent*)event;
        if (touchEvent.timestamp == mLastTouchTimestamp) return;        
        else mLastTouchTimestamp = touchEvent.timestamp;
    }
    
    [super dispatchEvent:event];
}

- (void)broadcastEvent:(SPEvent *)event
{
    if (event.bubbles)
        [NSException raise:SP_EXC_INVALID_OPERATION
                    format:@"Broadcast of bubbling events is prohibited"];

    [self dispatchEvent:event];
}

- (void)broadcastEventWithType:(NSString *)type
{
    [self dispatchEventWithType:type];
}

- (float)width
{
    return [self boundsInSpace:mParent].width; 
}

- (void)setWidth:(float)value
{
    // this method calls 'self.scaleX' instead of changing mScaleX directly.
    // that way, subclasses reacting on size changes need to override only the scaleX method.
    
    self.scaleX = 1.0f;
    float actualWidth = self.width;
    if (actualWidth != 0.0f) self.scaleX = value / actualWidth;
}

- (float)height
{
    return [self boundsInSpace:mParent].height;
}

- (void)setHeight:(float)value
{
    self.scaleY = 1.0f;
    float actualHeight = self.height;
    if (actualHeight != 0.0f) self.scaleY = value / actualHeight;
}

- (void)setX:(float)value
{
    if (value != mX)
    {
        mX = value;
        mOrientationChanged = YES;
    }
}

- (void)setY:(float)value
{
    if (value != mY)
    {
        mY = value;
        mOrientationChanged = YES;
    }
}

- (void)setScaleX:(float)value
{
    if (value != mScaleX)
    {
        mScaleX = value;
        mOrientationChanged = YES;
    }
}

- (void)setScaleY:(float)value
{
    if (value != mScaleY)
    {
        mScaleY = value;
        mOrientationChanged = YES;
    }
}

- (void)setSkewX:(float)value
{
    if (value != mSkewX)
    {
        mSkewX = value;
        mOrientationChanged = YES;
    }
}

- (void)setSkewY:(float)value
{
    if (value != mSkewY)
    {
        mSkewY = value;
        mOrientationChanged = YES;
    }
}

- (void)setPivotX:(float)value
{
    if (value != mPivotX)
    {
        mPivotX = value;
        mOrientationChanged = YES;
    }
}

- (void)setPivotY:(float)value
{
    if (value != mPivotY)
    {
        mPivotY = value;
        mOrientationChanged = YES;
    }
}

- (void)setRotation:(float)value
{
    // move to equivalent value in range [0 deg, 360 deg] without a loop
    value = fmod(value, TWO_PI);
    
    // move to [-180 deg, +180 deg]
    if (value < -PI) value += TWO_PI;
    if (value >  PI) value -= TWO_PI;
    
    mRotation = value;
    mOrientationChanged = YES;
}

- (void)setAlpha:(float)value
{
    mAlpha = MAX(0.0f, MIN(1.0f, value));
}

- (SPDisplayObject *)base
{
    SPDisplayObject *currentObject = self;
    while (currentObject->mParent) currentObject = currentObject->mParent;
    return currentObject;
}

- (SPDisplayObject *)root
{
    Class stageClass = [SPStage class];
    SPDisplayObject *currentObject = self;
    while (currentObject->mParent)
    {
        if ([currentObject->mParent isMemberOfClass:stageClass]) return currentObject;
        else currentObject = currentObject->mParent;
    }
    return nil;
}

- (SPStage*)stage
{
    SPDisplayObject *base = self.base;
    if ([base isKindOfClass:[SPStage class]]) return (SPStage*) base;
    else return nil;
}

- (SPMatrix*)transformationMatrix
{
    if (mOrientationChanged)
    {
        mOrientationChanged = NO;
        [mTransformationMatrix identity];
    
        if (mScaleX != 1.0f || mScaleY != 1.0f) [mTransformationMatrix scaleXBy:mScaleX yBy:mScaleY];
        if (mSkewX  != 1.0f || mSkewY  != 1.0f) [mTransformationMatrix skewXBy:mSkewX yBy:mSkewY];
        if (mRotation != 0.0f)                 [mTransformationMatrix rotateBy:mRotation];
        if (mX != 0.0f || mY != 0.0f)           [mTransformationMatrix translateXBy:mX yBy:mY];
        
        if (mPivotX != 0.0 || mPivotY != 0.0)
        {
            // prepend pivot transformation
            mTransformationMatrix.tx = mX - mTransformationMatrix.a * mPivotX
                                          - mTransformationMatrix.c * mPivotY;
            mTransformationMatrix.ty = mY - mTransformationMatrix.b * mPivotX
                                          - mTransformationMatrix.d * mPivotY;
        }
    }
    
    return mTransformationMatrix;
}

- (void)setTransformationMatrix:(SPMatrix *)matrix
{
    mOrientationChanged = NO;
    [mTransformationMatrix copyFromMatrix:matrix];
    
    mX = matrix.tx;
    mY = matrix.ty;
    
    mScaleX = sqrtf(square(matrix.a) + square(matrix.b));
    mSkewY  = acosf(matrix.a / mScaleX);
    
    if (!SP_IS_FLOAT_EQUAL(matrix.b, mScaleX * sinf(mSkewY)))
    {
        mScaleX *= -1.0f;
        mSkewY = acosf(matrix.a / mScaleX);
    }
    
    mScaleY = sqrtf(square(matrix.c) + square(matrix.d));
    mSkewX  = acosf(matrix.d / mScaleY);
    
    if (!SP_IS_FLOAT_EQUAL(matrix.c, -mScaleY * sinf(mSkewX)))
    {
        mScaleY *= -1.0f;
        mSkewX = acosf(matrix.d / mScaleY);
    }
    
    if (SP_IS_FLOAT_EQUAL(mSkewX, mSkewY))
    {
        mRotation = mSkewX;
        mSkewX = mSkewY = 0.0f;
    }
    else
    {
        mRotation = 0.0f;
    }
}

- (BOOL)hasVisibleArea
{
    return mAlpha != 0.0f && mVisible && mScaleX != 0.0f && mScaleY != 0.0f;
}

@end

// -------------------------------------------------------------------------------------------------

@implementation SPDisplayObject (Internal)

- (void)setParent:(SPDisplayObjectContainer *)parent 
{ 
    SPDisplayObject *ancestor = parent;
    while (ancestor != self && ancestor != nil)
        ancestor = ancestor->mParent;
    
    if (ancestor == self)
        [NSException raise:SP_EXC_INVALID_OPERATION 
                    format:@"An object cannot be added as a child to itself or one of its children"];
    else
        mParent = parent; // only assigned, not retained (to avoid a circular reference).
}

- (void)dispatchEventOnChildren:(SPEvent *)event
{
    [self dispatchEvent:event];
}

@end
