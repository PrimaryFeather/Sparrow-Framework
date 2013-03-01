//
//  SPEvent.m
//  Sparrow
//
//  Created by Daniel Sperl on 27.04.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPEventDispatcher.h"
#import "SPEvent.h"
#import "SPEvent_Internal.h"

@implementation SPEvent
{
    SPEventDispatcher *__weak mTarget;
    SPEventDispatcher *__weak mCurrentTarget;
    NSString *mType;
    BOOL mStopsImmediatePropagation;
    BOOL mStopsPropagation;
    BOOL mBubbles;
}

@synthesize target = mTarget;
@synthesize currentTarget = mCurrentTarget;
@synthesize type = mType;
@synthesize bubbles = mBubbles;

- (id)initWithType:(NSString*)type bubbles:(BOOL)bubbles
{    
    if ((self = [super init]))
    {        
        mType = [[NSString alloc] initWithString:type];
        mBubbles = bubbles;
    }
    return self;
}

- (id)initWithType:(NSString*)type
{
    return [self initWithType:type bubbles:NO];
}

- (id)init
{
    return [self initWithType:@"undefined"];
}

- (void)stopImmediatePropagation
{
    mStopsImmediatePropagation = YES;
}

- (void)stopPropagation
{
    mStopsPropagation = YES;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"[%@: type=\"%@\", bubbles=%@]",
            NSStringFromClass([self class]), mType, mBubbles ? @"YES" : @"NO"];
}

+ (id)eventWithType:(NSString*)type bubbles:(BOOL)bubbles
{
    return [[self alloc] initWithType:type bubbles:bubbles];
}

+ (id)eventWithType:(NSString*)type
{
    return [[self alloc] initWithType:type];
}


@end

// -------------------------------------------------------------------------------------------------

@implementation SPEvent (Internal)

- (BOOL)stopsImmediatePropagation
{ 
    return mStopsImmediatePropagation;
}

- (BOOL)stopsPropagation
{ 
    return mStopsPropagation;
}

- (void)setTarget:(SPEventDispatcher*)target
{
    if (mTarget != target)
        mTarget = target;
}

- (void)setCurrentTarget:(SPEventDispatcher*)currentTarget
{
    if (mCurrentTarget != currentTarget)
        mCurrentTarget = currentTarget;
}

@end
