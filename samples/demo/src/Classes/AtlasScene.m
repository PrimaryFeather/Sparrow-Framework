//
//  AtlasScene.m
//  Demo
//
//  Created by Daniel Sperl on 26.07.09.
//  Copyright 2009 Incognitek. All rights reserved.
//

#import "AtlasScene.h"

@implementation AtlasScene

- (id)init
{
    if (self = [super init])
    {        
        SPTextureAtlas *atlas = [SPTextureAtlas atlasWithContentsOfFile:@"atlas.xml"];
        NSLog(@"found %d textures.", atlas.count);
        
        SPImage *image1 = [SPImage imageWithTexture:[atlas textureByName:@"walk_0"]];
        image1.x = 30;
        image1.y = 30;
        [self addChild:image1];
        
        SPImage *image2 = [SPImage imageWithTexture:[atlas textureByName:@"walk_1"]];
        image2.x = 90;
        image2.y = 110;
        [self addChild:image2];
        
        SPImage *image3 = [SPImage imageWithTexture:[atlas textureByName:@"walk_3"]];
        image3.x = 150;
        image3.y = 190;
        [self addChild:image3];        
        
        SPImage *image4 = [SPImage imageWithTexture:[atlas textureByName:@"walk_5"]];
        image4.x = 210;
        image4.y = 270;
        [self addChild:image4];        
    }
    return self;    
}

@end
