//
//  TextScene.m
//  Demo
//
//  Created by Daniel Sperl on 26.07.09.
//  Copyright 2009 Incognitek. All rights reserved.
//

#import "TextScene.h"

@interface TextScene ()

- (void)setupScene;

@end

@implementation TextScene

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
    SPQuad *background = [SPQuad quadWithWidth:320 height:480];
    background.color = 0xffffff;
    [self addChild:background];
     
    int offset = 10;
    
    SPTextField *defaultTF = [SPTextField textFieldWithWidth:300 height:60 
        text:@"TextFields can be created in different flavors. This is the default one."];
    defaultTF.x = defaultTF.y = offset;    
    defaultTF.background = YES;
    [self addChild:defaultTF];
    
    SPTextField *colorTF = [SPTextField textFieldWithWidth:300 height:60 
        text:@"They can have border and background, and all colors can be configured."];
    colorTF.x = offset;
    colorTF.y = defaultTF.y + defaultTF.height + offset;
    colorTF.border = YES;
    colorTF.borderColor = 0x0;
    colorTF.background = YES;
    colorTF.backgroundColor = 0x00ff00;
    colorTF.fontColor = 0x0000ff;
    [self addChild:colorTF];
    
    SPTextField *leftTF = [SPTextField textFieldWithWidth:145 height:60 
        text:@"Text can be aligned top-left ..."];
    leftTF.x = offset;
    leftTF.y = colorTF.y + colorTF.height + offset;
    leftTF.backgroundColor = 0xffaaaa;
    leftTF.background = YES;
    leftTF.hAlign = SPHAlignLeft;
    leftTF.vAlign = SPVAlignTop;
    [self addChild:leftTF];
    
    SPTextField *rightTF = [SPTextField textFieldWithWidth:145 height:60 
        text:@"... or bottom right ..."];
    rightTF.x = 2*offset + leftTF.width;
    rightTF.y = colorTF.y + colorTF.height + offset;
    rightTF.backgroundColor = 0xaaffaa;
    rightTF.background = YES;
    rightTF.hAlign = SPHAlignRight;
    rightTF.vAlign = SPVAlignBottom;
    [self addChild:rightTF];
    
    SPTextField *fontTF = [SPTextField textFieldWithWidth:300 height:100 
        text:@"... or centered. And of course the type of font and the size are arbitrary."];
    fontTF.x = offset;
    fontTF.y = leftTF.y + leftTF.height + offset;
    fontTF.hAlign = SPHAlignCenter;
    fontTF.vAlign = SPVAlignCenter;
    fontTF.fontSize = 17;
    fontTF.fontName = @"Georgia-Bold";
    fontTF.background = YES;
    fontTF.backgroundColor = 0xbbbbbb;
    [self addChild:fontTF];
}

@end
