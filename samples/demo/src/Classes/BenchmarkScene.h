//
//  BenchmarkScene.h
//  Demo
//
//  Created by Daniel Sperl on 18.09.09.
//  Copyright 2009 Incognitek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BenchmarkScene : SPSprite 
{
    SPButton *mStartButton;
    SPTextField *mResultText;
    SPJuggler *mJuggler;
    SPTextureAtlas *mAtlas;

    SPSprite *mContainer;
    int mFrameCount;
    double mStartMoment;
 
}

@end
