//
//  Game.h
//  Sparrow
//
//  Created by Daniel Sperl on 16.03.09.
//  Copyright 2011 Gamua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Scene.h"

@interface Game : SPStage
{
  @private
    Scene *mCurrentScene;
    SPSprite *mMainMenu;
}

@end
