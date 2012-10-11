//
//  AppDelegate.m
//  AppScaffold
//

#import "AppDelegate.h"
#import "ViewController.h"

@implementation AppDelegate

- (void)dealloc 
{
    [mViewController release];
    [mWindow release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    mWindow = [[UIWindow alloc] initWithFrame:screenBounds];
    
    // Customize your Sparrow settings below
    // ---------------------------------------------------------------------------------------------
    
    // 'supportHighResolutions' enables retina display support. It will cause '@2x' textures to be 
    // loaded automatically.
    // 
    // 'doubleOnPad' allows you to handle the iPad as if it were an iPhone with a 3.5 inch retina
    // display and a resolution of '384x512' points (half of '768x1024'). It will load '@2x'
    // textures on iPad 1 & 2. If the iPad has a retina screen, it will load '@4x' textures instead.
    
    [SPStage setSupportHighResolutions:YES doubleOnPad:YES];
    
    // Your game will have a different size depending on where it's running!
    // If your game is landscape only set "Initial Interface Orientation" to 
    // a landscape orientation in App-Info.plist.
    
    BOOL isPad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
    int width  = isPad ? 384 : screenBounds.size.width;
    int height = isPad ? 512 : screenBounds.size.height;
    
    SPView *sparrowView = [[SPView alloc] initWithFrame:screenBounds];
    sparrowView.multipleTouchEnabled = NO; // enable multitouch here if you need it.
    sparrowView.frameRate = 30;            // possible fps: 60, 30, 20, 15, 12, 10, etc.
    [mWindow addSubview:sparrowView];
    
    GameController *gameController = [[GameController alloc] initWithWidth:width height:height];
    sparrowView.stage = gameController;
    
    [gameController release];
    [sparrowView release];
    
    // ---------------------------------------------------------------------------------------------
    
    mViewController = [[ViewController alloc] initWithSparrowView:sparrowView];
    
    if ([mWindow respondsToSelector:@selector(setRootViewController:)])
        [mWindow setRootViewController:mViewController];
    else
        [mWindow addSubview:mViewController.view];

    [mWindow makeKeyAndVisible];
    
    return YES;
}

@end
