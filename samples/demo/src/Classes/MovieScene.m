//
//  MovieScene.m
//  Demo
//
//  Created by Daniel Sperl on 14.05.10.
//  Copyright 2011 Gamua. All rights reserved.
//

#import "MovieScene.h"

@implementation MovieScene

- (id)init
{
    if ((self = [super init])) 
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
        NSArray *frames = [atlas texturesStartingWith:@"walk_"];
        mMovie = [[SPMovieClip alloc] initWithFrames:frames fps:12];
        
        // add sounds
        SPSound *stepSound = [[SPSound alloc] initWithContentsOfFile:@"step.caf"];        
        [mMovie setSound:[stepSound createChannel] atIndex:1];
        [mMovie setSound:[stepSound createChannel] atIndex:7];
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
