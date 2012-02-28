//
//  GameController.h
//  AppScaffold
//

#import "SPStage.h"
#import "Game.h"

@interface GameController : SPStage
{
  @private
    Game *mGame;
}

- (void)rotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
                       animationTime:(double)time;

@end
