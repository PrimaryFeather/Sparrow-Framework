//
//  SPDisplayObjectContainer.h
//  Sparrow
//
//  Created by Daniel Sperl on 15.03.09.
//  Copyright 2009 Incognitek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPDisplayObject.h"

@interface SPDisplayObjectContainer : SPDisplayObject 
{
  @private
    NSMutableArray *mChildren;
}

@property (readonly) int numChildren;

- (void)addChild:(SPDisplayObject *)child;
- (void)addChild:(SPDisplayObject *)child atIndex:(int)index;
- (BOOL)containsChild:(SPDisplayObject *)child;
- (SPDisplayObject *)childAtIndex:(int)index;
- (int)childIndex:(SPDisplayObject *)child;
- (void)removeChild:(SPDisplayObject *)child;
- (void)removeChildAtIndex:(int)index;
- (void)swapChild:(SPDisplayObject*)child1 withChild:(SPDisplayObject*)child2;
- (void)swapChildAtIndex:(int)index1 withChildAtIndex:(int)index2;

@end
