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
    int offset = 10;
    
    SPTextField *defaultTF = [SPTextField textFieldWithWidth:300 height:60 
        text:@"TextFields can be created in different flavors."];
    defaultTF.color = 0xffffff;
    defaultTF.x = defaultTF.y = offset;    
    [self addChild:defaultTF];
    
    SPTextField *colorTF = [SPTextField textFieldWithWidth:300 height:60 
        text:@"They can have a border and a color."];
    colorTF.x = offset;
    colorTF.y = defaultTF.y + defaultTF.height + offset;
    colorTF.border = YES;
    colorTF.color = 0xaaaaff;
    [self addChild:colorTF];
    
    SPTextField *leftTF = [SPTextField textFieldWithWidth:145 height:80 
        text:@"Text can be aligned in different ways, e.g. top-left ..."];
    leftTF.x = offset;    
    leftTF.y = colorTF.y + colorTF.height + offset;
    leftTF.hAlign = SPHAlignLeft;
    leftTF.vAlign = SPVAlignTop;
    leftTF.border = YES;
    leftTF.color = 0xffaaaa;
    [self addChild:leftTF];
    
    SPTextField *rightTF = [SPTextField textFieldWithWidth:145 height:80 
        text:@"... or bottom right ..."];
    rightTF.x = 2*offset + leftTF.width;
    rightTF.y = colorTF.y + colorTF.height + offset;
    rightTF.hAlign = SPHAlignRight;
    rightTF.vAlign = SPVAlignBottom;
    rightTF.color = 0xaaffaa;
    rightTF.border = YES;
    [self addChild:rightTF];
    
    SPTextField *fontTF = [SPTextField textFieldWithWidth:300 height:100 
        text:@"... or centered. And of course the type of font and the size are arbitrary."];
    fontTF.x = offset;
    fontTF.y = leftTF.y + leftTF.height + offset;
    fontTF.hAlign = SPHAlignCenter;
    fontTF.vAlign = SPVAlignCenter;
    fontTF.fontSize = 18;
    fontTF.fontName = @"Georgia-Bold";
    fontTF.border = YES;
    fontTF.color = 0xffffff;
    [self addChild:fontTF];
}

@end
