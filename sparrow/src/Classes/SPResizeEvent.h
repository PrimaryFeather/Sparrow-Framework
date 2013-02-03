//
//  SPResizeEvent.h
//  Sparrow
//
//  Created by Daniel Sperl on 01.10.2012.
//  Copyright 2012 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPEvent.h"

#define SP_EVENT_TYPE_RESIZE @"resize"

@interface SPResizeEvent : SPEvent

- (id)initWithType:(NSString *)type width:(float)width height:(float)height 
     animationTime:(double)time;

@property (nonatomic, readonly) float width;
@property (nonatomic, readonly) float height;
@property (nonatomic, readonly) double animationTime;
@property (nonatomic, readonly) BOOL isPortrait;

@end
