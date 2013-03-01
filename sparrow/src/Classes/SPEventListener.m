//
//  SPEventListener.m
//  Sparrow
//
//  Created by Daniel Sperl on 28.02.13.
//  Copyright 2013 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPEventListener.h"
#import "SPNSExtensions.h"

#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

@implementation SPEventListener
{
    SPEventBlock mBlock;
    id __weak mTarget;
    SEL mSelector;
}

@synthesize target = mTarget;
@synthesize selector = mSelector;

- (id)initWithTarget:(id)target selector:(SEL)selector block:(SPEventBlock)block
{
    if ((self = [super init]))
    {
        mBlock = block;
        mTarget = target;
        mSelector = selector;
    }
    
    return self;
}

- (id)initWithTarget:(id)target selector:(SEL)selector
{
    id __weak weakTarget = target;
    
    return [self initWithTarget:target selector:selector block:^(SPEvent *event)
            {
                [weakTarget performSelector:selector withObject:event];
            }];
}

- (id)initWithBlock:(SPEventBlock)block
{
    return [self initWithTarget:nil selector:nil block:block];
}

- (void)invokeWithEvent:(SPEvent *)event
{
    mBlock(event);
}

- (BOOL)fitsTarget:(id)target andSelector:(SEL)selector orBlock:(SPEventBlock)block
{
    BOOL fitsTargetAndSelector = (target && (target == mTarget)) && (!selector || (selector == mSelector));
    BOOL fitsBlock = block == mBlock;
    return fitsTargetAndSelector || fitsBlock;
}

@end
