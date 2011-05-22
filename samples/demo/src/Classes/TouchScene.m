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
    NSString *description = [NSString stringWithFormat:@"%@\n%@\n%@",
                             @"- touch and drag to move the images", 
                             @"- pinch with 2 fingers to scale and rotate", 
                             @"- double click brings an image to the front"];
    
    SPTextField *infoText = [SPTextField textFieldWithWidth:300 height:100 
                                                       text:description fontName:@"Verdana" 
                                                   fontSize:13 color:0x0];    
    infoText.x = infoText.y = 10;
    infoText.vAlign = SPVAlignTop;
    infoText.hAlign = SPHAlignLeft;
    [self addChild:infoText];
        
    SPTextureAtlas *atlas = [SPTextureAtlas atlasWithContentsOfFile:@"atlas.xml"];
    SPImage *eggClosed = [SPImage imageWithTexture:[atlas textureByName:@"egg_closed"]];
    SPImage *eggOpened = [SPImage imageWithTexture:[atlas textureByName:@"egg_opened"]];
    
    // to find out how to react to touch events have a look at the TouchSheet class! 
    // It's part of the demo.
                             
    TouchSheet *sheet1 = [[TouchSheet alloc] initWithQuad:eggClosed];    
    sheet1.x = 130;
    sheet1.y = 200;    
    
    TouchSheet *sheet2 = [[TouchSheet alloc] initWithQuad:eggOpened];    
    sheet2.x = 200;
    sheet2.y = 295; 
    
    [self addChild:sheet1];
    [self addChild:sheet2];    
}

@end
