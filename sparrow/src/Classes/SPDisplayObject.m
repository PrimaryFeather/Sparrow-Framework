//
//  SPDisplayObject.m
//  Sparrow
//
//  Created by Daniel Sperl on 15.03.09.
//  Copyright 2009 Incognitek. All rights reserved.
//

#import "SPDisplayObject.h"
#import "SPDisplayObjectContainer.h"
#import "SPStage.h"
#import "SPMakros.h"
#import "SPTouchEvent.h"

// --- class implementation ------------------------------------------------------------------------

@implementation SPDisplayObject

@synthesize x = mX;
@synthesize y = mY;
@synthesize scaleX = mScaleX;
@synthesize scaleY = mScaleY;
@synthesize rotationZ = mRotationZ;
@synthesize parent = mParent;
@synthesize alpha = mAlpha;
@synthesize isVisible = mVisible;
@synthesize isTouchable = mTouchable;

#pragma mark -

- (id)init
{    
    if ([[self class] isEqual:[SPDisplayObject class]]) 
    {
        [NSException raise:SP_EXC_ABSTRACT_CLASS 
                    format:@"Attempting to instantiate abstract class SPDisplayObject."];
        [self release];
        return nil;
    }    
    
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


#pragma mark -

- (void)render
{
    // override in subclass
}


#pragma mark -

- (void)removeFromParent
{
    [mParent removeChild:self];
}

- (SPMatrix*)transformationMatrixToSpace:(SPDisplayObject*)targetCoordinateSpace
{   
    // nil represents the target coordinate space of a direct parent.
    if (targetCoordinateSpace == nil) 
        return self.transformationMatrix;
    else if (targetCoordinateSpace == self)
        return [SPMatrix matrixWithIdentity];
    
    SP_CREATE_POOL(pool);

    // move up from target object until we find a common parent
    SPMatrix *targetMatrix = [[SPMatrix alloc] init];
    SPDisplayObject *currentObject = targetCoordinateSpace;    
    
    while (![currentObject isKindOfClass:[SPDisplayObjectContainer class]] ||
           ![(SPDisplayObjectContainer*)currentObject containsChild:self])
    {
        SPMatrix *currentMatrix = currentObject.transformationMatrix;
        [targetMatrix concatMatrix:currentMatrix];
        currentObject = [currentObject parent];
        if (currentObject == nil)
        {
            SP_RELEASE_POOL(pool);
            [NSException raise:SP_EXC_NOT_RELATED format:@"Object not connected to target"];
        }
    }
    
    // now move up from self until we reach common parent
    SPDisplayObject *commonParent = currentObject;
    SPMatrix *selfMatrix = [[SPMatrix alloc] init];
    currentObject = self;
    while (currentObject != commonParent)
    {        
        SPMatrix *currentMatrix = currentObject.transformationMatrix;        
        [selfMatrix concatMatrix:currentMatrix];
        currentObject = [currentObject parent];
    }    
      
    [targetMatrix invert];
    [selfMatrix concatMatrix:targetMatrix];
    [targetMatrix release];
    
    SP_RELEASE_POOL(pool);
    
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
    return [self boundsInSpace:nil];
}

- (SPDisplayObject*)hitTestPoint:(SPPoint*)localPoint forTouch:(BOOL)isTouch;
{
    // on a touch test, invisible or untouchable objects cause the test to fail
    if (isTouch && (!self.isVisible || !self.isTouchable)) return nil;
    
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
    
#pragma mark -

- (float)width
{
    return [self boundsInSpace:nil].width; 
}

- (void)setWidth:(float)value
{
    mScaleX = value / (self.width / self.scaleX);
}

- (float)height
{
    return [self boundsInSpace:nil].height;
}

- (void)setHeight:(float)value
{
    mScaleY = value / (self.height / self.scaleY);
}

- (void)setRotationZ:(float)value
{
    while (value < 0) value += TWO_PI;
    while (value >= TWO_PI) value -= TWO_PI;
    mRotationZ = value;
}

- (void)setAlpha:(float)value
{
    mAlpha = MAX(0.0f, MIN(1.0f, value));
}

- (SPDisplayObject*)root
{
    SPDisplayObject *currentObject = self;
    while (currentObject.parent) currentObject = currentObject.parent;
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
    [matrix scaleXBy:self.scaleX yBy:self.scaleY];
    [matrix rotateBy:self.rotationZ];
    [matrix translateXBy:self.x yBy:self.y];
    return [matrix autorelease];
}

@end
