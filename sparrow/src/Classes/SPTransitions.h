//
//  SPTransitions.h
//  Sparrow
//
//  Created by Daniel Sperl on 11.05.09.
//  Copyright 2009 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>

#define SP_TRANSITION_LINEAR                @"linear"
#define SP_TRANSITION_EASE_IN               @"easeIn"
#define SP_TRANSITION_EASE_OUT              @"easeOut"
#define SP_TRANSITION_EASE_IN_OUT           @"easeInOut"
#define SP_TRANSITION_EASE_OUT_IN           @"easeOutIn"
#define SP_TRANSITION_EASE_IN_BACK          @"easeInBack"
#define SP_TRANSITION_EASE_OUT_BACK         @"easeOutBack"
#define SP_TRANSITION_EASE_IN_OUT_BACK      @"easeInOutBack"
#define SP_TRANSITION_EASE_OUT_IN_BACK      @"easeOutInBack"
#define SP_TRANSITION_EASE_IN_ELASTIC       @"easeInElastic"
#define SP_TRANSITION_EASE_OUT_ELASTIC      @"easeOutElastic"
#define SP_TRANSITION_EASE_IN_OUT_ELASTIC   @"easeInOutElastic"
#define SP_TRANSITION_EASE_OUT_IN_ELASTIC   @"easeOutInElastic"  
#define SP_TRANSITION_EASE_IN_BOUNCE        @"easeInBounce"
#define SP_TRANSITION_EASE_OUT_BOUNCE       @"easeOutBounce"
#define SP_TRANSITION_EASE_IN_OUT_BOUNCE    @"easeInOutBounce"
#define SP_TRANSITION_EASE_OUT_IN_BOUNCE    @"easeOutInBounce" 

@interface SPTransitions : NSObject 

+ (float)linear:(float)ratio;

+ (float)easeIn:(float)ratio;
+ (float)easeOut:(float)ratio;
+ (float)easeInOut:(float)ratio;
+ (float)easeOutIn:(float)ratio;

+ (float)easeInBack:(float)ratio;
+ (float)easeOutBack:(float)ratio;
+ (float)easeInOutBack:(float)ratio;
+ (float)easeOutInBack:(float)ratio;

+ (float)easeInElastic:(float)ratio;
+ (float)easeOutElastic:(float)ratio;
+ (float)easeInOutElastic:(float)ratio;
+ (float)easeOutInElastic:(float)ratio;

+ (float)easeInBounce:(float)ratio;
+ (float)easeOutBounce:(float)ratio;
+ (float)easeInOutBounce:(float)ratio;
+ (float)easeOutInBounce:(float)ratio;

@end
