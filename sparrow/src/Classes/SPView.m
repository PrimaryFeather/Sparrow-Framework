//
//  EAGLView.m
//  Sparrow
//
//  Created by Daniel Sperl on 13.03.09.
//  Copyright 2009 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>

#import "SPStage.h"
#import "SPStage_Internal.h"
#import "SPView.h"
#import "SPMacros.h"
#import "SPTouch.h"
#import "SPTouch_Internal.h"
#import "SPRenderSupport.h"

// --- private interface ---------------------------------------------------------------------------

@interface SPView ()

@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic, retain) id displayLink;

- (void)setup;
- (void)createFramebuffer;
- (void)destroyFramebuffer;

- (void)renderStage;
- (void)processTouchEvent:(UIEvent*)event;

@end

// --- class implementation ------------------------------------------------------------------------

@implementation SPView

#define REFRESH_RATE 60

@synthesize stage = mStage;
@synthesize timer = mTimer;
@synthesize displayLink = mDisplayLink;
@synthesize frameRate = mFrameRate;

- (id)initWithFrame:(CGRect)frame 
{    
    if ([super initWithFrame:frame]) 
    {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder 
{
    if ([super initWithCoder:decoder]) 
    {
        [self setup];
    }
    return self;
}

- (void)setup
{
    if (mContext) return; // already initialized!
    
    // A system version of 3.1 or greater is required to use CADisplayLink.
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    if ([currSysVer compare:@"3.1" options:NSNumericSearch] != NSOrderedAscending)
        mDisplayLinkSupported = YES;
    
    self.frameRate = 30.0f;
    
    // get the layer
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
    
    eaglLayer.opaque = YES;
    eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, 
        kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];    

    mContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];    
    
    if (!mContext || ![EAGLContext setCurrentContext:mContext])        
        NSLog(@"Could not create render context");    
    
    mRenderSupport = [[SPRenderSupport alloc] init];
}

- (void)layoutSubviews 
{
    [self destroyFramebuffer]; // reset framebuffer (scale factor could have changed)
    [self createFramebuffer];
    [self renderStage];        // fill buffer immediately to avoid flickering
}

- (void)createFramebuffer 
{    
    glGenFramebuffersOES(1, &mFramebuffer);
    glGenRenderbuffersOES(1, &mRenderbuffer);
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, mFramebuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, mRenderbuffer);
    [mContext renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(CAEAGLLayer*)self.layer];
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, mRenderbuffer);
    
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &mWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &mHeight);
    
    if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) 
        NSLog(@"failed to create framebuffer: %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
}

- (void)destroyFramebuffer 
{
    glDeleteFramebuffersOES(1, &mFramebuffer);
    mFramebuffer = 0;
    glDeleteRenderbuffersOES(1, &mRenderbuffer);
    mRenderbuffer = 0;    
}

- (void)renderStage
{
    if (mFramebuffer == 0 || mRenderbuffer == 0) 
        return; // buffers not yet initialized
    
    SP_CREATE_POOL(pool);
    
    double now = CACurrentMediaTime();
    double timePassed = now - mLastFrameTimestamp;
    [mStage advanceTime:timePassed];
    mLastFrameTimestamp = now;
    
    [EAGLContext setCurrentContext:mContext];
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, mFramebuffer);
    glViewport(0, 0, mWidth, mHeight);
    
    [mRenderSupport bindTexture:nil]; // old textures could have become invalid
    [mStage render:mRenderSupport];
    
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, mRenderbuffer);
    [mContext presentRenderbuffer:GL_RENDERBUFFER_OES];
    
    SP_RELEASE_POOL(pool);
}

- (void)setTimer:(NSTimer *)newTimer 
{    
    if (mTimer != newTimer)
    {
        [mTimer invalidate];        
        mTimer = newTimer;
    }
}

- (void)setDisplayLink:(id)newDisplayLink
{
    if (mDisplayLink != newDisplayLink)
    {
        [mDisplayLink invalidate];
        mDisplayLink = newDisplayLink;
    }
}

- (void)setFrameRate:(float)value
{    
    if (mDisplayLinkSupported)
    {
        int frameInterval = 1;            
        while (REFRESH_RATE / frameInterval > value)
            ++frameInterval;
        mFrameRate = REFRESH_RATE / frameInterval;
    }
    else 
        mFrameRate = value;
    
    if (self.isStarted)
    {
        [self stop];
        [self start];
    }
}

- (BOOL)isStarted
{
    return mTimer || mDisplayLink;
}

- (void)start
{
    if (self.isStarted) return;
    if (mFrameRate > 0.0f)
    {
        mLastFrameTimestamp = CACurrentMediaTime();
        
        if (mDisplayLinkSupported)
        {
            mDisplayLink = [NSClassFromString(@"CADisplayLink") 
                            displayLinkWithTarget:self selector:@selector(renderStage)];
            
			[mDisplayLink setFrameInterval: (int)(REFRESH_RATE / mFrameRate)];
			[mDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        }
        else 
        {
            // timer used as a fallback
            self.timer = [NSTimer scheduledTimerWithTimeInterval:(1.0f / mFrameRate) 
                target:self selector:@selector(renderStage) userInfo:nil repeats:YES];            
        }
    }    
}

- (void)stop
{
    [self renderStage]; // draw last-moment changes
    
    self.timer = nil;
    self.displayLink = nil;
}

- (void)setStage:(SPStage*)stage
{
    if (mStage != stage)
    {
        mStage.nativeView = nil;
        [mStage release];
        mStage = [stage retain];
        mStage.nativeView = self;        
    }
}

+ (Class)layerClass 
{
    return [CAEAGLLayer class];
}

- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event 
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
    if (self.isStarted && mLastTouchTimestamp != event.timestamp)
    {
        SP_CREATE_POOL(pool);
        
        CGSize viewSize = self.bounds.size;
        float xConversion = mStage.width / viewSize.width;
        float yConversion = mStage.height / viewSize.height;
        
        // convert to SPTouches and forward to stage
        NSMutableSet *touches = [NSMutableSet set];        
        double now = CACurrentMediaTime();
        for (UITouch *uiTouch in [event touchesForView:self])
        {
            CGPoint location = [uiTouch locationInView:self];            
            CGPoint previousLocation = [uiTouch previousLocationInView:self];
            SPTouch *touch = [SPTouch touch];
            touch.timestamp = now; // timestamp of uiTouch not compatible to Sparrow timestamp
            touch.globalX = location.x * xConversion;
            touch.globalY = location.y * yConversion;
            touch.previousGlobalX = previousLocation.x * xConversion;
            touch.previousGlobalY = previousLocation.y * yConversion;
            touch.tapCount = uiTouch.tapCount;
            touch.phase = (SPTouchPhase) uiTouch.phase;            
            [touches addObject:touch];
        }
        [mStage processTouches:touches];        
        mLastTouchTimestamp = event.timestamp;
        
        SP_RELEASE_POOL(pool);
    }    
}

- (void)dealloc 
{    
    if ([EAGLContext currentContext] == mContext) 
        [EAGLContext setCurrentContext:nil];
    
    [mContext release];
    [mStage release];   
    [mRenderSupport release];
    [self destroyFramebuffer];
    
    self.timer = nil;       // invalidates timer    
    self.displayLink = nil; // invalidates displayLink        
    
    [super dealloc];
}

@end
