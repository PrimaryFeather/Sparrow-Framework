//
//  Scene.m
//  Demo
//
//  Created by Sperl Daniel on 06.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Scene.h"

@implementation Scene
{
    SPButton *mBackButton;
}

- (id)init
{
    if ((self = [super init]))
    {
        // create a button with the text "back" and display it at the bottom of the screen.
        SPTexture *buttonTexture = [SPTexture textureWithContentsOfFile:@"button_back.png"];
        
        mBackButton = [[SPButton alloc] initWithUpState:buttonTexture text:@"back"];
        mBackButton.x = CENTER_X - mBackButton.width / 2.0f;
        mBackButton.y = GAME_HEIGHT - mBackButton.height + 1;
        [mBackButton addEventListener:@selector(onBackButtonTriggered:) atObject:self 
                              forType:SP_EVENT_TYPE_TRIGGERED];
        [self addChild:mBackButton];
    }
    return self;
}

- (void)onBackButtonTriggered:(SPEvent *)event
{
    [mBackButton removeEventListenersAtObject:self forType:SP_EVENT_TYPE_TRIGGERED];
    [self dispatchEventWithType:EVENT_TYPE_SCENE_CLOSING bubbles:YES];
}

@end
