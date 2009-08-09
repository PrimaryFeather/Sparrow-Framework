//
//  SPTransitions.m
//  Sparrow
//
//  Created by Daniel Sperl on 11.05.09.
//  Copyright 2009 Incognitek. All rights reserved.
//

#import "SPTransitions.h"


@implementation SPTransitions

+ (float)linearWithDelta:(float)delta ratio:(float)ratio
{
    return ratio * delta;
}

+ (float)easeInWithDelta:(float)delta ratio:(float)ratio
{
    return delta * ratio * ratio * ratio;
}

+ (float)easeOutWithDelta:(float)delta ratio:(float)ratio
{
    float invRatio = ratio-1.0f;
    return delta * (invRatio * invRatio * invRatio + 1);
}

+ (float)easeInOutWithDelta:(float)delta ratio:(float)ratio
{
    if (ratio < 0.5f) return [SPTransitions easeInWithDelta: delta/2.0f ratio:ratio*2.0f];
    else return delta/2.0f + [SPTransitions easeOutWithDelta: delta/2.0f ratio:(ratio-0.5f)*2.0f];
}

+ (float)easeOutInWithDelta:(float)delta ratio:(float)ratio
{
    if (ratio < 0.5f) return [SPTransitions easeOutWithDelta: delta/2.0f ratio:ratio*2.0f];
    else return delta/2.0f + [SPTransitions easeInWithDelta: delta/2.0f ratio:(ratio-0.5f)*2.0f];
}

@end
