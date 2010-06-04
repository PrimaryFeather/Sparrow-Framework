//
//  MovieScene.m
//  Demo
//
//  Created by Daniel Sperl on 14.05.10.
//  Copyright 2010 Incognitek. All rights reserved.
//

#import "MovieScene.h"

@implementation MovieScene

- (id)init
{
    if (self = [super init]) 
    {
        NSString *description = @"[Animation provided by angryanimator.com]";        
        SPTextField *infoText = [SPTextField textFieldWithWidth:300 height:30 
                                                           text:description fontName:@"Verdana" 
                                                       fontSize:13 color:0x0];    
        infoText.x = infoText.y = 10;
        infoText.vAlign = SPVAlignTop;
        infoText.hAlign = SPHAlignCenter;
        [self addChild:infoText];        
        
        // all our animation textures are in the atlas
        SPTextureAtlas *atlas = [SPTextureAtlas atlasWithContentsOfFile:@"atlas.xml"];
        
        // add frames to movie
        mMovie = [[SPMovieClip alloc] initWithFrame:[atlas textureByName:@"walk_0"] fps:10];
        [mMovie addFrame:[atlas textureByName:@"walk_1"]];
        [mMovie addFrame:[atlas textureByName:@"walk_2"]];
        [mMovie addFrame:[atlas textureByName:@"walk_3"]];
        [mMovie addFrame:[atlas textureByName:@"walk_4"]];
        [mMovie addFrame:[atlas textureByName:@"walk_5"]];
        [mMovie addFrame:[atlas textureByName:@"walk_6"]];
        [mMovie addFrame:[atlas textureByName:@"walk_7"]];          
        
        // add sounds
        SPSound *stepSound = [[SPSound alloc] initWithContentsOfFile:@"step.caf"];        
        [mMovie setSound:[stepSound createChannel] atIndex:2];
        [mMovie setSound:[stepSound createChannel] atIndex:6];
        [stepSound release];
       
        // move the clip to the center and add it to the stage
        mMovie.x = 160 - (int)mMovie.width / 2;
        mMovie.y = 240 - (int)mMovie.height / 2; 
        [self addChild:mMovie];                
        [mMovie release];        

        // like any animation, the movie needs to be added to the juggler!
        // this is the recommended way to do that.
        [self addEventListener:@selector(onAddedToStage:) atObject:self forType:SP_EVENT_TYPE_ADDED_TO_STAGE];
        [self addEventListener:@selector(onRemovedFromStage:) atObject:self forType:SP_EVENT_TYPE_REMOVED_FROM_STAGE];
    }
    return self;
}

- (void)onAddedToStage:(SPEvent *)event
{
    [self.stage.juggler addObject:mMovie];
}

- (void)onRemovedFromStage:(SPEvent *)event
{
    [self.stage.juggler removeObject:mMovie];
}

@end
