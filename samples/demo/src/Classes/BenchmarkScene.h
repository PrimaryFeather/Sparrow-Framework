//
//  BenchmarkScene.h
//  Demo
//
//  Created by Daniel Sperl on 18.09.09.
//  Copyright 2011 Gamua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Scene.h"

@interface BenchmarkScene : Scene
{
    SPButton *mStartButton;
    SPTextField *mResultText;
    SPTexture *mTexture;

    SPSprite *mContainer;
    int mFrameCount;
    double mElapsed; 
    BOOL mStarted;
    int mFailCount;
    int mWaitFrames;
}

@end
