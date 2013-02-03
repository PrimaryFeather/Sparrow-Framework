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
{
    UIWindow *mWindow;
    SPViewController *mViewController;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{
    NSSetUncaughtExceptionHandler(&onUncaughtException);
    
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    mWindow = [[UIWindow alloc] initWithFrame:screenBounds];
    
    [SPAudioEngine start];
    
    mViewController = [[SPViewController alloc] init];
    mViewController.multitouchEnabled = YES;
    [mViewController startWithRoot:[Game class] supportHighResolutions:YES doubleOnPad:YES];
    
    [mWindow setRootViewController:mViewController];
    [mWindow makeKeyAndVisible];
    
    // What follows is a very simply approach to support the iPad:
    // we just center the stage on the screen!
    //
    // (Beware: to support autorotation, this would need a little more work.)
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        mViewController.view.frame = CGRectMake(64, 32, 640, 960);
        mViewController.stage.width = 320;
        mViewController.stage.height = 480;
    }
    
    return YES;
}

@end
