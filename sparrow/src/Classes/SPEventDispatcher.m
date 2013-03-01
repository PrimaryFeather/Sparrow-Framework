//
//  SPEventDispatcher.m
//  Sparrow
//
//  Created by Daniel Sperl on 15.03.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPEventDispatcher.h"
#import "SPDisplayObject.h"
#import "SPDisplayObjectContainer.h"
#import "SPEvent_Internal.h"
#import "SPMacros.h"
#import "SPNSExtensions.h"
#import "SPEventListener.h"

@implementation SPEventDispatcher
{
    NSMutableDictionary *mEventListeners;
}

- (void)addEventListener:(SPEventListener *)listener forType:(NSString *)eventType
{
    if (!mEventListeners)
        mEventListeners = [[NSMutableDictionary alloc] init];
    
    // When an event listener is added or removed, a new NSArray object is created, instead of
    // changing the array. The reason for this is that we can avoid creating a copy of the NSArray
    // in the "dispatchEvent"-method, which is called far more often than
    // "add"- and "removeEventListener".
    
    NSArray *listeners = mEventListeners[eventType];
    if (!listeners)
    {
        listeners = @[listener];
        mEventListeners[eventType] = listeners;
    }
    else
    {
        listeners = [listeners arrayByAddingObject:listener];
        mEventListeners[eventType] = listeners;
    }
}

- (void)addEventListenerForType:(NSString *)eventType block:(SPEventBlock)block
{
    SPEventListener *listener = [[SPEventListener alloc] initWithBlock:block];
    [self addEventListener:listener forType:eventType];
}

- (void)addEventListener:(SEL)selector atObject:(id)object forType:(NSString*)eventType
{
    SPEventListener *listener = [[SPEventListener alloc] initWithTarget:object selector:selector];
    [self addEventListener:listener forType:eventType];
}

- (void)removeEventListenersForType:(NSString *)eventType withTarget:(id)object
                        andSelector:(SEL)selector orBlock:(SPEventBlock)block
{
    NSArray *listeners = mEventListeners[eventType];
    if (listeners)
    {
        NSMutableArray *remainingListeners = [[NSMutableArray alloc] init];
        for (SPEventListener *listener in listeners)
        {
            if (![listener fitsTarget:object andSelector:selector orBlock:block])
                [remainingListeners addObject:listener];
        }
        
        if (remainingListeners.count == 0) [mEventListeners removeObjectForKey:eventType];
        else mEventListeners[eventType] = remainingListeners;
    }
}

- (void)removeEventListener:(SEL)selector atObject:(id)object forType:(NSString*)eventType
{
    [self removeEventListenersForType:eventType withTarget:object andSelector:selector orBlock:nil];
}

- (void)removeEventListenersAtObject:(id)object forType:(NSString*)eventType
{
    [self removeEventListenersForType:eventType withTarget:object andSelector:nil orBlock:nil];
}

- (void)removeEventListenerForType:(NSString *)eventType block:(SPEventBlock)block;
{
    [self removeEventListenersForType:eventType withTarget:nil andSelector:nil orBlock:block];
}

- (BOOL)hasEventListenerForType:(NSString*)eventType
{
    return mEventListeners[eventType] != nil;
}

- (void)dispatchEventWithType:(NSString *)type
{
    if ([self hasEventListenerForType:type])
        [self dispatchEvent:[[SPEvent alloc] initWithType:type bubbles:NO]];
}

- (void)dispatchEventWithType:(NSString *)type bubbles:(BOOL)bubbles
{
    if (bubbles || [self hasEventListenerForType:type])
        [self dispatchEvent:[[SPEvent alloc] initWithType:type bubbles:bubbles]];
}

- (void)dispatchEvent:(SPEvent*)event
{
    NSMutableArray *listeners = mEventListeners[event.type];   
    if (!event.bubbles && !listeners) return; // no need to do anything.
    
    // if the event already has a current target, it was re-dispatched by user -> we change the
    // target to 'self' for now, but undo that later on (instead of creating a copy, which could
    // lead to the creation of a huge amount of objects).
    SPEventDispatcher *previousTarget = event.target;
    if (!previousTarget || event.currentTarget) event.target = self;
    
    BOOL stopImmediatePropagation = NO;
    if (listeners.count != 0)
    {
        event.currentTarget = self;
        
        // we can enumerate directly over the array, since "add"- and "removeEventListener" won't
        // change it, but instead always create a new array.
        for (SPEventListener *listener in listeners)
        {
            [listener invokeWithEvent:event];
            
            if (event.stopsImmediatePropagation)
            {
                stopImmediatePropagation = YES;
                break;
            }
        }
    }
    
    if (!stopImmediatePropagation && event.bubbles && !event.stopsPropagation && 
        [self isKindOfClass:[SPDisplayObject class]])
    {
        event.currentTarget = nil; // this is how we can find out later if the event was redispatched
        SPDisplayObject *target = (SPDisplayObject*)self;
        [target.parent dispatchEvent:event];
    }
    
    if (previousTarget) event.target = previousTarget;
}

@end
