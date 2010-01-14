//
//  SPTouchEvent.m
//  Sparrow
//
//  Created by Daniel Sperl on 02.05.09.
//  Copyright 2009 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPTouchEvent.h"
#import "SPDisplayObject.h"
#import "SPDisplayObjectContainer.h"
#import "SPEvent_Internal.h"

@implementation SPTouchEvent

@synthesize touches = mTouches;

- (id)initWithType:(NSString*)type bubbles:(BOOL)bubbles touches:(NSSet*)touches
{   
    if (self = [super initWithType:type bubbles:bubbles])
    {        
        mTouches = [touches retain];
    }
    return self;
}

- (id)initWithType:(NSString*)type touches:(NSSet*)touches
{   
    return [self initWithType:type bubbles:YES touches:touches];
}

- (id)initWithType:(NSString*)type bubbles:(BOOL)bubbles
{
    return [self initWithType:type bubbles:bubbles touches:[NSSet set]];
}

- (SPEvent*)clone
{
    return [SPTouchEvent eventWithType:self.type touches:self.touches];
}

- (double)timestamp
{
    return [[mTouches anyObject] timestamp];    
}

- (NSSet*)touchesWithTarget:(SPDisplayObject*)target
{
    NSMutableSet *touchesFound = [NSMutableSet set];
    for (SPTouch *touch in mTouches)
    {
        if ([target isEqual:touch.target] ||
            ([target isKindOfClass:[SPDisplayObjectContainer class]] &&
             [(SPDisplayObjectContainer*)target containsChild:touch.target]))
        {
            [touchesFound addObject: touch];
        }
    }    
    return touchesFound;    
}

- (NSSet*)touchesWithTarget:(SPDisplayObject*)target andPhase:(SPTouchPhase)phase
{
    NSMutableSet *touchesFound = [NSMutableSet set];
    for (SPTouch *touch in mTouches)
    {
        if (touch.phase == phase &&
            ([target isEqual:touch.target] || 
             ([target isKindOfClass:[SPDisplayObjectContainer class]] &&
              [(SPDisplayObjectContainer*)target containsChild:touch.target])))
        {
            [touchesFound addObject: touch];
        }
    }    
    return touchesFound;    
}

- (void)dealloc
{
    [mTouches release];
    [super dealloc];
}

+ (SPTouchEvent*)eventWithType:(NSString*)type touches:(NSSet*)touches
{
    return [[[SPTouchEvent alloc] initWithType:type touches:touches] autorelease];
}

@end
