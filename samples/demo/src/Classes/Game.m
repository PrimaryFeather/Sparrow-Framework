//
//  Game.m
//  Sparrow
//
//  Created by Daniel Sperl on 16.03.09.
//  Copyright 2011 Gamua. All rights reserved.
//

#import "Game.h"
#import "TextureScene.h"
#import "TouchScene.h"
#import "TextScene.h"
#import "AnimationScene.h"
#import "CustomHitTestScene.h"
#import "BenchmarkScene.h"
#import "MovieScene.h"
#import "SoundScene.h"
#import "RenderTextureScene.h"

@implementation Game

- (id)initWithWidth:(float)width height:(float)height
{
    if ((self = [super initWithWidth:width height:height]))
    {
        // add background image
        SPImage *background = [SPImage imageWithContentsOfFile:@"Default.png"];
        [self addChild:background];
        
        // this sprite will contain objects that are only visible in the main menu
        mMainMenu = [[SPSprite alloc] init];
        [self addChild:mMainMenu];
        
        SPImage *logo = [SPImage imageWithContentsOfFile:@"logo.png"];
        logo.y = 5;
        [mMainMenu addChild:logo];
        
        // choose which scenes will be accessible
        NSArray *scenesToCreate = [NSArray arrayWithObjects:
                                   @"Textures", [TextureScene class],
                                   @"Multitouch", [TouchScene class],
                                   @"TextFields", [TextScene class],
                                   @"Animations", [AnimationScene class],
                                   @"Custom hit-test", [CustomHitTestScene class],
                                   @"Movie Clip", [MovieScene class],
                                   @"Sound", [SoundScene class],
                                   @"RenderTexture", [RenderTextureScene class],
                                   @"Benchmark", [BenchmarkScene class], nil];
        
        SPTexture *buttonTexture = [SPTexture textureWithContentsOfFile:@"button_big.png"];
        int count = 0;
        int index = 0;
        
        // create buttons for each scene
        while (index < scenesToCreate.count)
        {
            NSString *sceneTitle = [scenesToCreate objectAtIndex:index++];
            Class sceneClass = [scenesToCreate objectAtIndex:index++];
            
            SPButton *button = [SPButton buttonWithUpState:buttonTexture text:sceneTitle];
            button.x = count % 2 == 0 ? 28 : 167;
            button.y = 150 + (count / 2) * 52 + (count % 2) * 26;    
            button.name = NSStringFromClass(sceneClass);
            [button addEventListener:@selector(onButtonTriggered:) atObject:self 
                             forType:SP_EVENT_TYPE_TRIGGERED];
            [mMainMenu addChild:button];
            ++count;
        }
        
        [self addEventListener:@selector(onSceneClosing:) atObject:self
                       forType:EVENT_TYPE_SCENE_CLOSING];
        
    }
    return self;
}

- (void)onButtonTriggered:(SPEvent *)event
{
    if (mCurrentScene) return;
    
    // the class name of the scene is saved in the "name" property of the button. 
    SPButton *button = (SPButton *)event.target;
    Class sceneClass = NSClassFromString(button.name);
    
    // create an instance of that class and add it to the display tree.
    mCurrentScene = [[sceneClass alloc] init];
    mMainMenu.visible = NO;
    [self addChild:mCurrentScene];
}

- (void)onSceneClosing:(SPEvent *)event
{
    [mCurrentScene removeFromParent];
    [mCurrentScene release];
    mCurrentScene = nil;
    mMainMenu.visible = YES;
}

- (void)dealloc
{
    [mMainMenu release]; // automatically releases all children   
    [mCurrentScene release];
    [super dealloc];
}

@end
