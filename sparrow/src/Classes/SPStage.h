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
}

@property (nonatomic, readonly) float frameRate;

- (id)initWithWidth:(float)width height:(float)height;
- (void)advanceTime:(double)seconds;
- (void)processTouches:(NSSet*)touches;

@end

