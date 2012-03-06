//
//  TestScene.m
//  Sparrow
//
//  Created by Daniel Sperl on 30.04.09.
//  Copyright 2011 Gamua. All rights reserved.
//

#import "TouchScene.h"

// --- private interface ---------------------------------------------------------------------------

@interface TouchScene ()

- (void)setupScene;

@end

// --- class implementation ------------------------------------------------------------------------

@implementation TouchScene

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
    NSString *description = @"Touch and drag to move the image, \n"
                            @"pinch with 2 fingers to scale and rotate.";
    
    SPTextField *infoText = [SPTextField textFieldWithWidth:300 height:64 
                                                       text:description fontName:@"Verdana" 
                                                   fontSize:13 color:0x0];    
    infoText.x = infoText.y = 10;
    [self addChild:infoText];
    
    SPImage *sparrow = [SPImage imageWithContentsOfFile:@"sparrow_sheet.png"];
    
    // to find out how to react to touch events have a look at the TouchSheet class! 
    // It's part of the demo.
                             
    TouchSheet *sheet = [[TouchSheet alloc] initWithQuad:sparrow];
    sheet.x = CENTER_X;
    sheet.y = CENTER_Y;    
    
    [self addChild:sheet];
    [sheet release];
}

@end
