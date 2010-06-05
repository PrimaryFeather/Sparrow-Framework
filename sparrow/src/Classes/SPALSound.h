//
//  SPALSound.h
//  Sparrow
//
//  Created by Daniel Sperl on 28.05.10.
//  Copyright 2010 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>
#import "SPSound.h"

@interface SPALSound : SPSound 
{
  @private
    uint mBufferID;
    double mDuration;
}

- (id)initWithData:(const void *)data size:(int)size channels:(int)channels frequency:(int)frequency
          duration:(double)duration;

@property (nonatomic, readonly) uint bufferID;

@end
