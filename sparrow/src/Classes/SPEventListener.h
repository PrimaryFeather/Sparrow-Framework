//
//  SPEventListener.h
//  Sparrow
//
//  Created by Daniel Sperl on 28.02.13.
//  Copyright 2013 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>
#import "SPEventDispatcher.h"

@class SPEvent;

/** ------------------------------------------------------------------------------------------------
 
 This class captures information about an event listener, which can be either a block or a 
 combination of a target object and a selector.
 
 _This is an internal class. You do not have to use it manually._
 
 ------------------------------------------------------------------------------------------------- */

@interface SPEventListener : NSObject

/// Initializes an event listener with the specified properties. Note that `target` and `selector`
/// are only used by the `fitsTarget:` method; it's always the block that will be invoked.
/// _Designated Initializer._
- (id)initWithTarget:(id)target selector:(SEL)selector block:(SPEventBlock)block;

/// Initializes an event listener from a target and a selector.
- (id)initWithTarget:(id)target selector:(SEL)selector;

/// Initializes an event listener from a block.
- (id)initWithBlock:(SPEventBlock)block;

/// Invokes the event block with a certain event.
- (void)invokeWithEvent:(SPEvent *)event;

/// Indicates if this event fits either the combination of target and selector, or a block.
- (BOOL)fitsTarget:(id)target andSelector:(SEL)selector orBlock:(SPEventBlock)block;

/// The target of the listener, if available (otherwise, nil).
@property (nonatomic, readonly) id target;

/// The selector of the listener, if available (otherwise, nil).
@property (nonatomic, readonly) SEL selector;

@end
