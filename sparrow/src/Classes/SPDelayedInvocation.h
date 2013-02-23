//
//  SPDelayedInvocation.h
//  Sparrow
//
//  Created by Daniel Sperl on 11.07.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>
#import "SPAnimatable.h"
#import "SPEventDispatcher.h"

/** ------------------------------------------------------------------------------------------------
 
 An SPDelayedInvocation is a proxy object that will forward any methods that are called on it
 to a certain target - but only after a certain time has passed.
 
 The easiest way to delay an invocation is by calling [SPJuggler delayInvocationAtTarget:byTime:].
 This method will create a delayed invocation for you, adding it to the juggler right away.
 
 DelayedCall dispatches an Event of type `SP_EVENT_TYPE_REMOVE_FROM_JUGGLER` when it is finished,
 so that the juggler automatically removes it when it's no longer needed.
 
------------------------------------------------------------------------------------------------- */


@interface SPDelayedInvocation : SPEventDispatcher <SPAnimatable>

/// ------------------
/// @name Initializers
/// ------------------

/// Initializes a delayed invocation.
- (id)initWithTarget:(id)target delay:(double)time;

/// Factory method.
+ (id)invocationWithTarget:(id)target delay:(double)time;

/// ----------------
/// @name Properties
/// ----------------

/// The target object to which messages will be forwarded.
@property (nonatomic, readonly) id target;

/// The time messages will be delayed (in seconds).
@property (nonatomic, readonly) double totalTime;

/// The time that has already passed (in seconds).
@property (nonatomic, assign)   double currentTime;

@end
