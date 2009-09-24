//
//  Game.h
//  Sparrow
//
//  Created by Daniel Sperl on 16.03.09.
//  Copyright 2009 Incognitek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sparrow.h"

@interface Game : SPStage
{
  @private
    SPSprite *mCurrentScene;
    SPSprite *mSceneButtons;
    SPButton *mBackButton;    
    
    SPButton *mAtlasButton;    
    SPButton *mTouchButton;
    SPButton *mTextButton;
    SPButton *mAnimationButton;
    SPButton *mCustomHitTestButton;
    SPButton *mBenchmarkButton;

}

@end
