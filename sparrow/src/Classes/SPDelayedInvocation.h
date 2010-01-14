//
//  SPDelayedInvocation.h
//  Sparrow
//
//  Created by Daniel Sperl on 11.07.09.
//  Copyright 2009 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>
#import "SPAnimatable.h"

@interface SPDelayedInvocation : NSObject <SPAnimatable>
{
  @private
    id mTarget;
    NSMutableSet *mInvocations;
    double mTotalTime;
    double mCurrentTime;
}

@property (nonatomic, readonly) id target;
@property (nonatomic, readonly) double totalTime;
@property (nonatomic, assign)   double currentTime;

- (id)initWithTarget:(id)target delay:(double)time;
+ (SPDelayedInvocation*)invocationWithTarget:(id)target delay:(double)time;

@end
