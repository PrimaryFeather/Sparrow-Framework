//
//  TweenScene.m
//  Demo
//
//  Created by Daniel Sperl on 23.08.09.
//  Copyright 2009 Incognitek. All rights reserved.
//

#import "AnimationScene.h"

@interface AnimationScene ()

- (void)setupScene;
- (void)resetSaturn;

@end

@implementation AnimationScene

- (id)init
{
    if (self = [super init])
    {
        [self setupScene];        
    }
    return self;
}

- (void)setupScene
{    
    SPTextureAtlas *atlas = [SPTextureAtlas atlasWithContentsOfFile:@"atlas.xml"];   
    
    // we create a button that is used to start the tween.
    mStartButton = [[SPButton alloc] initWithUpState:[atlas textureByName:@"button_wide"] 
                                           text:@"Start animation"];
    [mStartButton addEventListener:@selector(onStartButtonPressed:) atObject:self
                           forType:SP_EVENT_TYPE_TRIGGERED];
    mStartButton.x = 80;
    mStartButton.y = 20;
    [self addChild:mStartButton];
    
    // the saturn image will be tweened.
    mSaturn = [[SPImage alloc] initWithTexture:[atlas textureByName:@"saturn"]];
    [self resetSaturn];
    [self addChild:mSaturn];
}

- (void)resetSaturn
{
    mSaturn.x = 10;
    mSaturn.y = 60;
    mSaturn.scaleX = mSaturn.scaleY = 1.0f;
    mSaturn.rotationZ = 0.0f;
}

- (void)onStartButtonPressed:(SPEvent*)event
{
    mStartButton.isEnabled = NO;
    [self resetSaturn];
    
    // to animate any numeric property of an arbitrary object (not just display objects!), you
    // can create a 'Tween'. One tween object animates one target for a certain time, with
    // a certain transition function.    
    SPTween *tween = [SPTween tweenWithTarget:mSaturn time:5.0f transition:SP_TRANSITION_EASE_IN];

    // you can animate any property as long as it's numeric (float, double, int). 
    // it is animated from it's current value to a target value.
    [tween animateProperty:@"x" targetValue:310];
    [tween animateProperty:@"y" targetValue:330];
    [tween animateProperty:@"scaleX" targetValue:0.5];
    [tween animateProperty:@"scaleY" targetValue:0.5];
    [tween animateProperty:@"rotationZ" targetValue:PI_HALF];
    [tween addEventListener:@selector(onTweenComplete:) atObject:self 
                    forType:SP_EVENT_TYPE_TWEEN_COMPLETED];

    // the tween alone is useless -- once in every frame, it has to be advanced, so that the 
    // animation occurs. This is done by the 'Juggler'. It receives the tween and will use it to 
    // animate the object. 
    // There is a default juggler at the stage, but you can create your own jugglers, as well.
    // That way, you can group animations into logical parts.
    [self.stage.juggler addObject:tween];
}

- (void)onTweenComplete:(SPEvent*)event
{    
    mStartButton.isEnabled = YES;
    [(SPTween*)event.target removeEventListenersAtObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
}

- (void)dealloc
{
    [mStartButton removeEventListenersAtObject:self forType:SP_EVENT_TYPE_TRIGGERED];
    [mStartButton release];
    [mSaturn release];
    [super dealloc];
}

@end
