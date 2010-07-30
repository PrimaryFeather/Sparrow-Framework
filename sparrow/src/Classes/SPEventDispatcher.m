//
//  SPEventDispatcher.m
//  Sparrow
//
//  Created by Daniel Sperl on 15.03.09.
//  Copyright 2009 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPEventDispatcher.h"
#import "SPDisplayObject.h"
#import "SPEvent_Internal.h"
#import "SPMacros.h"
#import "SPNSExtensions.h"

@implementation SPEventDispatcher

- (void)addEventListener:(SEL)listener atObject:(id)object forType:(NSString*)eventType 
            retainObject:(BOOL)doRetain
{
    if (!mEventListeners)
        mEventListeners = [[NSMutableDictionary alloc] init];
    
    NSInvocation *invocation = [NSInvocation invocationWithTarget:object selector:listener];
    if (doRetain) [invocation retainArguments];    
    
    // When an event listener is added or removed, a new NSArray object is created, instead of 
    // changing the array. The reason for this is that we can avoid creating a copy of the NSArray 
    // in the "dispatchEvent"-method, which is called far more often than 
    // "add"- and "removeEventListener".    
    
    NSArray *listeners = [mEventListeners objectForKey:eventType];
    if (!listeners)
    {
        listeners = [[NSArray alloc] initWithObjects:invocation, nil];
        [mEventListeners setObject:listeners forKey:eventType];
        [listeners release];
    }
    else 
    {
        listeners = [listeners arrayByAddingObject:invocation];
        [mEventListeners setObject:listeners forKey:eventType];
    }    
}

- (void)addEventListener:(SEL)listener atObject:(id)object forType:(NSString*)eventType
{
    [self addEventListener:listener atObject:object forType:eventType retainObject:NO];
}

- (void)removeEventListener:(SEL)listener atObject:(id)object forType:(NSString*)eventType
{
    NSArray *listeners = [mEventListeners objectForKey:eventType];
    if (listeners)
    {
        NSMutableArray *remainingListeners = [[NSMutableArray alloc] init];
        for (NSInvocation *inv in listeners)
        {
            if (inv.target != object || (listener != nil && inv.selector != listener))
                [remainingListeners addObject:inv];
        }
                
        if (remainingListeners.count == 0) [mEventListeners removeObjectForKey:eventType];
        else [mEventListeners setObject:remainingListeners forKey:eventType];
        
        [remainingListeners release];
    }
}

- (void)removeEventListenersAtObject:(id)object forType:(NSString*)eventType
{
    [self removeEventListener:nil atObject:object forType:eventType];
}

- (BOOL)hasEventListenerForType:(NSString*)eventType
{
    return [mEventListeners objectForKey:eventType] != nil;
}

- (void)dispatchEvent:(SPEvent*)event
{
    NSMutableArray *listeners = [mEventListeners objectForKey:event.type];   
    if (!event.bubbles && !listeners) return; // no need to do anything.
    
    // if the event already has a current target, it was re-dispatched by user -> we change the
    // target to 'self' for now, but undo that later on (instead of creating a copy, which could
    // lead to the creation of a huge amount of objects).
    SPEventDispatcher *previousTarget = event.target;
    if (!event.target || event.currentTarget) event.target = self;
    event.currentTarget = self;        

    [self retain]; // the event listener could release 'self', so we have to make sure that it 
                   // stays valid while we're here.
    
    BOOL stopImmediatPropagation = NO;    
    if (listeners.count != 0)
    {    
        // we can enumerate directly over the array, since "add"- and "removeEventListener" won't
        // change it, but instead always create a new array.
        [listeners retain];
        for (NSInvocation *inv in listeners)
        {
            [inv setArgument:&event atIndex:2];
            [inv invoke];
            if (event.stopsImmediatePropagation) 
            {
                stopImmediatPropagation = YES;
                break;
            }
        }
        [listeners release];
    }
    
    if (!stopImmediatPropagation)
    {
        event.currentTarget = nil; // this is how we can find out later if the event was redispatched
        if (event.bubbles && !event.stopsPropagation && [self isKindOfClass:[SPDisplayObject class]])
        {
            SPDisplayObject *target = (SPDisplayObject*)self;
            [target.parent dispatchEvent:event];            
        }
    }
    
    if (previousTarget) event.target = previousTarget;
    
    // we use autorelease instead of release to avoid having to make additional "retain"-calls
    // in calling methods (like "dispatchEventsOnChildren"). Those methods might be called very
    // often, so we save some time by avoiding that.
    [self autorelease];
}

- (void)dealloc
{
    [mEventListeners release];
    [super dealloc];
}

@end
