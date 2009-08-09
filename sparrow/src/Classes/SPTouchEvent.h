//
//  SPTouchEvent.h
//  Sparrow
//
//  Created by Daniel Sperl on 02.05.09.
//  Copyright 2009 Incognitek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPEvent.h"
#import "SPTouch.h"

@class SPDisplayObject;

#define SP_EVENT_TYPE_TOUCH @"touch"

@interface SPTouchEvent : SPEvent
{
  @private
    NSSet *mTouches;    
}

@property (nonatomic, readonly) NSSet *touches;
@property (nonatomic, readonly) double timestamp;

- (id)initWithType:(NSString*)type bubbles:(BOOL)bubbles touches:(NSSet*)touches; // design. init.
- (id)initWithType:(NSString*)type touches:(NSSet*)touches;
- (NSSet*)touchesWithTarget:(SPDisplayObject*)target;
- (NSSet*)touchesWithTarget:(SPDisplayObject*)target andPhase:(SPTouchPhase)phase;

+ (SPTouchEvent*)eventWithType:(NSString*)type touches:(NSSet*)touches;

@end
