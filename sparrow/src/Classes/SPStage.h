//
//  SPStage.h
//  Sparrow
//
//  Created by Daniel Sperl on 15.03.09.
//  Copyright 2009 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>
#import "SPDisplayObjectContainer.h"

@class SPTouchProcessor;
@class SPJuggler;

@interface SPStage : SPDisplayObjectContainer
{
  @private
    float mWidth;
    float mHeight;
 
    // helpers
    SPTouchProcessor *mTouchProcessor;
    SPJuggler *mJuggler;
    
    id mNativeView;
}

@property (nonatomic, assign)   float frameRate;
@property (nonatomic, readonly) SPJuggler *juggler;
@property (nonatomic, readonly) id nativeView;

- (id)initWithWidth:(float)width height:(float)height;

- (void)advanceTime:(double)seconds;
- (void)processTouches:(NSSet*)touches;

+ (void)setSupportHighResolutions:(BOOL)support;
+ (BOOL)supportHighResolutions;
+ (float)contentScaleFactor;

@end
