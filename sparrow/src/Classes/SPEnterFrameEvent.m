//
//  SPEnterFrameEvent.m
//  Sparrow
//
//  Created by Daniel Sperl on 30.04.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPEnterFrameEvent.h"


@implementation SPEnterFrameEvent

@synthesize passedTime = mPassedTime;

- (id)initWithType:(NSString*)type bubbles:(BOOL)bubbles passedTime:(double)seconds 
{
    if ((self = [super initWithType:type bubbles:bubbles]))
    {
        mPassedTime = seconds;
    }
    return self;    
}

- (id)initWithType:(NSString*)type passedTime:(double)seconds
{
    return [self initWithType:type bubbles:NO passedTime:seconds];
}

- (id)initWithType:(NSString*)type bubbles:(BOOL)bubbles
{
    return [self initWithType:type bubbles:bubbles passedTime:0.0f];
}

+ (SPEnterFrameEvent*)eventWithType:(NSString*)type passedTime:(double)seconds
{
    return [[[SPEnterFrameEvent alloc] initWithType:type passedTime:seconds] autorelease];
}

- (void)dealloc
{
    [super dealloc];
}

@end
