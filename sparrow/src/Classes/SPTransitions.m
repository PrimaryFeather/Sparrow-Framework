//
//  SPTransitions.m
//  Sparrow
//
//  Created by Daniel Sperl on 11.05.09.
//  Copyright 2009 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//
//  The easing functions were thankfully taken from http://dojotoolkit.org
//                                              and http://www.robertpenner.com/easing
//

#import "SPTransitions.h"
#import "SPMacros.h"
#import "SPUtils.h"

@implementation SPTransitions

- (id)init
{
    [self release];
    [NSException raise:NSGenericException format:@"Static class - do not initialize!"];        
    return nil;
}

+ (float)linear:(float)ratio
{
    return ratio;
}

+ (float)randomize:(float)ratio
{
    return [SPUtils randomFloat];
}

+ (float)easeIn:(float)ratio
{
    return ratio * ratio * ratio;
}

+ (float)easeOut:(float)ratio
{
    float invRatio = ratio - 1.0f;
    return invRatio * invRatio * invRatio + 1.0f;
}

+ (float)easeInOut:(float)ratio
{
    if (ratio < 0.5f) return 0.5f * [SPTransitions easeIn:ratio*2.0f];
    else              return 0.5f * [SPTransitions easeOut:(ratio-0.5f)*2.0f] + 0.5f;
}

+ (float)easeOutIn:(float)ratio
{
    if (ratio < 0.5f) return 0.5f * [SPTransitions easeOut:ratio*2.0f];
    else              return 0.5f * [SPTransitions easeIn:(ratio-0.5f)*2.0f] + 0.5f;
}

+ (float)easeInBack:(float)ratio
{
    float s = 1.70158f;
    return powf(ratio, 2.0f) * ((s + 1.0f)*ratio - s);    
}

+ (float)easeOutBack:(float)ratio
{
    float invRatio = ratio - 1.0f;
    float s = 1.70158f;
    return powf(invRatio, 2.0f) * ((s + 1.0f)*invRatio + s) + 1.0f;    
}

+ (float)easeInOutBack:(float)ratio
{
    if (ratio < 0.5f) return 0.5f * [SPTransitions easeInBack:ratio*2.0f];
    else              return 0.5f * [SPTransitions easeOutBack:(ratio-0.5f)*2.0f] + 0.5f;
}

+ (float)easeOutInBack:(float)ratio
{
    if (ratio < 0.5f) return 0.5f * [SPTransitions easeOutBack:ratio*2.0f];
    else              return 0.5f * [SPTransitions easeInBack:(ratio-0.5f)*2.0f] + 0.5f;
}

+ (float)easeInElastic:(float)ratio
{
    if (ratio == 0.0f || ratio == 1.0f) return ratio;
    else
    {
        float p = 0.3f;
        float s = p / 4.0f;
        float invRatio = ratio - 1.0f;
        return -1.0f * powf(2.0f, 10.0f*invRatio) * sinf((invRatio-s)*TWO_PI/p);        
    }
}

+ (float)easeOutElastic:(float)ratio
{
    if (ratio == 0.0f || ratio == 1.0f) return ratio;
    else 
    {
        float p = 0.3f;
        float s = p / 4.0f;
        return powf(2.0f, -10.0f*ratio) * sinf((ratio-s)*TWO_PI/p) + 1.0f;
    }
}

+ (float)easeInOutElastic:(float)ratio
{
    if (ratio < 0.5f) return 0.5f * [SPTransitions easeInElastic:ratio*2.0f];
    else              return 0.5f * [SPTransitions easeOutElastic:(ratio-0.5f)*2.0f] + 0.5f;    
}

+ (float)easeOutInElastic:(float)ratio
{
    if (ratio < 0.5f) return 0.5f * [SPTransitions easeOutElastic:ratio*2.0f];
    else              return 0.5f * [SPTransitions easeInElastic:(ratio-0.5f)*2.0f] + 0.5f;    
}

+ (float)easeInBounce:(float)ratio
{
    return 1.0f - [SPTransitions easeOutBounce:1.0f - ratio];
}

+ (float)easeOutBounce:(float)ratio
{
    float s = 7.5625f;
    float p = 2.75f;
    float l;
    if (ratio < (1.0f/p))
    {
        l = s * powf(ratio, 2.0f);
    }
    else
    {    
        if (ratio < (2.0f/p))
        {
            ratio -= 1.5f/p;
            l = s * powf(ratio, 2.0f) + 0.75f;
        }
        else
        {
            if (ratio < 2.5f/p)
            {
                ratio -= 2.25f/p;
                l = s * powf(ratio, 2.0f) + 0.9375f;
            }
            else
            {
                ratio -= 2.625f/p;
                l = s * powf(ratio, 2.0f) + 0.984375f;
            }
        }
    }
    return l;
}

+ (float)easeInOutBounce:(float)ratio
{
    if (ratio < 0.5f) return 0.5f * [SPTransitions easeInBounce:ratio*2.0f];
    else              return 0.5f * [SPTransitions easeOutBounce:(ratio-0.5f)*2.0f] + 0.5f;  
}

+ (float)easeOutInBounce:(float)ratio
{
    if (ratio < 0.5f) return 0.5f * [SPTransitions easeOutBounce:ratio*2.0f];
    else              return 0.5f * [SPTransitions easeInBounce:(ratio-0.5f)*2.0f] + 0.5f;  
}

@end
