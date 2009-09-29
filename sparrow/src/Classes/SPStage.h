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

@end

