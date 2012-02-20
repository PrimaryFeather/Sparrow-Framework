//
//  AppScaffoldAppDelegate.m
//  AppScaffold
//

#import "AppDelegate.h"
#import "Game.h" 

@implementation AppDelegate

- (id)init
{
    if ((self = [super init]))
    {
        mWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        mSparrowView = [[SPView alloc] initWithFrame:mWindow.bounds]; 
        [mWindow addSubview:mSparrowView];
    }
    return self;
}

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{   
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    [SPStage setSupportHighResolutions:YES];
    [SPAudioEngine start];
    
    Game *game = [[Game alloc] init];        
    mSparrowView.stage = game;
    mSparrowView.frameRate = 30.0f;
    [game release];
    
    [mWindow makeKeyAndVisible];
    [mSparrowView start];
    
    [pool release];
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
