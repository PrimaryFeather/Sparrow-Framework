//
//  TextureScene.m
//  Demo
//
//  Created by Daniel Sperl on 26.07.09.
//  Copyright 2011 Gamua. All rights reserved.
//

#import "TextureScene.h"

@implementation TextureScene

- (id)init
{
    if ((self = [super init]))
    {
        // texture atlas
        //
        // create a texture atlas e.g. with the 'atlas_generator' that's part of Sparrow, e.g.:
        // ./generate_atlas.rb input/*.png atlas.xml
        
        SPTextureAtlas *atlas = [SPTextureAtlas atlasWithContentsOfFile:@"atlas.xml"];
        NSLog(@"found %d textures.", atlas.count);
        
        SPImage *image1 = [SPImage imageWithTexture:[atlas textureByName:@"walk_00"]];
        image1.x = 30;
        image1.y = 20;
        [self addChild:image1];
        
        SPImage *image2 = [SPImage imageWithTexture:[atlas textureByName:@"walk_01"]];
        image2.x = 90;
        image2.y = 50;
        [self addChild:image2];
        
        SPImage *image3 = [SPImage imageWithTexture:[atlas textureByName:@"walk_03"]];
        image3.x = 150;
        image3.y = 80;
        [self addChild:image3];        
        
        SPImage *image4 = [SPImage imageWithTexture:[atlas textureByName:@"walk_05"]];
        image4.x = 210;
        image4.y = 110;
        [self addChild:image4];        
        
        SPTextField *atlasText = [SPTextField textFieldWithWidth:128 height:40 
          text:@"Load textures from an atlas!" fontName:@"Helvetica-Bold" fontSize:14 color:SP_BLACK];
        atlasText.x = 140;
        atlasText.y = 30;
        atlasText.hAlign = SPHAlignRight;
        [self addChild:atlasText];

        // pvrtc texture
        //
        // create compressed PVR textures with the 'texturetool' (part of the iOS SDK), e.g.:
        // texturetool -m -e PVRTC -f PVR -p preview.png -o texture.pvr texture.png
        
        SPImage *logoPvrtc = [SPImage imageWithContentsOfFile:@"logo_rect_tc.pvr"];
        logoPvrtc.x = 172;
        logoPvrtc.y = 300;
        [self addChild:logoPvrtc];
        
        // pvr texture, gzip-compressed
        // 
        // compress a PVR texture with gzip to save space, e.g.:
        // gzip texture.pvr (-> creates texture.pvr.gz)
        
        SPImage *logoPvrGz = [SPImage imageWithContentsOfFile:@"logo_rect.pvr.gz"];
        logoPvrGz.x = 96;
        logoPvrGz.y = 260;
        [self addChild:logoPvrGz];
        
        // pvr texture
        //
        // create uncompressed PVR textures with the PVRTexTool, which can be downloaded here:
        // http://www.imgtec.com/powervr/insider/powervr-pvrtextool.asp
        
        SPImage *logoPvr = [SPImage imageWithContentsOfFile:@"logo_rect.pvr"];
        logoPvr.x = 20; 
        logoPvr.y = 220;
        [self addChild:logoPvr];
        
    }
    return self;    
}

@end
