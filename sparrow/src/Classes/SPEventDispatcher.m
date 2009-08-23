//
//  SPEventDispatcher.m
//  Sparrow
//
//  Created by Daniel Sperl on 15.03.09.
//  Copyright 2009 Incognitek. All rights reserved.
//

#import "SPEventDispatcher.h"
#import "SPDisplayObject.h"
#import "SPEvent_Internal.h"
#import "SPMakros.h"
#import "SPNSExtensions.h"

@implementation SPEventDispatcher

- (id)init
{    
    if (self = [super init])
    {        
        mEventListeners = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark -

- (void)addEventListener:(SEL)listener atObject:(id)object forType:(NSString*)eventType
{
    NSMutableArray *listeners = [mEventListeners objectForKey:eventType];
    if (!listeners)
    {
        listeners = [NSMutableArray array];
        [mEventListeners setObject:listeners forKey:eventType];        
    }    
    NSInvocation *invocation = [NSInvocation invocationWithTarget:object selector:listener];
    [invocation retainArguments];
    [listeners addObject:invocation];
}

- (void)removeEventListener:(SEL)listener atObject:(id)object forType:(NSString*)eventType
{
    NSMutableArray *listeners = [mEventListeners objectForKey:eventType];
    if (listeners)
    {
        int index = 0;
        while (index < listeners.count)
        {
            NSInvocation *inv = [listeners objectAtIndex:index];
            
            if (inv.target == object && (listener == nil || inv.selector == listener))            
                [listeners removeObjectAtIndex:index];
            else
                ++index;
        }
        if (listeners.count == 0) [mEventListeners removeObjectForKey:eventType];
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
    // if the event already has a current target, it was re-dispatched by user -> we change the
    // target to 'self' for now, but undo that later on (instead of creating a copy, which could
    // lead to the creation of a huge amount of objects in some cases).
    SPEventDispatcher *previousTarget = event.target;
    if (!event.target || event.currentTarget) event.target = self;
    event.currentTarget = self;    
    
    // we have to make a copy of the listeners, since the event listener could remove the
    // listener while we are iterating
    NSMutableArray *listeners = [[mEventListeners objectForKey:event.type] copy];    
    BOOL stopImmediatPropagation = NO;
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
}

#pragma mark -

- (void)dealloc
{
    [mEventListeners release];
    [super dealloc];
}

@end
