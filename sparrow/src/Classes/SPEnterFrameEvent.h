//
//  SPEnterFrameEvent.h
//  Sparrow
//
//  Created by Daniel Sperl on 30.04.09.
//  Copyright 2009 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>
#import "SPEvent.h"

#define SP_EVENT_TYPE_ENTER_FRAME @"enterFrame"

@interface SPEnterFrameEvent : SPEvent
{
  @private 
    double mPassedTime;
}

@property (nonatomic, readonly) double passedTime;

- (id)initWithType:(NSString*)type bubbles:(BOOL)bubbles passedTime:(double)seconds; // des. init.
- (id)initWithType:(NSString*)type passedTime:(double)seconds;
+ (SPEnterFrameEvent*)eventWithType:(NSString*)type passedTime:(double)seconds;

@end
