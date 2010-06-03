//
//  Game.m
//  Sparrow
//
//  Created by Daniel Sperl on 16.03.09.
//  Copyright 2009 Incognitek. All rights reserved.
//

#import "Game.h"
#import "AtlasScene.h"
#import "TouchScene.h"
#import "TextScene.h"
#import "AnimationScene.h"
#import "CustomHitTestScene.h"
#import "BenchmarkScene.h"
#import "MovieScene.h"
#import "SoundScene.h"

// --- private interface ---------------------------------------------------------------------------

@interface Game ()

- (void)showScene:(SPSprite *)scene;
- (void)addSceneButton:(SPButton *)button;

@end

// --- class implementation ------------------------------------------------------------------------

@implementation Game

- (id)initWithWidth:(float)width height:(float)height
{
    if (self = [super initWithWidth:width height:height])
    {
        mNumButtons = 0;        
                
        // add background image 
        
        SPImage *background = [SPImage imageWithContentsOfFile:@"Default.png"];
        [self addChild:background];
        
        // this sprite will contain objects that are only visible in the main menu
        mMainMenu = [[SPSprite alloc] init];
        [self addChild:mMainMenu];
        
        SPImage *logo = [SPImage imageWithContentsOfFile:@"logo.png"];
        [mMainMenu addChild:logo];
        
        SPTexture *sceneButtonTexture = [SPTexture textureWithContentsOfFile:@"button_big.png"];
        
        SPButton *atlasButton = [SPButton buttonWithUpState:sceneButtonTexture text:@"Texture Atlas"];
        [atlasButton addEventListener:@selector(onAtlasButtonTriggered:) atObject:self 
                              forType:SP_EVENT_TYPE_TRIGGERED];
        [self addSceneButton:atlasButton];
        
        SPButton *touchButton = [SPButton buttonWithUpState:sceneButtonTexture text:@"Multitouch"];
        [touchButton addEventListener:@selector(onTouchButtonTriggered:) atObject:self
                              forType:SP_EVENT_TYPE_TRIGGERED];        
        [self addSceneButton:touchButton];
        
        SPButton *textButton = [SPButton buttonWithUpState:sceneButtonTexture text:@"TextFields"];
        [textButton addEventListener:@selector(onTextButtonTriggered:) atObject:self
                             forType:SP_EVENT_TYPE_TRIGGERED];
        [self addSceneButton:textButton];

        SPButton *animationButton = [SPButton buttonWithUpState:sceneButtonTexture text:@"Animations"];
        [animationButton addEventListener:@selector(onAnimationButtonTriggered:) atObject:self
                                  forType:SP_EVENT_TYPE_TRIGGERED];
        [self addSceneButton:animationButton];
        
        SPButton *hitTestButton = [SPButton buttonWithUpState:sceneButtonTexture text:@"Custom hit-test"];
        [hitTestButton addEventListener:@selector(onHitTestButtonTriggered:)
                               atObject:self forType:SP_EVENT_TYPE_TRIGGERED];
        [self addSceneButton:hitTestButton];
        
        SPButton *movieButton = [SPButton buttonWithUpState:sceneButtonTexture text:@"Simple Movie"];
        [movieButton addEventListener:@selector(onMovieButtonTriggered:)
                             atObject:self forType:SP_EVENT_TYPE_TRIGGERED];        
        [self addSceneButton:movieButton];
        
        SPButton *soundButton = [SPButton buttonWithUpState:sceneButtonTexture text:@"Sound"];
        [soundButton addEventListener:@selector(onSoundButtonTriggered:) atObject:self
                             forType:SP_EVENT_TYPE_TRIGGERED];
        [self addSceneButton:soundButton];
        
        SPButton *benchmarkButton = [SPButton buttonWithUpState:sceneButtonTexture text:@"Benchmark"];
        [benchmarkButton addEventListener:@selector(onBenchmarkButtonTriggered:) atObject:self
                                  forType:SP_EVENT_TYPE_TRIGGERED];
        [self addSceneButton:benchmarkButton];
        
        SPTexture *backButtonTexture = [SPTexture textureWithContentsOfFile:@"button_back.png"];
        mBackButton = [[SPButton alloc] initWithUpState:backButtonTexture text:@"back"];
        mBackButton.visible = NO;
        mBackButton.x = (int)(self.stage.width - mBackButton.width) / 2;
        mBackButton.y = self.stage.height - mBackButton.height + 1;
        [mBackButton addEventListener:@selector(onBackButtonTriggered:) atObject:self 
                              forType:SP_EVENT_TYPE_TRIGGERED];
        [self addChild:mBackButton]; 
         
    }
    return self;
}

- (void)showScene:(SPSprite*)scene
{
    mCurrentScene = scene;
    [self addChild:scene];

    mMainMenu.visible = NO;
    mBackButton.visible = YES;
}

- (void)addSceneButton:(SPButton *)button
{
    button.x = mNumButtons % 2 == 0 ? 28 : 167;
    button.y = 200 + (mNumButtons / 2) * 52;    
    [mMainMenu addChild:button];
    mNumButtons++;
}

#pragma mark -

- (void)onBackButtonTriggered:(SPEvent*)event
{
    [mCurrentScene removeFromParent];
    mCurrentScene = nil;
    
    mBackButton.visible = NO;
    mMainMenu.visible = YES;    
}

- (void)onAtlasButtonTriggered:(SPEvent*)event
{
    SPSprite *scene = [[AtlasScene alloc] init];
    [self showScene:scene];
    [scene release];    
}

- (void)onTouchButtonTriggered:(SPEvent*)event
{
    SPSprite *scene = [[TouchScene alloc] init];
    [self showScene:scene];
    [scene release];
}

- (void)onTextButtonTriggered:(SPEvent*)event
{
    SPSprite *scene = [[TextScene alloc] init];
    [self showScene:scene];
    [scene release];
}

- (void)onAnimationButtonTriggered:(SPEvent*)event
{
    SPSprite *scene = [[AnimationScene alloc] init];
    [self showScene:scene];
    [scene release];
}

- (void)onHitTestButtonTriggered:(SPEvent*)event
{
    SPSprite *scene = [[CustomHitTestScene alloc] init];
    [self showScene:scene];
    [scene release];
}

- (void)onMovieButtonTriggered:(SPEvent *)event
{
    SPSprite *scene = [[MovieScene alloc] init];
    [self showScene:scene];
    [scene release];
}

- (void)onSoundButtonTriggered:(SPEvent *)event
{
    SPSprite *scene = [[SoundScene alloc] init];
    [self showScene:scene];
    [scene release];
}

- (void)onBenchmarkButtonTriggered:(SPEvent*)event
{
    SPSprite *scene = [[BenchmarkScene alloc] init];
    [self showScene:scene];
    [scene release];    
}

#pragma mark -

- (void)dealloc
{
    [mMainMenu release]; // automatically releases all childs   
    [mBackButton release];    
    [mCurrentScene release];
    [super dealloc];
}

@end
