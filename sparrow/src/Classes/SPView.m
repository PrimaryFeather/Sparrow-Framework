//
//  EAGLView.m
//  Sparrow
//
//  Created by Daniel Sperl on 13.03.09.
//  Copyright Incognitek 2009. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>

#import "SPStage.h"
#import "SPStage_Internal.h"
#import "SPView.h"
#import "SPMakros.h"
#import "SPTouch.h"
#import "SPTouch_Internal.h"

// --- private interface ---------------------------------------------------------------------------

@interface SPView ()

@property (nonatomic, retain) EAGLContext *context;
@property (nonatomic, retain) NSTimer *timer;

- (id)initialize;
- (BOOL)createFramebuffer;
- (void)destroyFramebuffer;
- (void)renderStage;
- (void)processTouchEvent:(UIEvent*)event;

@end

// --- class implementation ------------------------------------------------------------------------

@implementation SPView

@synthesize stage = mStage;
@synthesize context = mContext;
@synthesize timer = mTimer;
@synthesize frameRate = mFrameRate;

#pragma mark -

- (id)initWithCoder:(NSCoder*)coder 
{
    if (self = [super initWithCoder:coder]) return [self initialize];
    else return nil;
}

- (id)initWithFrame:(CGRect)aRect
{
    if (self = [super initWithFrame:aRect]) return [self initialize];
    else return nil;
}

- (id)initialize
{
    self.frameRate = 60.0f;
    self.multipleTouchEnabled = YES;
    self.backgroundColor = [UIColor blackColor];
    [[UIApplication sharedApplication] setStatusBarHidden:YES animated:NO];
    
    // get the layer
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
    
    eaglLayer.opaque = YES;
    eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, 
        kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];    
    
    mContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    
    if (!mContext || ![EAGLContext setCurrentContext:mContext]) 
    {
        [self release];
        return nil;
    }    
    
    return self;
}

#pragma mark -

- (void)setTimer:(NSTimer *)newTimer 
{    
    if (mTimer != newTimer)
    {
        [mTimer invalidate];        
        mTimer = newTimer;
    }
}

- (void)setFrameRate:(double)value
{    
    mFrameRate = value;    
    if (self.isStarted)
    {
        self.isStarted = NO;
        self.isStarted = YES;
    }
}

- (BOOL)isStarted
{
    return mTimer != nil;
}

- (void)setIsStarted:(BOOL)value
{
    if (self.isStarted == value) return;
    if (value && mFrameRate > 0.0f)
    {
        mLastFrameTimestamp = CACurrentMediaTime();
        self.timer = [NSTimer scheduledTimerWithTimeInterval:(1.0f / mFrameRate) 
                              target:self selector:@selector(renderStage) userInfo:nil repeats:YES];
    }
    else
    {
        self.timer = nil;
    }    
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

- (void)renderStage
{    
    SP_CREATE_POOL(pool);
    
    [EAGLContext setCurrentContext:mContext];
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, mFramebuffer);
    glViewport(0, 0, mWidth, mHeight);
    
    double now = CACurrentMediaTime();
    double timePassed = now - mLastFrameTimestamp;
    [mStage advanceTime:timePassed];
    mLastFrameTimestamp = now;
        
    [mStage render];
    
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, mRenderbuffer);
    [mContext presentRenderbuffer:GL_RENDERBUFFER_OES];
    
    SP_RELEASE_POOL(pool);
}
 
#pragma mark -

+ (Class)layerClass 
{
    return [CAEAGLLayer class];
}

- (void)layoutSubviews 
{
    [EAGLContext setCurrentContext:mContext];
    [self destroyFramebuffer];
    [self createFramebuffer];    
}

- (BOOL)createFramebuffer 
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
    {
        NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
        return NO;
    }
    
    return YES;
}

- (void)destroyFramebuffer 
{
    glDeleteFramebuffersOES(1, &mFramebuffer);
    mFramebuffer = 0;
    glDeleteRenderbuffersOES(1, &mRenderbuffer);
    mRenderbuffer = 0;    
}


#pragma mark -

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

- (void)processTouchEvent:(UIEvent*)event
{
    if (self.isStarted && mLastTouchTimestamp != event.timestamp)
    {
        SP_CREATE_POOL(pool);
        
        // convert to SPTouches and forward to stage
        NSMutableSet *touches = [NSMutableSet set];        
        double now = CACurrentMediaTime();
        for (UITouch *uiTouch in [event touchesForView:self])
        {
            CGPoint location = [uiTouch locationInView:self];            
            CGPoint previousLocation = [uiTouch previousLocationInView:self];
            SPTouch *touch = [SPTouch touch];
            touch.timestamp = now; // timestamp of uiTouch not compatible to Sparrow timestamp
            touch.globalX = location.x;
            touch.globalY = location.y;
            touch.previousGlobalX = previousLocation.x;
            touch.previousGlobalY = previousLocation.y;
            touch.tapCount = uiTouch.tapCount;
            touch.phase = (SPTouchPhase) uiTouch.phase;            
            [touches addObject:touch];
        }
        [mStage processTouches:touches];        
        mLastTouchTimestamp = event.timestamp;
        
        SP_RELEASE_POOL(pool);
    }    
}

#pragma mark -

- (void)dealloc 
{    
    self.timer = nil; // invalidates timer    
    if ([EAGLContext currentContext] == mContext) [EAGLContext setCurrentContext:nil];
    [mContext release];  
    [mStage release];
    
    [super dealloc];
}

@end
