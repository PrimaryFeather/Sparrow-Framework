//
//  ViewController.m
//  ViewControllerTest
//

#import "ViewController.h"
#import "Game.h"

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
    
    // Customize your Sparrow settings here
    
    [SPStage setSupportHighResolutions:YES]; // loads '@2x' textures automatically
    [SPAudioEngine start];                   // starts up the sound engine
    
    [Media initAtlas];      // loads your texture atlas -> see Media.h/Media.m
    [Media initSound];      // loads all your sounds    -> see Media.h/Media.m
    
    Game *game = [[Game alloc] init]; // this will start your game logic
    
    SPView *sparrowView = self.sparrowView;
    sparrowView.stage = game;
    sparrowView.multipleTouchEnabled = NO;
    sparrowView.frameRate = 30.0f;
    
    [game release];
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
