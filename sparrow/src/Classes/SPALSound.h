//
//  SPALSound.h
//  Sparrow
//
//  Created by Daniel Sperl on 28.05.10.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>
#import "SPSound.h"

/** ------------------------------------------------------------------------------------------------ 

 The SPALSound class is a concrete implementation of SPSound that uses OpenAL internally. 
 
 Don't create instances of this class manually. Use `[SPSound initWithContentsOfFile:]` instead.
 
------------------------------------------------------------------------------------------------- */

@interface SPALSound : SPSound 
{
  @private
    uint mBufferID;
    double mDuration;
}

/// --------------------
/// @name Initialization
/// --------------------

/// Initializes a sound with its known properties.
- (id)initWithData:(const void *)data size:(int)size channels:(int)channels frequency:(int)frequency
          duration:(double)duration;

/// ----------------
/// @name Properties
/// ----------------

/// The OpenAL buffer ID of the sound.
@property (nonatomic, readonly) uint bufferID;

@end
