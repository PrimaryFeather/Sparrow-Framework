//
//  BenchmarkScene.m
//  Demo
//
//  Created by Daniel Sperl on 18.09.09.
//  Copyright 2011 Gamua. All rights reserved.
//

#import "BenchmarkScene.h"
#import <QuartzCore/QuartzCore.h> // for CACurrentMediaTime()

@interface BenchmarkScene ()

- (void)addTestObjects;
- (void)benchmarkComplete;

@end

#define WAIT_TIME 0.1f

@implementation BenchmarkScene
{
    SPButton *mStartButton;
    SPTextField *mResultText;
    SPTexture *mTexture;
    
    SPSprite *mContainer;
    int mFrameCount;
    double mElapsed;
    BOOL mStarted;
    int mFailCount;
    int mWaitFrames;
}

- (id)init
{
    if ((self = [super init]))
    {
        mTexture = [[SPTexture alloc] initWithContentsOfFile:@"benchmark_object.png"];
        
        // the container will hold all test objects
        mContainer = [[SPSprite alloc] init];
        mContainer.touchable = NO; // we do not need touch events on the test objects -- thus, 
                                   // it is more efficient to disable them.
        [self addChild:mContainer atIndex:0];        
        
        SPTexture *buttonTexture = [SPTexture textureWithContentsOfFile:@"button_normal.png"];
        
        // we create a button that is used to start the benchmark.
        mStartButton = [[SPButton alloc] initWithUpState:buttonTexture
                                                    text:@"Start benchmark"];
        [mStartButton addEventListener:@selector(onStartButtonPressed:) atObject:self
                               forType:SP_EVENT_TYPE_TRIGGERED];
        mStartButton.x = 160 - (int)(mStartButton.width / 2);
        mStartButton.y = 20;
        [self addChild:mStartButton];
        
        mStarted = NO;
        
        [self addEventListener:@selector(onEnterFrame:) atObject:self forType:SP_EVENT_TYPE_ENTER_FRAME];
    }
    return self;    
}

- (void)onEnterFrame:(SPEnterFrameEvent *)event
{    
    if (!mStarted) return;
    
    mElapsed += event.passedTime;
    ++mFrameCount;
    
    if (mFrameCount % mWaitFrames == 0)
    {
        float targetFPS = Sparrow.currentController.framesPerSecond;
        float realFPS = mWaitFrames / mElapsed;
        
        if (ceilf(realFPS) >= targetFPS)
        {
            mFailCount = 0;
            [self addTestObjects];
        }
        else
        {
            ++mFailCount;
            
            if (mFailCount > 15)
                mWaitFrames = 5; // slow down creation process to be more exact
            if (mFailCount > 20)
                mWaitFrames = 10;
            if (mFailCount == 25)
                [self benchmarkComplete]; // target fps not reached for a while
        }
        
        mElapsed = mFrameCount = 0;
    }
    
    for (SPDisplayObject *child in mContainer)    
        child.rotation += 0.05f;    
}

- (void)onStartButtonPressed:(SPEvent*)event
{
    NSLog(@"starting benchmark");
    
    mStartButton.visible = NO;
    mStarted = YES;
    mFailCount = 0;
    mWaitFrames = 3;
    
    [mResultText removeFromParent];
    mResultText = nil;
    
    mFrameCount = 0;
    [self addTestObjects];
}

- (void)benchmarkComplete
{
    mStarted = NO;
    mStartButton.visible = YES;
    
    int frameRate = Sparrow.currentController.framesPerSecond;
    
    NSLog(@"benchmark complete!");
    NSLog(@"fps: %d", frameRate);
    NSLog(@"number of objects: %d", mContainer.numChildren);
    
    NSString *resultString = [NSString stringWithFormat:@"Result:\n%d objects\nwith %d fps", 
                              mContainer.numChildren, frameRate];
    
    mResultText = [SPTextField textFieldWithWidth:250 height:200 text:resultString];
    mResultText.fontSize = 30;
    mResultText.color = 0x0;
    mResultText.x = (320 - mResultText.width) / 2;
    mResultText.y = (480 - mResultText.height) / 2;
    
    [self addChild:mResultText];
    [mContainer removeAllChildren];
}

- (void)addTestObjects
{
    int border = 15;
    int numObjects = mFailCount > 20 ? 2 : 5;
    
    for (int i=0; i<numObjects; ++i)
    {   
        SPImage *egg = [[SPImage alloc] initWithTexture:mTexture];
        egg.x = [SPUtils randomIntBetweenMin:border andMax:GAME_WIDTH  - border];
        egg.y = [SPUtils randomIntBetweenMin:border andMax:GAME_HEIGHT - border];
        [mContainer addChild:egg];
    }
}

- (void)dealloc
{
    [self removeEventListenersAtObject:self forType:SP_EVENT_TYPE_ENTER_FRAME];
    [mStartButton removeEventListenersAtObject:self forType:SP_EVENT_TYPE_TRIGGERED];
}

@end
