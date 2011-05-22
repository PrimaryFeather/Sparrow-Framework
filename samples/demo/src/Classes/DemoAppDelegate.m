//
//  DemoAppDelegate.m
//  Demo
//
//  Created by Daniel Sperl on 25.07.09.
//  Copyright 2011 Gamua. All rights reserved.
//

#import "DemoAppDelegate.h"
#import "Game.h"
#import "Sparrow.h"

#import "SPNSExtensions.h"

// --- c functions ---

void onUncaughtException(NSException *exception) 
{
	NSLog(@"uncaught exception: %@", exception.description);
}

// ---

@implementation DemoAppDelegate

@synthesize window;
@synthesize sparrowView;

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{    
    SP_CREATE_POOL(pool);    
    
    NSSetUncaughtExceptionHandler(&onUncaughtException);     
    
    [SPAudioEngine start];
    [SPStage setSupportHighResolutions:YES]; // use the provided hd textures on suitable hardware
    
    if ([[UIDevice currentDevice].model rangeOfString:@"iPad"].location == 0)
        [SPStage setContentScaleFactor:2.0f];

    Game *game = [[Game alloc] init];
    sparrowView.stage = game;
    sparrowView.multipleTouchEnabled = YES;
    sparrowView.frameRate = 30;    
    
    [sparrowView start];     
    [window makeKeyAndVisible];
    [game release];
    
    SP_RELEASE_POOL(pool);
}

- (void)applicationWillResignActive:(UIApplication *)application 
{    
    [sparrowView stop];
}

- (void)applicationDidBecomeActive:(UIApplication *)application 
{
	[sparrowView start];
}

- (void)dealloc 
{
    [SPAudioEngine stop];
    [window release];
    [super dealloc];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    [SPPoint purgePool];
    [SPRectangle purgePool];
    [SPMatrix purgePool];    
}

@end
