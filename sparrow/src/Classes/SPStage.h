//
//  SPStage.h
//  Sparrow
//
//  Created by Daniel Sperl on 15.03.09.
//  Copyright 2009 Incognitek. All rights reserved.
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
    
    // fps calculation
    double mCumulatedTime;
    int mFrameCount;
    float mFrameRate;
    
    SPTouchProcessor *mTouchProcessor;
    SPJuggler *mJuggler;
}

@property (nonatomic, readonly) float frameRate;
@property (nonatomic, readonly) SPJuggler *juggler;

- (id)initWithWidth:(float)width height:(float)height;
- (void)advanceTime:(double)seconds;
- (void)processTouches:(NSSet*)touches;

@end

