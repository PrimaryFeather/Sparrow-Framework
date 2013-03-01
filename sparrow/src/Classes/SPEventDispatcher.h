//
//  SPEventDispatcher.h
//  Sparrow
//
//  Created by Daniel Sperl on 15.03.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>
#import "SPEvent.h"

typedef void (^SPEventBlock)(SPEvent *event);

/** ------------------------------------------------------------------------------------------------

 The SPEventDispatcher class is the base for all classes that dispatch events.
 
 The event mechanism is a key feature of Sparrow's architecture. Objects can communicate with 
 each other over events.
 
 An event dispatcher can dispatch events (objects of type SPEvent or one of its subclasses) 
 to objects that have registered themselves as listeners. A string (the event type) is used to 
 identify different events.
 
 Here is a sample:
 
	// dispatching an event
	[self dispatchEvent:[SPEvent eventWithType:@"eventType"]];
	
	// listening to an event from 'object'
	[object addEventListener:@selector(onEvent:) atObject:self forType:@"eventType"];
	
	// the corresponding event listener
	- (void)onEvent:(SPEvent *)event
	{
	    // an event was triggered
	}
 
 As SPDisplayObject, the base object of all rendered objects, inherits from SPEventDispatcher,
 the event mechanism is tightly bound to the display list. Events that have their `bubbles`-property
 enabled will rise up the display list until they reach its root (normally the stage). That means
 that a listener can register for the event type not only on the object that will dispatch it, but
 on any object that is a direct or indirect parent of the dispatcher. 
 
 Different to _Adobe Flash_, events in Sparrow do not have a capture-phase.
 
 @see [SPEvent]
 @see [SPDisplayObject]
 
------------------------------------------------------------------------------------------------- */

@interface SPEventDispatcher : NSObject

/// -------------
/// @name Methods
/// -------------

/// Registers an event listener which is implemented through a block.
- (void)addEventListenerForType:(NSString *)eventType block:(SPEventBlock)block;

/// Registers an event listener at a certain object.
- (void)addEventListener:(SEL)selector atObject:(id)object forType:(NSString *)eventType;

/// Removes an event listener from an object.
- (void)removeEventListener:(SEL)selector atObject:(id)object forType:(NSString *)eventType;

/// Removes all event listeners from an object that have a certain type.
- (void)removeEventListenersAtObject:(id)object forType:(NSString *)eventType;

/// Removes an event listener that was implemented through a block.
- (void)removeEventListenerForType:(NSString *)eventType block:(SPEventBlock)block;

/// Dispatches an event to all objects that have registered for events of the same type.
- (void)dispatchEvent:(SPEvent*)event;

/// Creates a new (non-bubbling) event object and dispatches it.
- (void)dispatchEventWithType:(NSString *)type;

/// Creates a new event object and dispatches it.
- (void)dispatchEventWithType:(NSString *)type bubbles:(BOOL)bubbles;

/// Returns if there are listeners registered for a certain event type.
- (BOOL)hasEventListenerForType:(NSString *)eventType;

@end
