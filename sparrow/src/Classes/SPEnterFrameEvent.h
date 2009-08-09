//
//  SPEnterFrameEvent.h
//  Sparrow
//
//  Created by Daniel Sperl on 30.04.09.
//  Copyright 2009 Incognitek. All rights reserved.
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
