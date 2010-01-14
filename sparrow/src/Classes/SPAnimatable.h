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

@protocol SPAnimatable

- (void)advanceTime:(double)seconds;

@property (nonatomic, readonly) BOOL isComplete;

@end
