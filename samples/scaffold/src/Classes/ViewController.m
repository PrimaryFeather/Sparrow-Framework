//
//  ViewController.m
//  ViewControllerTest
//

#import <UIKit/UIDevice.h>

#import "ViewController.h"
#import "GameController.h"

@implementation ViewController

- (id)init
{
    if ((self = [super init]))
    {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        
        [nc addObserver:self selector:@selector(onApplicationDidBecomeActive:) 
                   name:UIApplicationDidBecomeActiveNotification object:nil];
        [nc addObserver:self selector:@selector(onApplicationWillResignActive:) 
                   name:UIApplicationWillResignActiveNotification object:nil];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [SPPoint purgePool];
    [SPRectangle purgePool];
    [SPMatrix purgePool];   
    
    [super didReceiveMemoryWarning];
}

#pragma mark - view lifecycle

- (void)loadView
{
    self.view = [[[SPView alloc] initWithFrame:[UIScreen mainScreen].bounds] autorelease];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Customize your Sparrow settings below
    // ---------------------------------------------------------------------------------------------
    
    // 'supportHighResolutions' enables retina display support. It will cause '@2x' textures to be 
    // loaded automatically.
    // 
    // 'doubleOnPad' allows you to handle the iPad as if it were an iPhone with a retina display
    // and a resolution of '384x512' points (half of '768x1024'). It will load '@2x' textures on 
    // iPad 1 & 2. If the iPad has a retina screen, it will load '@4x' textures instead.
    
    [SPStage setSupportHighResolutions:YES doubleOnPad:YES];
    [SPAudioEngine start];  // starts up the sound engine
    
    [Media initAtlas];      // loads your texture atlas -> see Media.h/Media.m
    [Media initSound];      // loads all your sounds    -> see Media.h/Media.m
    
    // your game will have a different size depending on where it's running!
    BOOL isPad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
    int gameWidth  = isPad ? 384 : 320;
    int gameHeight = isPad ? 512 : 480;
    
    // this will start your game logic
    GameController *controller = [[GameController alloc] initWithWidth:gameWidth height:gameHeight];
    
    SPView *sparrowView = self.sparrowView;
    sparrowView.stage = controller;
    sparrowView.multipleTouchEnabled = NO; // enable multitouch here if you need it.
    sparrowView.frameRate = 30.0f;         // possible fps: 60, 30, 20, 15, 12, 10, etc.
    
    [controller release];
    
    // ---------------------------------------------------------------------------------------------
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
    
    // Return YES for supported orientations
    // return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - notifications

- (void)onApplicationDidBecomeActive:(NSNotification *)notification
{
    [self.sparrowView start];
}

- (void)onApplicationWillResignActive:(NSNotification *)notification
{
    [self.sparrowView stop];
}

#pragma mark - properties

- (SPView *)sparrowView
{
    return (SPView *)self.view;
}

@end
