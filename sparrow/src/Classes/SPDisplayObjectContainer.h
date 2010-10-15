//
//  SPDisplayObjectContainer.h
//  Sparrow
//
//  Created by Daniel Sperl on 15.03.09.
//  Copyright 2009 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>
#import "SPDisplayObject.h"

@interface SPDisplayObjectContainer : SPDisplayObject <NSFastEnumeration>
{
  @private
    NSMutableArray *mChildren;
}

@property (nonatomic, readonly) int numChildren;

- (void)addChild:(SPDisplayObject *)child;
- (void)addChild:(SPDisplayObject *)child atIndex:(int)index;
- (BOOL)containsChild:(SPDisplayObject *)child;
- (SPDisplayObject *)childAtIndex:(int)index;
- (SPDisplayObject *)childByName:(NSString *)name;
- (int)childIndex:(SPDisplayObject *)child;
- (void)removeChild:(SPDisplayObject *)child;
- (void)removeChildAtIndex:(int)index;
- (void)removeAllChildren;
- (void)swapChild:(SPDisplayObject*)child1 withChild:(SPDisplayObject*)child2;
- (void)swapChildAtIndex:(int)index1 withChildAtIndex:(int)index2;

@end
