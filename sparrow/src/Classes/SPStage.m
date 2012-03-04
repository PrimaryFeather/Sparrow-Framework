//
//  SPStage.m
//  Sparrow
//
//  Created by Daniel Sperl on 15.03.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPStage.h"
#import "SPStage_Internal.h"
#import "SPDisplayObject_Internal.h"
#import "SPMacros.h"
#import "SPEnterFrameEvent.h"
#import "SPTouchProcessor.h"
#import "SPJuggler.h"

#import <UIKit/UIKit.h>
#import <UIKit/UIDevice.h>

// --- static members ------------------------------------------------------------------------------

static BOOL supportHighResolutions = NO;
static BOOL doubleOnPad = NO;
static float contentScaleFactor = -1;
static NSMutableArray *stages = NULL;

// --- class implementation ------------------------------------------------------------------------

@implementation SPStage

@synthesize width = mWidth;
@synthesize height = mHeight;
@synthesize color = mColor;
@synthesize juggler = mJuggler;
@synthesize nativeView = mNativeView;

- (id)initWithWidth:(float)width height:(float)height
{    
    if ((self = [super init]))
    {
        // Save existing stages to have access to them in "SPStage setSupportHighResolutions:".
        // We use a CFArray to avoid that 'self' is retained -> that would cause a memory leak!
        if (!stages) stages = (NSMutableArray *)CFArrayCreateMutable(NULL, 0, NULL);
        [stages addObject:self];
        
        mWidth = width;
        mHeight = height;
        mTouchProcessor = [[SPTouchProcessor alloc] initWithRoot:self];
        mJuggler = [[SPJuggler alloc] init];
    }
    return self;
}

- (id)init
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    return [self initWithWidth:screenSize.width height:screenSize.height];
}

- (void)advanceTime:(double)seconds
{    
    // advance juggler
    [mJuggler advanceTime:seconds];
    
    // dispatch EnterFrameEvent
    SPEnterFrameEvent *enterFrameEvent = [[SPEnterFrameEvent alloc] 
        initWithType:SP_EVENT_TYPE_ENTER_FRAME passedTime:seconds];
    [self broadcastEvent:enterFrameEvent];
    [enterFrameEvent release];
}

- (void)processTouches:(NSSet*)touches
{
    [mTouchProcessor processTouches:touches];
}

- (SPDisplayObject*)hitTestPoint:(SPPoint*)localPoint forTouch:(BOOL)isTouch
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

+ (SPStage *)mainStage
{
    return [stages objectAtIndex:0];
}

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

- (void)setPivotX:(float)value
{
    [NSException raise:SP_EXC_INVALID_OPERATION format:@"cannot set pivot coordinates of stage"];
}

- (void)setPivotY:(float)value
{
    [NSException raise:SP_EXC_INVALID_OPERATION format:@"cannot set pivot coordinates of stage"];
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

- (void)dealloc 
{    
    [SPPoint purgePool];
    [SPRectangle purgePool];
    [SPMatrix purgePool];
    
    [mTouchProcessor release];
    [mJuggler release];
    
    [stages removeObject:self];
    if (stages.count == 0) { [stages release]; stages = NULL; }    
    
    [super dealloc];
}

@end

// -------------------------------------------------------------------------------------------------

@implementation SPStage (HDSupport)

+ (void)updateNativeViews
{
    for (SPStage *stage in stages)
    {
        if ([stage.nativeView respondsToSelector:@selector(contentScaleFactor)])
        {
            float factor = supportHighResolutions ? [[UIScreen mainScreen] scale] : 1.0f;
            if (contentScaleFactor != -1) factor = contentScaleFactor;
            
            [stage.nativeView setContentScaleFactor:factor];
            [stage.nativeView layoutSubviews];
        }
    }
}

+ (void)setSupportHighResolutions:(BOOL)hd doubleOnPad:(BOOL)pad
{
    if (hd != supportHighResolutions || pad != doubleOnPad)
    {
        supportHighResolutions = hd;
        doubleOnPad = hd && pad; // only makes sense with hd = YES
        [self updateNativeViews];
    }
}

+ (void)setSupportHighResolutions:(BOOL)hd
{
    [self setSupportHighResolutions:hd doubleOnPad:NO];
}

+ (BOOL)supportHighResolutions
{
    return supportHighResolutions;
}

+ (BOOL)doubleResolutionsOnPad
{
    return doubleOnPad;
}

// DEPRECATED
+ (void)setContentScaleFactor:(float)value
{
    if (value != contentScaleFactor)
    {
        contentScaleFactor = value;
        [SPStage updateNativeViews];
    }
}

+ (float)contentScaleFactor
{
    if (supportHighResolutions && [UIScreen instancesRespondToSelector:@selector(scale)])
    {
        if (contentScaleFactor == -1)
        {
            float factor = [[UIScreen mainScreen] scale];
            if (doubleOnPad && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) factor *= 2;
            return factor;
        }
        else return contentScaleFactor;
    }
    else
    {
        return 1.0f;
    }
}

@end

// -------------------------------------------------------------------------------------------------

@implementation SPStage (Internal)

- (void)setNativeView:(id)nativeView
{
    mNativeView = nativeView;
    [SPStage updateNativeViews];
}

@end
