//
//  SPDisplayObject.m
//  Sparrow
//
//  Created by Daniel Sperl on 15.03.09.
//  Copyright 2009 Incognitek. All rights reserved.
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

// --- class implementation ------------------------------------------------------------------------

@implementation SPDisplayObject

@synthesize x = mX;
@synthesize y = mY;
@synthesize scaleX = mScaleX;
@synthesize scaleY = mScaleY;
@synthesize rotation = mRotationZ;
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
        [self release];
        [NSException raise:SP_EXC_ABSTRACT_CLASS 
                    format:@"Attempting to initialize abstract class SPDisplayObject."];        
        return nil;
    }    
    #endif
    
    if (self = [super init])
    {
        mAlpha = 1.0f;
        mScaleX = 1.0f;
        mScaleY = 1.0f;
        mVisible = YES;
        mTouchable = YES;
    }
    return self;
}

- (void)dealloc
{
    [mName release];
    [super dealloc];
}

- (void)render:(SPRenderSupport*)support
{
    // override in subclass
}

- (void)removeFromParent
{
    [mParent removeChild:self];
}

- (SPMatrix*)transformationMatrixToSpace:(SPDisplayObject*)targetCoordinateSpace
{           
    if (targetCoordinateSpace == self)
    {
        return [SPMatrix matrixWithIdentity];
    }        
    else if (!targetCoordinateSpace)
    {
        // targetCoordinateSpace 'nil' represents the target coordinate of the root object.
        // -> move up from self to root
        SPMatrix *selfMatrix = [[SPMatrix alloc] init];
        SPDisplayObject *currentObject = self;
        while (currentObject)
        {
            [selfMatrix concatMatrix:currentObject.transformationMatrix];
            currentObject = currentObject->mParent;
        }        
        return [selfMatrix autorelease]; 
    }
    else if (targetCoordinateSpace->mParent == self) // optimization
    {
        SPMatrix *targetMatrix = targetCoordinateSpace.transformationMatrix;
        [targetMatrix invert];
        return targetMatrix;
    }
    else if (mParent == targetCoordinateSpace) // optimization
    {        
        return self.transformationMatrix;
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

    currentObject = targetCoordinateSpace;    
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
        [selfMatrix concatMatrix:currentObject.transformationMatrix];
        currentObject = currentObject->mParent;
    }
    
    // 3.: Now move up from target until we reach the common parent
    SPMatrix *targetMatrix = [[SPMatrix alloc] init];
    currentObject = targetCoordinateSpace;
    while (currentObject && currentObject != commonParent)
    {
        [targetMatrix concatMatrix:currentObject.transformationMatrix];
        currentObject = currentObject->mParent;
    }    
    
    // 4.: Combine the two matrices
    [targetMatrix invert];
    [selfMatrix concatMatrix:targetMatrix];
    [targetMatrix release];
    
    return [selfMatrix autorelease];
}

- (SPRectangle*)boundsInSpace:(SPDisplayObject*)targetCoordinateSpace
{
    [NSException raise:SP_EXC_ABSTRACT_METHOD 
                format:@"Method needs to be implemented in subclass"];
    return nil;
}

- (SPRectangle*)bounds
{
    return [self boundsInSpace:mParent];
}

- (SPDisplayObject*)hitTestPoint:(SPPoint*)localPoint forTouch:(BOOL)isTouch;
{
    // on a touch test, invisible or untouchable objects cause the test to fail
    if (isTouch && (!mVisible || !mTouchable)) return nil;
    
    // otherwise, check bounding box
    if ([[self boundsInSpace:self] containsPoint:localPoint]) return self; 
    else return nil;
}

- (SPPoint*)localToGlobal:(SPPoint*)localPoint
{
    // move up until parent is nil
    SPMatrix *transformationMatrix = [[SPMatrix alloc] init];
    SPDisplayObject *currentObject = self;    
    while (currentObject)
    {
        [transformationMatrix concatMatrix:currentObject.transformationMatrix];
        currentObject = [currentObject parent];
    }
    
    SPPoint *globalPoint = [transformationMatrix transformPoint:localPoint];
    [transformationMatrix release];
    return globalPoint;
}

- (SPPoint*)globalToLocal:(SPPoint*)globalPoint
{
    // move up until parent is nil, then invert matrix
    SPMatrix *transformationMatrix = [[SPMatrix alloc] init];
    SPDisplayObject *currentObject = self;    
    while (currentObject)
    {
        [transformationMatrix concatMatrix:currentObject.transformationMatrix];
        currentObject = [currentObject parent];
    }
    
    [transformationMatrix invert];
    SPPoint *localPoint = [transformationMatrix transformPoint:globalPoint];
    [transformationMatrix release];
    return localPoint;
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

- (float)width
{
    return [self boundsInSpace:mParent].width; 
}

- (void)setWidth:(float)value
{
    // this method calls 'self.scaleX' instead of changing mScaleX directly.
    // that way, subclasses reacting on size changes need to override only the scaleX method.
    
    mScaleX = 1.0f;
    float actualWidth = self.width;
    if (actualWidth != 0.0f) self.scaleX = value / actualWidth;
    else                     self.scaleX = 1.0f;
}

- (float)height
{
    return [self boundsInSpace:mParent].height;
}

- (void)setHeight:(float)value
{
    mScaleY = 1.0f;
    float actualHeight = self.height;
    if (actualHeight != 0.0f) self.scaleY = value / actualHeight;
    else                      self.scaleY = 1.0f;
}

- (void)setRotation:(float)value
{
    // clamp between [-180 deg, +180 deg]
    while (value < -PI) value += TWO_PI;
    while (value >  PI) value -= TWO_PI;
    mRotationZ = value;
}

- (void)setAlpha:(float)value
{
    mAlpha = MAX(0.0f, MIN(1.0f, value));
}

- (SPDisplayObject*)root
{
    SPDisplayObject *currentObject = self;
    while (currentObject->mParent) 
        currentObject = currentObject->mParent;
    return currentObject;
}

- (SPStage*)stage
{
    SPDisplayObject *root = self.root;
    if ([root isKindOfClass:[SPStage class]]) return (SPStage*) root;
    else return nil;
}

- (SPMatrix*)transformationMatrix
{
    SPMatrix *matrix = [[SPMatrix alloc] init];
    
    if (mScaleX != 1.0f || mScaleY != 1.0f) [matrix scaleXBy:mScaleX yBy:mScaleY];
    if (mRotationZ != 0.0f)                 [matrix rotateBy:mRotationZ];
    if (mX != 0.0f || mY != 0.0f)           [matrix translateXBy:mX yBy:mY];
    
    return [matrix autorelease];
}

@end

// -------------------------------------------------------------------------------------------------

@implementation SPDisplayObject (Internal)

- (void)setParent:(SPDisplayObjectContainer*)parent 
{ 
    // only assigned, not retained -- otherwise, we would create a circular reference.
    mParent = parent; 
}

- (void)dispatchEventOnChildren:(SPEvent *)event
{
    [self dispatchEvent:event];
}

@end
