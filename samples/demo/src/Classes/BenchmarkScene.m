//
//  BenchmarkScene.m
//  Demo
//
//  Created by Daniel Sperl on 18.09.09.
//  Copyright 2009 Incognitek. All rights reserved.
//

#import "BenchmarkScene.h"
#import <QuartzCore/QuartzCore.h> // for CACurrentMediaTime()

@interface BenchmarkScene ()

- (SPSprite *)createTestSprite;
- (void)onBenchmarkComplete;

@end

#define DURATION 15

@implementation BenchmarkScene

- (id)init
{
    if (self = [super init])
    {
        mAtlas = [[SPTextureAtlas alloc] initWithContentsOfFile:@"atlas.xml"];   
        
        // we create a button that is used to start the benchmark.
        mStartButton = [[SPButton alloc] initWithUpState:[mAtlas textureByName:@"button_wide"] 
                                                    text:@"Start benchmark"];
        [mStartButton addEventListener:@selector(onStartButtonPressed:) atObject:self
                               forType:SP_EVENT_TYPE_TRIGGERED];
        mStartButton.x = 80;
        mStartButton.y = 20;
        [self addChild:mStartButton];
        [mStartButton release];
        
        mJuggler = [[SPJuggler alloc] init];
        [self addEventListener:@selector(onEnterFrame:) atObject:self
                       forType:SP_EVENT_TYPE_ENTER_FRAME];
    }
    return self;    
}

- (void)onEnterFrame:(SPEnterFrameEvent *)event
{
    [mJuggler advanceTime:event.passedTime];
    ++mFrameCount;
}

- (void)onStartButtonPressed:(SPEvent*)event
{
    NSLog(@"starting benchmark");
    
    mStartButton.isEnabled = NO;
    [mResultText removeFromParent];
    mResultText = nil;
    
    mFrameCount = 0;
    mStartMoment = CACurrentMediaTime();
    
    int numX = 12;
    int numY = 16;
    
    int diffX = 320 / numX;
    int diffY = 480 / numY;
           
    [mJuggler removeAllObjects];
    [mContainer removeFromParent];
    mContainer = [[SPSprite alloc] init];
    mContainer.isTouchable = NO;
    
    mContainer.x = (320.0f / diffX) / 2;
    mContainer.y = (480.0f / diffY) / 2;
    
    for (int x=0; x<numX; ++x)
    {
        for (int y=0; y<numY; ++y)
        {
            SPSprite *testSprite = [self createTestSprite];
            testSprite.x = x * diffX;
            testSprite.y = y * diffY;
            
            float rotation = SP_D2R((x*numY+y) * (360 / (numX * numY)));
            testSprite.rotationZ = rotation;
            
            [mContainer addChild:testSprite];

            SPTween *tween = [[SPTween alloc] initWithTarget:testSprite time:DURATION];
            [tween animateProperty:@"rotationZ" targetValue:SP_D2R(rotation + 360 * 2)];
            //[tween animateProperty:@"y" targetValue:testSprite.y + 50];
            [mJuggler addObject:tween];
            [tween release];

        }
    }
    
    [self addChild:mContainer atIndex:0];
    [mContainer release];
    
    [[mJuggler delayInvocationAtTarget:self byTime:DURATION] onBenchmarkComplete];            
    
}

- (void)onBenchmarkComplete
{
    float fps = (float)mFrameCount / DURATION;
    
    NSLog(@"benchmark complete!");
    NSLog(@"number of frames: %d", mFrameCount);
    NSLog(@"fps: %.2f", fps);
    NSLog(@"real duration: %f", CACurrentMediaTime() - mStartMoment);
    
    [mContainer removeFromParent];
    mContainer = nil;
    mStartButton.isEnabled = YES;
    
    NSString *resultString = [NSString stringWithFormat:@"Result:\n%.2f fps", fps]; 
    
    mResultText = [[SPTextField alloc] initWithWidth:250 height:200 text:resultString];
    mResultText.fontSize = 30;
    mResultText.fontColor = 0xffffff;
    mResultText.x = (320 - mResultText.width) / 2;
    mResultText.y = (480 - mResultText.height) / 2;
    
    [self addChild:mResultText];
}

- (SPSprite *)createTestSprite
{
    SPSprite *sprite = [SPSprite sprite];    
    
    SPImage *moon = [[SPImage alloc] initWithTexture:[mAtlas textureByName:@"moon"]];    
    //SPQuad *moon = [[SPQuad alloc] initWithWidth:130.0f height:130.0f];
    //moon.color = 0xff0000;
    moon.scaleX = moon.scaleY = 0.3f;
    moon.x = -moon.width/2 + 25;  
    moon.y = -moon.height / 2;
    
    [sprite addChild:moon];
    [moon release];
    return sprite;
}

- (void)dealloc
{
    [self removeEventListenersAtObject:self forType:SP_EVENT_TYPE_ENTER_FRAME];
    [mStartButton removeEventListenersAtObject:self forType:SP_EVENT_TYPE_TRIGGERED];

    [mJuggler release];
    [mAtlas release];
    [super dealloc];
}

@end
