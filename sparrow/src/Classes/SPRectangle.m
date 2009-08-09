//
//  SPRectangle.m
//  Sparrow
//
//  Created by Daniel Sperl on 21.03.09.
//  Copyright 2009 Incognitek. All rights reserved.
//

#import "SPRectangle.h"
#import "SPMakros.h"

@implementation SPRectangle

@synthesize x = mX;
@synthesize y = mY;
@synthesize width = mWidth;
@synthesize height = mHeight;

- (id)initWithX:(float)x y:(float)y width:(float)width height:(float)height
{
    if (self = [super init])
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

- (BOOL)containsPoint:(SPPoint*)point
{
    return [self containsX:point.x y:point.y];
}

- (BOOL)containsX:(float)x y:(float)y
{
    return x >= mX && y >= mY && x <= mX + mWidth && y <= mY + mHeight;
}

- (BOOL)isEqual:(id)other 
{
    if (other == self) return YES;
    else if (!other || ![other isKindOfClass:[self class]]) return NO;
    else 
    {
        SPRectangle *rect = (SPRectangle*)other;
        return SP_IS_FLOAT_EQUAL(mX, rect.x) && SP_IS_FLOAT_EQUAL(mY, rect.y) &&
               SP_IS_FLOAT_EQUAL(mWidth, rect.width) && SP_IS_FLOAT_EQUAL(mHeight, rect.height);    
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

- (id)copyWithZone:(NSZone*)zone;
{
    return [[[self class] allocWithZone:zone] initWithX:mX y:mY width:mWidth height:mHeight];
}

@end
