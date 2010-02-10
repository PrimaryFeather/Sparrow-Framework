//
//  SPJuggler.h
//  Sparrow
//
//  Created by Daniel Sperl on 09.05.09.
//  Copyright 2009 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>
#import "SPAnimatable.h"

@interface SPJuggler : NSObject <SPAnimatable>
{
  @private
    NSMutableSet *mObjects;
    double mElapsedTime;
}

@property (nonatomic, readonly) double elapsedTime;

- (void)addObject:(id<SPAnimatable>)object;
- (void)removeObject:(id<SPAnimatable>)object;
- (void)removeAllObjects;
- (void)removeTweensWithTarget:(id)object;
- (id)delayInvocationAtTarget:(id)target byTime:(double)time;

+ (SPJuggler *)juggler;

@end
