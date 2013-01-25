//
//  AppScaffoldAppDelegate.m
//  AppScaffold
//

#import "AppDelegate.h"
#import "Game.h" 

@implementation AppDelegate
{
    UIWindow *mWindow;
    SPView *mSparrowView;
}

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
    @autoreleasepool
    {
        [SPStage setSupportHighResolutions:YES];
        [SPAudioEngine start];
        
        Game *game = [[Game alloc] init];        
        mSparrowView.stage = game;
        mSparrowView.frameRate = 30.0f;
        
        [mWindow makeKeyAndVisible];
        [mSparrowView start];
    }
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
}

@end
