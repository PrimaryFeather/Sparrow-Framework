//
//  SPViewController.m
//  Sparrow
//
//  Created by Daniel Sperl on 26.01.13.
//  Copyright 2013 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPViewController.h"
#import "SPTouchProcessor.h"
#import "SPRenderSupport.h"
#import "SparrowClass_Internal.h"
#import "SPTouch_Internal.h"
#import "SPEnterFrameEvent.h"
#import "SPResizeEvent.h"

// --- private interaface --------------------------------------------------------------------------

@interface SPViewController()

@property (nonatomic, readonly) GLKView *glkView;

@end

// --- class implementation ------------------------------------------------------------------------

@implementation SPViewController
{
    EAGLContext *mContext;
    Class mRootClass;
    SPStage *mStage;
    SPDisplayObject *mRoot;
    SPJuggler *mJuggler;
    SPTouchProcessor *mTouchProcessor;
    SPRenderSupport *mSupport;
    
    double mLastTouchTimestamp;
    float mContentScaleFactor;
    float mViewScaleFactor;
    BOOL mSupportHighResolutions;
    BOOL mDoubleResolutionOnPad;
}

@synthesize stage = mStage;
@synthesize juggler = mJuggler;
@synthesize root = mRoot;
@synthesize context = mContext;
@synthesize supportHighResolutions = mSupportHighResolutions;
@synthesize doubleResolutionOnPad = mDoubleResolutionOnPad;
@synthesize contentScaleFactor = mContentScaleFactor;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
    {
        mContentScaleFactor = 1.0f;
        mStage = [[SPStage alloc] init];
        mJuggler = [[SPJuggler alloc] init];
        mTouchProcessor = [[SPTouchProcessor alloc] initWithRoot:mStage];
        mContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        mSupport = [[SPRenderSupport alloc] init];
        
        if (!mContext || ![EAGLContext setCurrentContext:mContext])
            NSLog(@"Could not create render context");
        
        [Sparrow setCurrentController:self];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self glkView].context = mContext;
}

- (void)viewDidUnload
{
    mContext = nil;
    [EAGLContext setCurrentContext:nil];
}

- (void)didReceiveMemoryWarning
{
    [SPPoint purgePool];
    [SPRectangle purgePool];
    [SPMatrix purgePool];
    
    [super didReceiveMemoryWarning];
}

- (void)startWithRoot:(Class)rootClass
{
    [self startWithRoot:rootClass supportHighResolutions:YES];
}

- (void)startWithRoot:(Class)rootClass supportHighResolutions:(BOOL)hd
{
    [self startWithRoot:rootClass supportHighResolutions:hd doubleOnPad:NO];
}

- (void)startWithRoot:(Class)rootClass supportHighResolutions:(BOOL)hd doubleOnPad:(BOOL)pad
{
    if (mRootClass)
        [NSException raise:SP_EXC_INVALID_OPERATION
                    format:@"Sparrow has already been started"];

    BOOL isPad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
    
    mRootClass = rootClass;
    mSupportHighResolutions = hd;
    mDoubleResolutionOnPad = pad;
    mViewScaleFactor = mSupportHighResolutions ? [[UIScreen mainScreen] scale] : 1.0f;
    mContentScaleFactor = (mDoubleResolutionOnPad && isPad) ? mViewScaleFactor * 2.0f : mViewScaleFactor;
}

- (void)createRoot
{
    if (!mRoot)
    {
        mRoot = [[mRootClass alloc] init];
        [mStage addChild:mRoot atIndex:0];
    
        if ([mRoot isKindOfClass:[SPStage class]])
            [NSException raise:SP_EXC_INVALID_OPERATION
                        format:@"Root extends 'SPStage' but is expected to extend 'SPSprite' "
                               @"instead (different to Sparrow 1.x)"];
    }
}

- (void)updateStageSize
{
    CGSize viewSize = self.view.bounds.size;
    mStage.width  = viewSize.width  * mViewScaleFactor / mContentScaleFactor;
    mStage.height = viewSize.height * mViewScaleFactor / mContentScaleFactor;
}

#pragma mark - GLKViewDelegate

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    @autoreleasepool
    {
        if (!mRoot)
        {
            // ideally, we'd do this in 'viewDidLoad', but when iOS starts up in landscape mode,
            // the view width and height are swapped. In this method, however, they are correct.
            
            [self updateStageSize];
            [self createRoot];
        }
        
        [Sparrow setCurrentController:self];
        [EAGLContext setCurrentContext:mContext];
        
        glDisable(GL_CULL_FACE);
        glDisable(GL_DEPTH_TEST);
        glEnable(GL_BLEND);
        
        [mSupport nextFrame];
        [mStage render:mSupport];
        [mSupport finishQuadBatch];
        
        #if DEBUG
        [SPRenderSupport checkForOpenGLError];
        #endif
    }
}

- (void)update
{
    @autoreleasepool
    {
        double passedTime = self.timeSinceLastUpdate;
        
        [Sparrow setCurrentController:self];
        [mJuggler advanceTime:passedTime];
        
        SPEnterFrameEvent *enterFrameEvent =
        [[SPEnterFrameEvent alloc] initWithType:SP_EVENT_TYPE_ENTER_FRAME passedTime:passedTime];
        [mStage broadcastEvent:enterFrameEvent];
    }
}

#pragma mark - Touch Processing

- (void)setMultitouchEnabled:(BOOL)multitouchEnabled
{
    self.view.multipleTouchEnabled = multitouchEnabled;
}

- (BOOL)multitouchEnabled
{
    return self.view.multipleTouchEnabled;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self processTouchEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self processTouchEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self processTouchEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    mLastTouchTimestamp -= 0.0001f; // cancelled touch events have an old timestamp -> workaround
    [self processTouchEvent:event];
}

- (void)processTouchEvent:(UIEvent*)event
{
    if (!self.paused && mLastTouchTimestamp != event.timestamp)
    {
        @autoreleasepool
        {
            CGSize viewSize = self.view.bounds.size;
            float xConversion = mStage.width / viewSize.width;
            float yConversion = mStage.height / viewSize.height;
            
            // convert to SPTouches and forward to stage
            NSMutableSet *touches = [NSMutableSet set];
            double now = CACurrentMediaTime();
            for (UITouch *uiTouch in [event touchesForView:self.view])
            {
                CGPoint location = [uiTouch locationInView:self.view];
                CGPoint previousLocation = [uiTouch previousLocationInView:self.view];
                SPTouch *touch = [SPTouch touch];
                touch.timestamp = now; // timestamp of uiTouch not compatible to Sparrow timestamp
                touch.globalX = location.x * xConversion;
                touch.globalY = location.y * yConversion;
                touch.previousGlobalX = previousLocation.x * xConversion;
                touch.previousGlobalY = previousLocation.y * yConversion;
                touch.tapCount = uiTouch.tapCount;
                touch.phase = (SPTouchPhase)uiTouch.phase;
                [touches addObject:touch];
            }
            [mTouchProcessor processTouches:touches];
            mLastTouchTimestamp = event.timestamp;
        }
    }
}

#pragma mark - Auto Rotation

// The following methods implement what I would expect to be the default behaviour of iOS:
// The orientations that you activated in the application plist file are automatically rotated to.

- (NSUInteger)supportedInterfaceOrientations
{
    NSArray *supportedOrientations =
    [[NSBundle mainBundle] infoDictionary][@"UISupportedInterfaceOrientations"];
    
    NSUInteger returnOrientations = 0;
    if ([supportedOrientations containsObject:@"UIInterfaceOrientationPortrait"])
        returnOrientations |= UIInterfaceOrientationMaskPortrait;
    if ([supportedOrientations containsObject:@"UIInterfaceOrientationLandscapeLeft"])
        returnOrientations |= UIInterfaceOrientationMaskLandscapeLeft;
    if ([supportedOrientations containsObject:@"UIInterfaceOrientationPortraitUpsideDown"])
        returnOrientations |= UIInterfaceOrientationMaskPortraitUpsideDown;
    if ([supportedOrientations containsObject:@"UIInterfaceOrientationLandscapeRight"])
        returnOrientations |= UIInterfaceOrientationMaskLandscapeRight;
    
    return returnOrientations;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    NSArray *supportedOrientations =
    [[NSBundle mainBundle] infoDictionary][@"UISupportedInterfaceOrientations"];
    
    return ((interfaceOrientation == UIInterfaceOrientationPortrait &&
             [supportedOrientations containsObject:@"UIInterfaceOrientationPortrait"]) ||
            (interfaceOrientation == UIInterfaceOrientationLandscapeLeft &&
             [supportedOrientations containsObject:@"UIInterfaceOrientationLandscapeLeft"]) ||
            (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown &&
             [supportedOrientations containsObject:@"UIInterfaceOrientationPortraitUpsideDown"]) ||
            (interfaceOrientation == UIInterfaceOrientationLandscapeRight &&
             [supportedOrientations containsObject:@"UIInterfaceOrientationLandscapeRight"]));
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
                                         duration:(NSTimeInterval)duration
{
    // inform all display objects about the new game size
    BOOL isPortrait = UIInterfaceOrientationIsPortrait(interfaceOrientation);
    
    float newWidth  = isPortrait ? MIN(mStage.width, mStage.height) :
                                   MAX(mStage.width, mStage.height);
    float newHeight = isPortrait ? MAX(mStage.width, mStage.height) :
                                   MIN(mStage.width, mStage.height);
    
    if (newWidth != mStage.width)
    {
        mStage.width  = newWidth;
        mStage.height = newHeight;
        
        SPEvent *resizeEvent = [[SPResizeEvent alloc] initWithType:SP_EVENT_TYPE_RESIZE
                               width:newWidth height:newHeight animationTime:duration];
        [mStage broadcastEvent:resizeEvent];
    }
}

#pragma mark - Properties

- (GLKView *)glkView
{
    return (GLKView *)self.view;
}

@end
