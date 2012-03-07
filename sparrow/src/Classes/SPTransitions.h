//
//  SPTransitions.h
//  Sparrow
//
//  Created by Daniel Sperl on 11.05.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>

#define SP_TRANSITION_LINEAR                @"linear"
#define SP_TRANSITION_RANDOMIZE             @"randomize"

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

/** ------------------------------------------------------------------------------------------------
 
 The SPTransitions class contains static methods that define easing functions. Those functions
 will be used by SPTween to execute animations.
 
 Here is a visible representation of the available transformations:
 
 ![](http://gamua.com/img/blog/2010/sparrow-transitions.png)

 You can define your own transitions by extending this class. The name of the method you declare 
 acts as the key that is used to identify the transition when you create the tween.
 
------------------------------------------------------------------------------------------------- */
 
@interface SPTransitions : NSObject 

+ (float)linear:(float)ratio;
+ (float)randomize:(float)ratio;

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
