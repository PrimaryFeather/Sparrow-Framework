//
//  SPJuggler.h
//  Sparrow
//
//  Created by Daniel Sperl on 09.05.09.
//  Copyright 2009 Incognitek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPAnimatable.h"

@interface SPJuggler : NSObject <SPAnimatable>
{
  @private
    NSMutableSet *mObjects;
}

- (void)addObject:(id<SPAnimatable>)object;
- (void)removeObject:(id<SPAnimatable>)object;
- (id)delayInvocationAtTarget:(id)target byTime:(double)time;

@end
