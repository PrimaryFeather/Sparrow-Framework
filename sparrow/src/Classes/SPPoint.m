//
//  SPPoint.m
//  Sparrow
//
//  Created by Daniel Sperl on 23.03.09.
//  Copyright 2009 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPPoint.h"
#import "SPMacros.h"
#import <math.h>

// --- class implementation ------------------------------------------------------------------------

#define SQ(x) ((x)*(x))

@implementation SPPoint

@synthesize x = mX;
@synthesize y = mY;

// designated initializer
- (id)initWithX:(float)x y:(float)y
{
    if (self = [super init])
    {
        mX = x;
        mY = y;        
    }
    return self;
}

- (id)initWithPolarLength:(float)length angle:(float)angle
{
    return [self initWithX:cosf(angle)*length y:sinf(angle)*length];
}

- (id)init
{
    return [self initWithX:0.0f y:0.0f];
}

- (float)length
{
    return sqrtf(SQ(mX) + SQ(mY));
}

- (float)angle
{
    return atan2f(mY, mX);
}

- (SPPoint*)addPoint:(SPPoint*)point
{
    SPPoint *result = [[SPPoint alloc] initWithX:mX+point->mX y:mY+point->mY];    
    return [result autorelease];
}

- (SPPoint*)subtractPoint:(SPPoint*)point
{
    SPPoint *result = [[SPPoint alloc] initWithX:mX-point->mX y:mY-point->mY];    
    return [result autorelease];
}

- (SPPoint *)scaleBy:(float)scalar
{
    SPPoint *result = [[SPPoint alloc] initWithX:mX * scalar y:mY * scalar];
    return [result autorelease];
}

- (SPPoint*)normalize
{
    if (mX == 0 && mY == 0)
        [NSException raise:SP_EXC_INVALID_OPERATION format:@"Cannot normalize point in the origin"];
        
    float inverseLength = 1.0f / self.length;
    SPPoint *result = [[SPPoint alloc] initWithX:mX * inverseLength y:mY * inverseLength];
    return [result autorelease];
}

- (BOOL)isEqual:(id)other 
{
    if (other == self) return YES;
    else if (!other || ![other isKindOfClass:[self class]]) return NO;
    else 
    {
        SPPoint *point = (SPPoint*)other;
        return SP_IS_FLOAT_EQUAL(mX, point->mX) && SP_IS_FLOAT_EQUAL(mY, point->mY);    
    }
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"(x=%f, y=%f)", mX, mY];
}

+ (float)distanceFromPoint:(SPPoint*)p1 toPoint:(SPPoint*)p2
{
    return sqrtf(SQ(p2->mX - p1->mX) + SQ(p2->mY - p1->mY));
}

+ (SPPoint *)interpolateFromPoint:(SPPoint *)p1 toPoint:(SPPoint *)p2 ratio:(float)ratio
{
    float invRatio = 1.0f - ratio;
    return [SPPoint pointWithX:invRatio * p1->mX + ratio * p2->mX
                             y:invRatio * p1->mY + ratio * p2->mY];
}

+ (SPPoint *)pointWithPolarLength:(float)length angle:(float)angle
{
    return [[[SPPoint alloc] initWithPolarLength:length angle:angle] autorelease];
}

+ (SPPoint *)pointWithX:(float)x y:(float)y
{
    return [[[SPPoint alloc] initWithX:x y:y] autorelease];
}

+ (SPPoint*)point
{
    return [[[SPPoint alloc] init] autorelease];
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone*)zone;
{
    return [[[self class] allocWithZone:zone] initWithX:mX y:mY];
}

#pragma mark SPPoolObject

+ (SPPoolInfo *)poolInfo
{
    static SPPoolInfo poolInfo;
    return &poolInfo;
}

@end
