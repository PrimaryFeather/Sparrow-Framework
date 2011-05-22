//
//  RenderTextureScene.m
//  Demo
//
//  Created by Daniel Sperl on 05.12.10.
//  Copyright 2011 Gamua. All rights reserved.
//

#import "RenderTextureScene.h"

#define screenH 480

@interface RenderTextureScene ()

- (void)setupScene;

@end

@implementation RenderTextureScene

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
    NSString *description = @"Touch the screen to draw eggs!";
    SPTextField *infoText = [SPTextField textFieldWithWidth:300 height:100 
                                                       text:description fontName:@"Verdana" 
                                                   fontSize:13 color:0x0];    
    infoText.x = infoText.y = 10;
    infoText.vAlign = SPVAlignTop;
    infoText.touchable = NO;
    [self addChild:infoText];
    
    // we load the "brush" image (the sparrow egg) from the texture atlas
    SPTextureAtlas *atlas = [SPTextureAtlas atlasWithContentsOfFile:@"atlas.xml"];     
    mBrush = [[SPImage alloc] initWithTexture:[atlas textureByName:@"egg_opened"]];
    mBrush.scaleX = mBrush.scaleY = 0.5f;
    
    // the render texture is a dyanmic texture. We will draw the egg on that texture on
    // every touch event.
    mRenderTexture = [[SPRenderTexture alloc] initWithWidth:320 height:435];
    
    // the canvas image will display the render texture
    SPImage *canvas = [SPImage imageWithTexture:mRenderTexture];
    
    // we want to draw on touch events
    [canvas addEventListener:@selector(onTouch:) atObject:self forType:SP_EVENT_TYPE_TOUCH];    
    
    [self addChild:canvas];
}

- (void)onTouch:(SPTouchEvent *)event
{    
    NSSet *allTouches = [event touchesWithTarget:self];
    
    for (SPTouch* touch in allTouches)
    {
        // don't draw on 'finger up'
        if (touch.phase == SPTouchPhaseEnded) continue;
        
        // find out location of touch event
        SPPoint *currentLocation = [touch locationInSpace:self];                
        
        // center brush over location
        mBrush.x = currentLocation.x - mBrush.width / 2.0f;
        mBrush.y = currentLocation.y - mBrush.height / 2.0f;
        
        // draw brush to render texture
        [mRenderTexture drawObject:mBrush];        
    } 
}

- (void)dealloc
{
    [mRenderTexture release];
    [mBrush release];
    [super dealloc];
}

@end
