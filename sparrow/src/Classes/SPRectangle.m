//
//  SPRectangle.m
//  Sparrow
//
//  Created by Daniel Sperl on 21.03.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPRectangle.h"
#import "SPMacros.h"

@implementation SPRectangle

@synthesize x = mX;
@synthesize y = mY;
@synthesize width = mWidth;
@synthesize height = mHeight;

- (id)initWithX:(float)x y:(float)y width:(float)width height:(float)height
{
    if ((self = [super init]))
    {
        mX = x;
        mY = y;
        mWidth = width;
        mHeight = height;
    }
     
    return self;
}

- (id)init
{
    return [self initWithX:0.0f y:0.0f width:0.0f height:0.0f];
}

- (BOOL)containsX:(float)x y:(float)y
{
    return x >= mX && y >= mY && x <= mX + mWidth && y <= mY + mHeight;
}

- (BOOL)containsPoint:(SPPoint*)point
{
    return [self containsX:point.x y:point.y];
}

- (BOOL)containsRectangle:(SPRectangle*)rectangle
{
    if (!rectangle) return NO;
    
    float rX = rectangle->mX;
    float rY = rectangle->mY;
    float rWidth = rectangle->mWidth;
    float rHeight = rectangle->mHeight;

    return rX >= mX && rX + rWidth <= mX + mWidth &&
           rY >= mY && rY + rHeight <= mY + mHeight;
}

- (BOOL)intersectsRectangle:(SPRectangle*)rectangle
{
    if (!rectangle) return  NO;
    
    float rX = rectangle->mX;
    float rY = rectangle->mY;
    float rWidth = rectangle->mWidth;
    float rHeight = rectangle->mHeight;
    
    BOOL outside = 
        (rX <= mX && rX + rWidth <= mX)  || (rX >= mX + mWidth && rX + rWidth >= mX + mWidth) ||
        (rY <= mY && rY + rHeight <= mY) || (rY >= mY + mHeight && rY + rHeight >= mY + mHeight);
    return !outside;
}

- (SPRectangle*)intersectionWithRectangle:(SPRectangle*)rectangle
{
    if (!rectangle) return nil;
    
    float left   = MAX(mX, rectangle->mX);
    float right  = MIN(mX + mWidth, rectangle->mX + rectangle->mWidth);
    float top    = MAX(mY, rectangle->mY);
    float bottom = MIN(mY + mHeight, rectangle->mY + rectangle->mHeight);
    
    if (left > right || top > bottom)
        return [SPRectangle rectangleWithX:0 y:0 width:0 height:0];
    else
        return [SPRectangle rectangleWithX:left y:top width:right-left height:bottom-top];
}

- (SPRectangle*)uniteWithRectangle:(SPRectangle*)rectangle
{
    if (!rectangle) return [[self copy] autorelease];
    
    float left   = MIN(mX, rectangle->mX);
    float right  = MAX(mX + mWidth, rectangle->mX + rectangle->mWidth);
    float top    = MIN(mY, rectangle->mY);
    float bottom = MAX(mY + mHeight, rectangle->mY + rectangle->mHeight);
    return [SPRectangle rectangleWithX:left y:top width:right-left height:bottom-top];
}

- (void)setEmpty
{
    mX = mY = mWidth = mHeight = 0;
}

- (float)top { return mY; }
- (void)setTop:(float)value { mY = value; }

- (float)bottom { return mY + mHeight; }
- (void)setBottom:(float)value { mHeight = value - mY; }

- (float)left { return mX; }
- (void)setLeft:(float)value { mX = value; }

- (float)right { return mX + mWidth; }
- (void)setRight:(float)value { mWidth = value - mX; }

- (SPPoint *)topLeft { return [SPPoint pointWithX:mX y:mY]; }
- (void)setTopLeft:(SPPoint *)value { mX = value.x; mY = value.y; }

- (SPPoint *)bottomRight { return [SPPoint pointWithX:mX+mWidth y:mY+mHeight]; }
- (void)setBottomRight:(SPPoint *)value { self.right = value.x; self.bottom = value.y; }

- (SPPoint *)size { return [SPPoint pointWithX:mWidth y:mHeight]; }
- (void)setSize:(SPPoint *)value { mWidth = value.x; mHeight = value.y; }

- (BOOL)isEmpty
{
    return mWidth == 0 || mHeight == 0;
}

- (BOOL)isEqual:(id)other 
{
    if (other == self) return YES;
    else if (!other || ![other isKindOfClass:[self class]]) return NO;
    else 
    {
        SPRectangle *rect = (SPRectangle*)other;
        return SP_IS_FLOAT_EQUAL(mX, rect->mX) && SP_IS_FLOAT_EQUAL(mY, rect->mY) &&
               SP_IS_FLOAT_EQUAL(mWidth, rect->mWidth) && SP_IS_FLOAT_EQUAL(mHeight, rect->mHeight);    
    }
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"(x: %f, y: %f, width: %f, height: %f)", mX, mY, mWidth, mHeight];
}

+ (SPRectangle*)rectangleWithX:(float)x y:(float)y width:(float)width height:(float)height
{
    return [[[SPRectangle alloc] initWithX:x y:y width:width height:height] autorelease];
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone*)zone
{
    return [[[self class] allocWithZone:zone] initWithX:mX y:mY width:mWidth height:mHeight];
}

#pragma mark SPPoolObject

+ (SPPoolInfo *)poolInfo
{
    static SPPoolInfo *poolInfo = nil;
    if (!poolInfo) poolInfo = [[SPPoolInfo alloc] init];
    return poolInfo;
}

@end
