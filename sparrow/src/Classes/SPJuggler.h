//
//  SPJuggler.h
//  Sparrow
//
//  Created by Daniel Sperl on 09.05.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>
#import "SPAnimatable.h"
#import "SPMacros.h"

/** ------------------------------------------------------------------------------------------------

 The SPJuggler takes objects that implement SPAnimatable (e.g. `SPTween`s) and executes them.
 
 A juggler is a simple object. It does no more than saving a list of objects implementing 
 `SPAnimatable` and advancing their time if it is told to do so (by calling its own `advanceTime:`
 method). When an animation is completed, it throws it away.
 
 There is a default juggler in every stage. You can access it by calling
 
	SPJuggler *juggler = self.stage.juggler;
 
 in any object that has access to the stage. You can, however, create juggler objects yourself, too.
 That way, you can group your game into logical components that handle their animations independently.
 
 A cool feature of the juggler is to delay method calls. Say you want to remove an object from its
 parent 2 seconds from now. Call:

	[[juggler delayInvocationAtTarget:object byTime:2.0] removeFromParent];
 
 This line of code will execute the following method 2 seconds in the future:

 	[object removeFromParent];
 
 The Sparrow blog contains three extensive articles about the juggler:
 
 - http://www.sparrow-framework.org/2010/08/tweens-jugglers-animating-your-stage/
 - http://www.sparrow-framework.org/2010/09/tweens-jugglers-an-in-depth-look-at-the-juggler/
 - http://www.sparrow-framework.org/2010/10/tweens-jugglers-unleashed/
 
------------------------------------------------------------------------------------------------- */

@interface SPJuggler : NSObject <SPAnimatable>
{
  @private
    NSMutableArray *mObjects;
    double mElapsedTime;
}

/// ------------------
/// @name Initializers
/// ------------------

/// Factory method.
+ (SPJuggler *)juggler;

/// -------------
/// @name Methods
/// -------------

/// Adds an object to the juggler.
- (void)addObject:(id<SPAnimatable>)object;

/// Removes an object from the juggler.
- (void)removeObject:(id<SPAnimatable>)object;

/// Removes all objects at once.
- (void)removeAllObjects;

/// Removes all objects of type `SPTween` that have a certain target.
/// DEPRECATED! Use `removeObjectsWithTarget` instead.
- (void)removeTweensWithTarget:(id)object SP_DEPRECATED;

/// Removes all objects with a `target` property referencing a certain object (e.g. tweens or
/// delayed invocations).
- (void)removeObjectsWithTarget:(id)object;

/// Delays the execution of a certain method. Returns a proxy object on which to call the method
/// instead. Execution will be delayed until `time` has passed.
- (id)delayInvocationAtTarget:(id)target byTime:(double)time;

/// ----------------
/// @name Properties
/// ----------------

/// The total life time of the juggler.
@property (nonatomic, readonly) double elapsedTime;

@end
