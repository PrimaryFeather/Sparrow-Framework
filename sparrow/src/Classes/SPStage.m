//
//  SPStage.m
//  Sparrow
//
//  Created by Daniel Sperl on 15.03.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPStage.h"
#import "SPDisplayObject_Internal.h"
#import "SPMacros.h"
#import "SPRenderSupport.h"

#import <UIKit/UIKit.h>

// --- class implementation ------------------------------------------------------------------------

@implementation SPStage
{
    float mWidth;
    float mHeight;
    uint  mColor;
}

@synthesize width = mWidth;
@synthesize height = mHeight;
@synthesize color = mColor;

- (id)initWithWidth:(float)width height:(float)height
{    
    if ((self = [super init]))
    {
        mWidth = width;
        mHeight = height;
    }
    return self;
}

- (id)init
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    return [self initWithWidth:screenSize.width height:screenSize.height];
}

- (SPDisplayObject*)hitTestPoint:(SPPoint*)localPoint forTouch:(BOOL)isTouch
{
    if (isTouch && (!self.visible || !self.touchable)) 
        return nil;
    
    SPDisplayObject *target = [super hitTestPoint:localPoint forTouch:isTouch];
    
    // different to other containers, the stage should acknowledge touches even in empty parts.
    if (!target)
    {
        SPRectangle *bounds = [SPRectangle rectangleWithX:self.x y:self.y 
                                                    width:self.width height:self.height];
        if ([bounds containsPoint:localPoint])      
            target = self;
    }
    return target;
}

- (void)render:(SPRenderSupport *)support
{
    [SPRenderSupport clearWithColor:mColor alpha:1.0f];
    [support setupOrthographicProjectionWithLeft:0 right:mWidth top:0 bottom:mHeight];
    
    [super render:support];
}

- (void)setX:(float)value
{
    [NSException raise:SP_EXC_INVALID_OPERATION format:@"cannot set x-coordinate of stage"];
}

- (void)setY:(float)value
{
    [NSException raise:SP_EXC_INVALID_OPERATION format:@"cannot set y-coordinate of stage"];
}

- (void)setPivotX:(float)value
{
    [NSException raise:SP_EXC_INVALID_OPERATION format:@"cannot set pivot coordinates of stage"];
}

- (void)setPivotY:(float)value
{
    [NSException raise:SP_EXC_INVALID_OPERATION format:@"cannot set pivot coordinates of stage"];
}

- (void)setScaleX:(float)value
{
    [NSException raise:SP_EXC_INVALID_OPERATION format:@"cannot scale stage"];
}

- (void)setScaleY:(float)value
{
    [NSException raise:SP_EXC_INVALID_OPERATION format:@"cannot scale stage"];
}

- (void)setRotation:(float)value
{
    [NSException raise:SP_EXC_INVALID_OPERATION format:@"cannot rotate stage"];
}

@end

// -------------------------------------------------------------------------------------------------
