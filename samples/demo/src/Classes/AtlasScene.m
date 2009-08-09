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
        
        SPImage *jupiter = [SPImage imageWithTexture:[atlas textureByName:@"jupiter"]];
        jupiter.scaleX = jupiter.scaleY = 1.4f;
        jupiter.x = -20;
        jupiter.y = -20;
        [self addChild:jupiter];
        
        SPImage *saturn = [SPImage imageWithTexture:[atlas textureByName:@"saturn"]];
        saturn.x = 60;
        saturn.y = 130;
        [self addChild:saturn];
        
        SPImage *astronaut = [SPImage imageWithTexture:[atlas textureByName:@"astronaut"]];
        astronaut.x = 190;
        astronaut.y = 200;
        astronaut.rotationZ = PI/4.0f;
        [self addChild:astronaut];
    }
    return self;    
}

@end
