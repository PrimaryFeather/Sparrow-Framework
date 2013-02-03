//
//  SPResizeEvent.m
//  Sparrow
//
//  Created by Daniel Sperl on 01.10.2012.
//  Copyright 2012 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPResizeEvent.h"

@implementation SPResizeEvent
{
    float mWidth;
    float mHeight;
    double mAnimationTime;
}

@synthesize width = mWidth;
@synthesize height = mHeight;
@synthesize animationTime = mAnimationTime;

- (id)initWithType:(NSString *)type width:(float)width height:(float)height 
     animationTime:(double)time
{
    if ((self = [super initWithType:type bubbles:NO]))
    {
        mWidth = width;
        mHeight = height;
        mAnimationTime = time;
    }
    return self;
}

- (id)initWithType:(NSString*)type bubbles:(BOOL)bubbles
{
    return [self initWithType:type width:320 height:480 animationTime:0.5];
}

- (BOOL)isPortrait
{
    return mHeight > mWidth;
}

@end
