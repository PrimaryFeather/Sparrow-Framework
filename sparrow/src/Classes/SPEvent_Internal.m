//
//  SPEvent_Internal.m
//  Sparrow
//
//  Created by Daniel Sperl on 03.05.09.
//  Copyright 2009 Incognitek. All rights reserved.
//

#import "SPEvent_Internal.h"

@implementation SPEvent (Internal)

- (BOOL)stopsImmediatePropagation
{ 
    return mStopsImmediatePropagation;
}

- (BOOL)stopsPropagation
{ 
    return mStopsPropagation;
}

- (void)setTarget:(SPEventDispatcher*)target
{
    if (target != mTarget)
    {
        [mTarget release];
        mTarget = [target retain];
    }        
}

- (void)setCurrentTarget:(SPEventDispatcher*)currentTarget
{
    if (currentTarget != mCurrentTarget)
    {
        [mCurrentTarget release];
        mCurrentTarget = [currentTarget retain];
    }
}

@end
