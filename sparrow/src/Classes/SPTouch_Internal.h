//
//  SPTouch_Internal.h
//  Sparrow
//
//  Created by Daniel Sperl on 03.05.09.
//  Copyright 2009 Incognitek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPTouch.h"

@interface SPTouch (Internal)

- (void)setTimestamp:(double)timestamp;
- (void)setGlobalX:(float)x;
- (void)setGlobalY:(float)y;
- (void)setPreviousGlobalX:(float)x;
- (void)setPreviousGlobalY:(float)y;
- (void)setTapCount:(int)tapCount;
- (void)setPhase:(SPTouchPhase)phase;
- (void)setTarget:(SPDisplayObject*)target;

+ (SPTouch*)touch;

@end
