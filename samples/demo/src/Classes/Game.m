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

// --- private interface ---------------------------------------------------------------------------

@interface Game ()

- (void)showScene:(SPSprite*)scene;

@end

// --- class implementation ------------------------------------------------------------------------

@implementation Game

- (id)initWithWidth:(float)width height:(float)height
{
    if (self = [super initWithWidth:width height:height])
    {
        SPTexture *sceneButtonTexture = [SPTexture textureWithContentsOfFile:@"button_blue.png"];        

        mSceneButtons = [[SPSprite alloc] init];
        mSceneButtons.x = (self.width - sceneButtonTexture.width) / 2.0f;
        mSceneButtons.y = 20;        
        [self addChild:mSceneButtons];        
        
        mAtlasButton = [SPButton buttonWithUpState:sceneButtonTexture text:@"Texture Atlas"];
        [mAtlasButton addEventListener:@selector(onAtlasButtonTriggered:) atObject:self 
                               forType:SP_EVENT_TYPE_TRIGGERED];
        [mSceneButtons addChild:mAtlasButton];
        
        mTouchButton = [SPButton buttonWithUpState:sceneButtonTexture text:@"Multitouch"];
        [mTouchButton addEventListener:@selector(onTouchButtonTriggered:) atObject:self
                               forType:SP_EVENT_TYPE_TRIGGERED];
        mTouchButton.y = mAtlasButton.y + mAtlasButton.height;
        [mSceneButtons addChild:mTouchButton];
        
        mTextButton = [SPButton buttonWithUpState:sceneButtonTexture text:@"TextFields"];
        [mTextButton addEventListener:@selector(onTextButtonTriggered:) atObject:self
                               forType:SP_EVENT_TYPE_TRIGGERED];
        mTextButton.y = mTouchButton.y + mTouchButton.height;
        [mSceneButtons addChild:mTextButton];

        mAnimationButton = [SPButton buttonWithUpState:sceneButtonTexture text:@"Animations"];
        [mAnimationButton addEventListener:@selector(onAnimationButtonTriggered:) atObject:self
                               forType:SP_EVENT_TYPE_TRIGGERED];
        mAnimationButton.y = mTextButton.y + mTextButton.height;
        [mSceneButtons addChild:mAnimationButton];        
        
        mCustomHitTestButton = [SPButton buttonWithUpState:sceneButtonTexture text:@"Custom hit-test"];
        [mCustomHitTestButton addEventListener:@selector(onCustomHitTestButtonTriggered:)
                                      atObject:self forType:SP_EVENT_TYPE_TRIGGERED];
        mCustomHitTestButton.y =  mAnimationButton.y + mAnimationButton.height;
        [mSceneButtons addChild:mCustomHitTestButton];        

        mBenchmarkButton = [SPButton buttonWithUpState:sceneButtonTexture text:@"Benchmark"];
        [mBenchmarkButton addEventListener:@selector(onBenchmarkButtonTriggered:) atObject:self
                              forType:SP_EVENT_TYPE_TRIGGERED];
        mBenchmarkButton.y = mCustomHitTestButton.y + mCustomHitTestButton.height;
        [mSceneButtons addChild:mBenchmarkButton];
        
        SPTexture *backButtonTexture = [SPTexture textureWithContentsOfFile:@"button_yellow.png"];
        mBackButton = [[SPButton alloc] initWithUpState:backButtonTexture text:@"back"];
        mBackButton.isVisible = NO;
        mBackButton.x = mSceneButtons.x;
        mBackButton.y = self.stage.height - mBackButton.height - 20;
        [mBackButton addEventListener:@selector(onBackButtonTriggered:) atObject:self 
                              forType:SP_EVENT_TYPE_TRIGGERED];
        [self addChild:mBackButton]; 
    }
    return self;
}

- (void)showScene:(SPSprite*)scene
{
    mCurrentScene = scene;
    [self addChild:scene atIndex:0];
    
    mSceneButtons.isVisible = NO;
    mBackButton.isVisible = YES;
}

- (void)onBackButtonTriggered:(SPEvent*)event
{
    [mCurrentScene removeFromParent];
    mCurrentScene = nil;
    
    mBackButton.isVisible = NO;
    mSceneButtons.isVisible = YES;    
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

- (void)onCustomHitTestButtonTriggered:(SPEvent*)event
{
    SPSprite *scene = [[CustomHitTestScene alloc] init];
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
    [mAtlasButton removeEventListenersAtObject:self forType:SP_EVENT_TYPE_TRIGGERED];
    [mTouchButton removeEventListenersAtObject:self forType:SP_EVENT_TYPE_TRIGGERED];
    [mTextButton  removeEventListenersAtObject:self forType:SP_EVENT_TYPE_TRIGGERED];
    [mAnimationButton removeEventListenersAtObject:self forType:SP_EVENT_TYPE_TRIGGERED];
    [mCustomHitTestButton removeEventListenersAtObject:self forType:SP_EVENT_TYPE_TRIGGERED];
    [mBenchmarkButton removeEventListenersAtObject:self forType:SP_EVENT_TYPE_TRIGGERED];
    
    [mSceneButtons release]; // automatically releases all child buttons    
    [mBackButton release];
    [mBackButton removeEventListenersAtObject:self forType:SP_EVENT_TYPE_TRIGGERED];
    
    [mCurrentScene release];
    
    [super dealloc];
}

@end
