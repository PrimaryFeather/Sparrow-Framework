//
//  SPStage.m
//  Sparrow
//
//  Created by Daniel Sperl on 15.03.09.
//  Copyright 2009 Incognitek. All rights reserved.
//

#import "SPStage.h"
#import "SPMacros.h"
#import "SPEnterFrameEvent.h"
#import "SPTouchProcessor.h"
#import "SPJuggler.h"

@implementation SPStage

// --- c functions ---

static void dispatchEnterFrameEvent(SPDisplayObject *object, SPEnterFrameEvent *event)
{
    // EnterFrameEvents are dispatched in every frame, and they traverse the entire display tree --
    // thus, it pays off handling them in their own c function.
    
    [object dispatchEvent:event];    
    if ([object isKindOfClass:[SPDisplayObjectContainer class]])
    {
        SPDisplayObjectContainer *container = (SPDisplayObjectContainer *)object;
        for (SPDisplayObject *child in container)        
            dispatchEnterFrameEvent(child, event);
    }    
}

// -------------------

@synthesize width = mWidth;
@synthesize height = mHeight;
@synthesize juggler = mJuggler;
@synthesize nativeView = mNativeView;

- (id)initWithWidth:(float)width height:(float)height
{    
    if (self = [super init])
    {
        mWidth = width;
        mHeight = height;
        mTouchProcessor = [[SPTouchProcessor alloc] initWithRoot:self];
        mJuggler = [[SPJuggler alloc] init];
    }
    return self;
}

- (id)init
{
    return [self initWithWidth:320 height:480];
}

- (void)advanceTime:(double)seconds
{    
    // advance juggler
    [mJuggler advanceTime:seconds];
    
    // dispatch EnterFrameEvent
    SPEnterFrameEvent *enterFrameEvent = [[SPEnterFrameEvent alloc] 
        initWithType:SP_EVENT_TYPE_ENTER_FRAME passedTime:seconds];        
    dispatchEnterFrameEvent(self, enterFrameEvent);
    [enterFrameEvent release];
}

- (void)processTouches:(NSSet*)touches
{
    [mTouchProcessor processTouches:touches];
}

- (SPDisplayObject*)hitTestPoint:(SPPoint*)localPoint forTouch:(BOOL)isTouch;
{
    if (isTouch && (!self.visible || !self.touchable)) 
        return nil;
    
    SPDisplayObject *target = [super hitTestPoint:localPoint forTouch:isTouch];
    
    // different to other containers, the stage should acknowledge touches even in empty parts.
    if (!target)
    {
        SPRectangle *bounds = [SPRectangle rectangleWithX:self.x y:self.y 
                                                    width:self.width height:self.height];
        if ([bounds containsPoint:localPoint])      
            target = self;
    }
    return target;
}

#pragma mark -

- (float)width
{
    return mWidth;
}

- (void)setWidth:(float)width
{
    [NSException raise:SP_EXC_INVALID_OPERATION format:@"cannot set width of stage"];
}

- (float)height
{
    return mHeight;
}

- (void)setHeight:(float)height
{
    [NSException raise:SP_EXC_INVALID_OPERATION format:@"cannot set height of stage"];
}

- (void)setX:(float)value
{
    [NSException raise:SP_EXC_INVALID_OPERATION format:@"cannot set x-coordinate of stage"];
}

- (void)setY:(float)value
{
    [NSException raise:SP_EXC_INVALID_OPERATION format:@"cannot set y-coordinate of stage"];
}

- (void)setScaleX:(float)value
{
    [NSException raise:SP_EXC_INVALID_OPERATION format:@"cannot scale stage"];
}

- (void)setScaleY:(float)value
{
    [NSException raise:SP_EXC_INVALID_OPERATION format:@"cannot scale stage"];
}

- (void)setRotation:(float)value
{
    [NSException raise:SP_EXC_INVALID_OPERATION format:@"cannot rotate stage"];
}

- (void)setFrameRate:(float)value
{
    [mNativeView setFrameRate:value];
}

- (float)frameRate
{
    return [mNativeView frameRate];
}

#pragma mark -

- (void)dealloc 
{    
    [SPPoint purgePool];
    [SPRectangle purgePool];
    [SPMatrix purgePool];    
    
    [mTouchProcessor release];
    [mJuggler release];
    [super dealloc];
}

@end

