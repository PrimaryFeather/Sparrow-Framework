//
//  SPEvent.m
//  Sparrow
//
//  Created by Daniel Sperl on 27.04.09.
//  Copyright 2009 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPEvent.h"

@implementation SPEvent

@synthesize target = mTarget;
@synthesize currentTarget = mCurrentTarget;
@synthesize type = mType;
@synthesize bubbles = mBubbles;

- (id)initWithType:(NSString*)type bubbles:(BOOL)bubbles
{    
    if (self = [super init])
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

+ (SPEvent*)eventWithType:(NSString*)type bubbles:(BOOL)bubbles
{
    return [[[SPEvent alloc] initWithType:type bubbles:bubbles] autorelease];
}

+ (SPEvent*)eventWithType:(NSString*)type
{
    return [[[SPEvent alloc] initWithType:type] autorelease];
}

#pragma mark -

- (void)dealloc
{
    [mType release];
    [mTarget release];
    [mCurrentTarget release];
    [super dealloc];
}

@end
