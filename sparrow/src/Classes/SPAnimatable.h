//
//  SPAnimatable.h
//  Sparrow
//
//  Created by Daniel Sperl on 09.05.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>

/** ------------------------------------------------------------------------------------------------
 
 The SPAnimatable protocol describes objects that are animated depending on the passed time. 
 Any object that implements this protocol can be added to the SPJuggler.
 
 When an object should no longer be animated, it has to be removed from the juggler.
 To do this, you can manually remove it via the method `removeObject:`,
 or the object can request to be removed by dispatching an event with the type
 `SP_EVENT_TYPE_REMOVE_FROM_JUGGLER`. The `SPTween` class is an example of a class that
 dispatches such an event; you don't have to remove tweens manually from the juggler.
 
------------------------------------------------------------------------------------------------- */

@protocol SPAnimatable

/// Advance the animation by a number of seconds.
- (void)advanceTime:(double)seconds;

@end
