//
//  TweenScene.h
//  Demo
//
//  Created by Daniel Sperl on 23.08.09.
//  Copyright 2011 Gamua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sparrow.h"

@interface AnimationScene : SPSprite
{
    SPButton *mStartButton;
    SPButton *mDelayButton;
    SPImage *mEgg;
    SPTextField *mTransitionLabel;
    NSMutableArray *mTransitions;
}

@end
