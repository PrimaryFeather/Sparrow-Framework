//
//  AppDelegate.m
//  AppScaffold
//

#import "AppDelegate.h"
#import "ViewController.h"

@implementation AppDelegate

- (id)init
{
    if ((self = [super init]))
    {
        mWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }
    return self;
}

- (void)dealloc 
{
    [mViewController release];
    [mWindow release];    
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{
    mViewController = [[ViewController alloc] init];
    mWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    if ([mWindow respondsToSelector:@selector(setRootViewController:)])
        [mWindow setRootViewController:mViewController];
    else
        [mWindow addSubview:mViewController.view];

    [mWindow makeKeyAndVisible];
    
    return YES;
}

@end
