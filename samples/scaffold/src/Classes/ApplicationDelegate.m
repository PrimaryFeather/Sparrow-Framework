//
//  AppScaffoldAppDelegate.m
//  AppScaffold
//
//  Created by Daniel Sperl on 14.01.10.
//  Copyright Incognitek 2010. All rights reserved.
//

#import "ApplicationDelegate.h"
#import "Game.h" 

@implementation ApplicationDelegate

- (id)init
{
    if (self = [super init])
    {
        mWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        mSparrowView = [[SPView alloc] initWithFrame:mWindow.bounds]; 
        [mWindow addSubview:mSparrowView];
    }
    return self;
}

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{    
    SP_CREATE_POOL(pool);    
    
    [SPStage setSupportHighResolutions:YES];
    [SPAudioEngine start];
    
    Game *game = [[Game alloc] init];        
    mSparrowView.stage = game;
    [game release];
    
    [mWindow makeKeyAndVisible];
    [mSparrowView start];
    
    SP_RELEASE_POOL(pool);
}

- (void)applicationWillResignActive:(UIApplication *)application 
{    
    [mSparrowView stop];
}

- (void)applicationDidBecomeActive:(UIApplication *)application 
{
	[mSparrowView start];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    [SPPoint purgePool];
    [SPRectangle purgePool];
    [SPMatrix purgePool];    
}

- (void)dealloc 
{
    [SPAudioEngine stop];
    [mSparrowView release];
    [mWindow release];    
    [super dealloc];
}

@end
