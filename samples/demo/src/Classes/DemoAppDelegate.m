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

@synthesize window = mWindow;
@synthesize sparrowView = mSparrowView;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSSetUncaughtExceptionHandler(&onUncaughtException);     
    
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    mWindow = [[UIWindow alloc] initWithFrame:screenBounds];
    
    [SPAudioEngine start];
    [SPStage setSupportHighResolutions:YES]; // use @2x textures on suitable hardware
    
    mSparrowView = [[SPView alloc] initWithFrame:screenBounds];
    mSparrowView.multipleTouchEnabled = YES;
    mSparrowView.frameRate = 30;
    [mWindow addSubview:mSparrowView];
    
    Game *game = [[Game alloc] init];
    mSparrowView.stage = game;
    
    [mWindow makeKeyAndVisible];
    
    [game release];
    [pool release];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application 
{    
    [mSparrowView stop];
}

- (void)applicationDidBecomeActive:(UIApplication *)application 
{
	[mSparrowView start];
}

- (void)dealloc 
{
    [SPAudioEngine stop];
    [mWindow release];
    [super dealloc];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    [SPPoint purgePool];
    [SPRectangle purgePool];
    [SPMatrix purgePool];    
}

@end
