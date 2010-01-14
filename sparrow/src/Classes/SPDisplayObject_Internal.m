//
//  SPDisplayObject_Internal.m
//  Sparrow
//
//  Created by Daniel Sperl on 03.05.09.
//  Copyright 2009 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPDisplayObject_Internal.h"

@implementation SPDisplayObject (Internal)

- (void)setParent:(SPDisplayObjectContainer*)parent 
{ 
    // only assigned, not retained -- otherwise, we would create a circular reference.
    mParent = parent; 
}

@end
