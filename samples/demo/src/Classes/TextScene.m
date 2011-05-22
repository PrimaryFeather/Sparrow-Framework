//
//  TextScene.m
//  Demo
//
//  Created by Daniel Sperl on 26.07.09.
//  Copyright 2011 Gamua. All rights reserved.
//

#import "TextScene.h"

@interface TextScene ()

- (void)setupScene;

@end

@implementation TextScene

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
    int offset = 10;    
    
    SPTextField *colorTF = [SPTextField textFieldWithWidth:300 height:60 
        text:@"TextFields can have a border and a color."];
    colorTF.x = colorTF.y = offset;
    colorTF.border = YES;
    colorTF.color = 0x333399;
    [self addChild:colorTF];
    
    SPTextField *leftTF = [SPTextField textFieldWithWidth:145 height:80 
        text:@"Text can be aligned in different ways, e.g. top-left ..."];
    leftTF.x = offset;    
    leftTF.y = colorTF.y + colorTF.height + offset;
    leftTF.hAlign = SPHAlignLeft;
    leftTF.vAlign = SPVAlignTop;
    leftTF.border = YES;
    leftTF.color = 0x993333;
    [self addChild:leftTF];
    
    SPTextField *rightTF = [SPTextField textFieldWithWidth:145 height:80 
        text:@"... or bottom right ..."];
    rightTF.x = 2*offset + leftTF.width;
    rightTF.y = colorTF.y + colorTF.height + offset;
    rightTF.hAlign = SPHAlignRight;
    rightTF.vAlign = SPVAlignBottom;
    rightTF.color = 0x228822;
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
    fontTF.color = 0x0;
    [self addChild:fontTF];
    
    // Bitmap fonts!
    
    // First, you will need to create a bitmap font texture.
    //
    // E.g. with this tool: www.angelcode.com/products/bmfont/ or one that uses the same
    // data format. Export the font data as an XML file, and the texture as a png with white
    // characters on a transparent background (32 bit).
    //
    // Then, you just have to call the following method:    
    // (the returned font name is the one that is defined in the font XML.)
    NSString *bmpFontName = [SPTextField registerBitmapFontFromFile:@"desyrel.fnt"];

    // That's it! If you use this font now, the textField will be rendered with the bitmap font.
    SPTextField *bmpFontTF = [SPTextField textFieldWithWidth:300 height:150 
        text:@"It is very easy to use Bitmap fonts, as well!"];
    bmpFontTF.fontSize = SP_NATIVE_FONT_SIZE; // use the native bitmap font size, no scaling
    bmpFontTF.fontName = bmpFontName;
    bmpFontTF.color = SP_WHITE; // use white if you want to use the texture as it is
    bmpFontTF.hAlign = SPHAlignCenter;
    bmpFontTF.vAlign = SPVAlignCenter;
    bmpFontTF.kerning = YES;
    bmpFontTF.x = offset;
    bmpFontTF.y = fontTF.y + fontTF.height + offset;
    [self addChild:bmpFontTF];
    
    // A tip: you can add the font-texture to your standard texture atlas, and reference it from
    // there. That way, you save texture space, and avoid another texture-switch.
}

- (void)dealloc
{
    // when you are done with it, you should unregister your bitmap font. 
    // (Only if you no longer need it!)
    [SPTextField unregisterBitmapFont:@"Desyrel"];
    [super dealloc];
}

@end
