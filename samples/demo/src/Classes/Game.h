//
//  Game.h
//  Sparrow
//
//  Created by Daniel Sperl on 16.03.09.
//  Copyright 2011 Gamua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sparrow.h"

@interface Game : SPStage
{
  @private
    SPSprite *mCurrentScene;
    SPSprite *mMainMenu;
    SPButton *mBackButton;
    
    int mNumButtons;
}

@end
