//
//  SPEvent.h
//  Sparrow
//
//  Created by Daniel Sperl on 27.04.09.
//  Copyright 2009 Incognitek. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SP_EVENT_TYPE_ADDED @"added"
#define SP_EVENT_TYPE_ADDED_TO_STAGE @"addedToStage"
#define SP_EVENT_TYPE_REMOVED @"removed"
#define SP_EVENT_TYPE_REMOVED_FROM_STAGE @"removedFromStage"

@class SPEventDispatcher;

@interface SPEvent : NSObject
{
  @private
    SPEventDispatcher *mTarget;
    SPEventDispatcher *mCurrentTarget;
    NSString *mType;
    BOOL mStopsImmediatePropagation;
    BOOL mStopsPropagation;
    BOOL mBubbles;
}

@property (nonatomic, readonly) NSString *type;
@property (nonatomic, readonly) BOOL bubbles;
@property (nonatomic, readonly) SPEventDispatcher *target;
@property (nonatomic, readonly) SPEventDispatcher *currentTarget;

- (id)initWithType:(NSString*)type bubbles:(BOOL)bubbles; // designated initializer
- (id)initWithType:(NSString*)type;
- (void)stopImmediatePropagation;
- (void)stopPropagation;

+ (SPEvent*)eventWithType:(NSString*)type bubbles:(BOOL)bubbles;
+ (SPEvent*)eventWithType:(NSString*)type;

@end
