//
//  SPEventDispatcher.h
//  Sparrow
//
//  Created by Daniel Sperl on 15.03.09.
//  Copyright 2009 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>
#import "SPEvent.h"

@interface SPEventDispatcher : NSObject 
{
  @private
    NSMutableDictionary *mEventListeners;
}

- (void)addEventListener:(SEL)listener atObject:(id)object forType:(NSString*)eventType 
            retainObject:(BOOL)retain;
- (void)addEventListener:(SEL)listener atObject:(id)object forType:(NSString*)eventType;
- (void)removeEventListener:(SEL)listener atObject:(id)object forType:(NSString*)eventType;
- (void)removeEventListenersAtObject:(id)object forType:(NSString*)eventType;
- (void)dispatchEvent:(SPEvent*)event;
- (BOOL)hasEventListenerForType:(NSString*)eventType;

// todo
// - (BOOL)willTriggerForType:(NSString*)eventType; 

@end
