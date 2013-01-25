//
//  SPALSoundChannel.h
//  Sparrow
//
//  Created by Daniel Sperl on 28.05.10.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>
#import "SPSoundChannel.h"

@class SPALSound;

/** ------------------------------------------------------------------------------------------------

 The SPALSoundChannel class is a concrete implementation of SPSoundChannel that uses 
 OpenAL internally. 
 
 Don't create instances of this class manually. Use `[SPSound createChannel]` instead.
 
------------------------------------------------------------------------------------------------- */

@interface SPALSoundChannel : SPSoundChannel

/// ------------------
/// @name Initializers
/// ------------------

/// Initializes a sound channel from an SPALSound object.
- (id)initWithSound:(SPALSound *)sound;

@end
