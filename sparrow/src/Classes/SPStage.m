//
//  SPStage.m
//  Sparrow
//
//  Created by Daniel Sperl on 15.03.09.
//  Copyright 2009 Incognitek. All rights reserved.
//

#import "SPStage.h"
#import "SPMakros.h"
#import "SPEnterFrameEvent.h"
#import "SPTouchProcessor.h"

@implementation SPStage

@synthesize width = mWidth;
@synthesize height = mHeight;
@synthesize frameRate = mFrameRate;

- (id)initWithWidth:(float)width height:(float)height
{    
    if (self = [super init])
    {
        mWidth = width;
        mHeight = height;
        mTouchProcessor = [[SPTouchProcessor alloc] initWithRoot:self];
    }
    return self;
}

- (id)init
{
    return [self initWithWidth:320 height:480];
}

- (void)advanceTime:(double)seconds
{    
    SP_CREATE_POOL(pool);
    
    // update frameRate    
    mCumulatedTime += seconds;
    ++mFrameCount;
    if (mCumulatedTime >= 1)
    {        
        mFrameRate = (float)mFrameCount / (float)mCumulatedTime;
        mFrameCount = mCumulatedTime = 0;
    }
    
    // dispatch EnterFrameEvent
    SPEnterFrameEvent *enterFrameEvent = [[SPEnterFrameEvent alloc] 
        initWithType:SP_EVENT_TYPE_ENTER_FRAME passedTime:seconds];    
    [self dispatchEvent:enterFrameEvent];
    [enterFrameEvent release];

    SP_RELEASE_POOL(pool);
}

- (void)processTouches:(NSSet*)touches
{
    [mTouchProcessor processTouches:touches];
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

- (void)setRotationZ:(float)value
{
    [NSException raise:SP_EXC_INVALID_OPERATION format:@"cannot rotate stage"];
}

#pragma mark -

- (void)dealloc 
{    
    [mTouchProcessor release];
    [super dealloc];
}

@end

