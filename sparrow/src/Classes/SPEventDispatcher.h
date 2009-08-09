//
//  SPEventDispatcher.h
//  Sparrow
//
//  Created by Daniel Sperl on 15.03.09.
//  Copyright 2009 Incognitek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPEvent.h"

@interface SPEventDispatcher : NSObject 
{
  @private
    NSMutableDictionary *mEventListeners;
}

- (id)init;
- (void)addEventListener:(SEL)listener atObject:(id)object forType:(NSString*)eventType;
- (void)removeEventListener:(SEL)listener atObject:(id)object forType:(NSString*)eventType;
- (void)removeEventListenersAtObject:(id)object forType:(NSString*)eventType;
- (void)dispatchEvent:(SPEvent*)event;
- (BOOL)hasEventListenerForType:(NSString*)eventType;

// todo
// - (BOOL)willTriggerForType:(NSString*)eventType; 

@end
