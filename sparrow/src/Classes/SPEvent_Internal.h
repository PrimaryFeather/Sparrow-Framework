//
//  SPEvent_Internal.h
//  Sparrow
//
//  Created by Daniel Sperl on 03.05.09.
//  Copyright 2009 Incognitek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPEvent.h"

@interface SPEvent (Internal)

- (BOOL)stopsImmediatePropagation;
- (BOOL)stopsPropagation;
- (void)setTarget:(SPEventDispatcher*)target;
- (void)setCurrentTarget:(SPEventDispatcher*)currentTarget;

@end

