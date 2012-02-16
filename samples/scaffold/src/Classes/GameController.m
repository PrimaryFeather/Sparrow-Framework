//
//  GameController.m
//  AppScaffold
//

#import "GameController.h"

@implementation GameController

- (id)initWithWidth:(float)width height:(float)height
{
    if ((self = [super initWithWidth:width height:height]))
    {
        game = [[Game alloc] initWithWidth:width height:height];
        
        game.pivotX = game.x = width  / 2;
        game.pivotY = game.y = height / 2;
        
        [self addChild:game];
    }
    
    return self;
}

- (void)dealloc
{
    [game release];
    [super dealloc];
}

@end
