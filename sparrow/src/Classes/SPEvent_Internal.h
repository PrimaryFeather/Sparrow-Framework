//
//  SPEvent_Internal.h
//  Sparrow
//
//  Created by Daniel Sperl on 03.05.09.
//  Copyright 2009 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>
#import "SPEvent.h"

@interface SPEvent (Internal)

- (BOOL)stopsImmediatePropagation;
- (BOOL)stopsPropagation;
- (void)setTarget:(SPEventDispatcher*)target;
- (void)setCurrentTarget:(SPEventDispatcher*)currentTarget;

@end

