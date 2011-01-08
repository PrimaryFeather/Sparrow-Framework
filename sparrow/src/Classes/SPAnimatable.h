//
//  SPAnimatable.h
//  Sparrow
//
//  Created by Daniel Sperl on 09.05.09.
//  Copyright 2009 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>

/** ------------------------------------------------------------------------------------------------
 
 The SPAnimatable protocol describes objects that are animated depending on the passed time. 
 Any object that implements this protocol can be added to the SPJuggler.
 
------------------------------------------------------------------------------------------------- */

@protocol SPAnimatable

/// Advance the animation by a number of seconds.
- (void)advanceTime:(double)seconds;

/// Indicates if the animation is finished. (The juggler will purge the object.)
@property (nonatomic, readonly) BOOL isComplete;

@end
