//
//  SPTransitions.h
//  Sparrow
//
//  Created by Daniel Sperl on 11.05.09.
//  Copyright 2009 Incognitek. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SP_TRANSITION_LINEAR      @"linear"
#define SP_TRANSITION_EASE_IN     @"easeIn"
#define SP_TRANSITION_EASE_OUT    @"easeOut"
#define SP_TRANSITION_EASE_IN_OUT @"easeInOut"
#define SP_TRANSITION_EASE_OUT_IN @"easeOutIn"

@interface SPTransitions : NSObject 

+ (float)linearWithDelta:(float)delta ratio:(float)ratio;
+ (float)easeInWithDelta:(float)delta ratio:(float)ratio;
+ (float)easeOutWithDelta:(float)delta ratio:(float)ratio;
+ (float)easeInOutWithDelta:(float)delta ratio:(float)ratio;
+ (float)easeOutInWithDelta:(float)delta ratio:(float)ratio;

@end
