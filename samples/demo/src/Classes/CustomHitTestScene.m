//
//  CustomHitTestScene.m
//  Demo
//
//  Created by Daniel Sperl on 22.08.09.
//  Copyright 2011 Gamua. All rights reserved.
//

#import "CustomHitTestScene.h"
#import "RoundButton.h"

@interface CustomHitTestScene ()

- (void)setupScene;

@end



@implementation CustomHitTestScene

- (id)init
{
    if ((self = [super init]))
    {
        [self setupScene];        
    }
    return self;
}

- (void)setupScene
{
    NSString *description = @"Pushing the button only works when the touch occurs within a circle." 
                            @"This can be accomplished by overriding the method 'hitTestPoint:'.";
    
    SPTextField *infoText = [SPTextField textFieldWithWidth:300 height:100 
                                                       text:description fontName:@"Verdana" 
                                                   fontSize:13 color:0x0];    
    infoText.x = infoText.y = 10;
    infoText.vAlign = SPVAlignTop;
    [self addChild:infoText];
        
    // 'RoundButton' is a helper class of the Demo, not a part of Sparrow!
    // have a look at its code to understand this sample.
    
    SPTexture *roundSparrow = [SPTexture textureWithContentsOfFile:@"sparrow_round.png"];
    
    RoundButton *button = [[RoundButton alloc] initWithUpState:roundSparrow];
    button.x = CENTER_X - (int)button.width / 2;
    button.y = CENTER_Y - (int)button.height / 2;
    
    [self addChild:button];
}
    
@end
