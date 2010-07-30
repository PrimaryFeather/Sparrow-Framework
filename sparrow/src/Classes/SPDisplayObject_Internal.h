//
//  SPDisplayObject_Internal.h
//  Sparrow
//
//  Created by Daniel Sperl on 03.05.09.
//  Copyright 2009 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>
#import "SPDisplayObject.h"

@interface SPDisplayObject (Internal)

- (void)setParent:(SPDisplayObjectContainer*)parent;
- (void)dispatchEventOnChildren:(SPEvent *)event;

@end
