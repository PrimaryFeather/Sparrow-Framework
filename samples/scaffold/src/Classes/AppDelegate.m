//
//  AppDelegate.m
//  AppScaffold
//

#import "AppDelegate.h"
#import "Game.h"

// --- c functions ---

void onUncaughtException(NSException *exception)
{
    NSLog(@"uncaught exception: %@", exception.description);
}

// ---

@implementation AppDelegate
{
    SPViewController *mViewController;
    UIWindow *mWindow;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSSetUncaughtExceptionHandler(&onUncaughtException);
    
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    mWindow = [[UIWindow alloc] initWithFrame:screenBounds];
    
    mViewController = [[SPViewController alloc] init];
    [mViewController startWithRoot:[Game class] supportHighResolutions:YES doubleOnPad:YES];
    
    [mWindow setRootViewController:mViewController];
    [mWindow makeKeyAndVisible];
    
    return YES;
}

@end
