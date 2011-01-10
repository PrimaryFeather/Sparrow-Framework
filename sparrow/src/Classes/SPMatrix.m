//
//  SPMatrix.m
//  Sparrow
//
//  Created by Daniel Sperl on 26.03.09.
//  Copyright 2009 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPMatrix.h"
#import "SPPoint.h"
#import "SPMacros.h"

#define U 0
#define V 0
#define W 1

@implementation SPMatrix

@synthesize a=mA, b=mB, c=mC, d=mD, tx=mTx, ty=mTy;

// --- c functions ---

static void setValues(SPMatrix *matrix, float a, float b, float c, float d, float tx, float ty)
{
    matrix->mA = a;
    matrix->mB = b;
    matrix->mC = c;
    matrix->mD = d;
    matrix->mTx = tx;
    matrix->mTy = ty;    
}

// ---

- (id)initWithA:(float)a b:(float)b c:(float)c d:(float)d tx:(float)tx ty:(float)ty
{
    if (self = [super init])
    {
        mA = a; mB = b; mC = c; mD = d;
        mTx = tx; mTy = ty;
    }
    return self;
}

- (id)init
{
    return [self initWithA:1 b:0 c:0 d:1 tx:0 ty:0];
}

- (void)setValuesA:(float)a b:(float)b c:(float)c d:(float)d tx:(float)tx ty:(float)ty
{
    mA = a; mB = b; mC = c; mD = d;
    mTx = tx; mTy = ty;
}

- (float)determinant
{
    return mA * mD - mC * mB;
}

- (void)concatMatrix:(SPMatrix*)matrix
{
    setValues(self, matrix->mA * mA  + matrix->mC * mB, 
                    matrix->mB * mA  + matrix->mD * mB, 
                    matrix->mA * mC  + matrix->mC * mD,
                    matrix->mB * mC  + matrix->mD * mD,
                    matrix->mA * mTx + matrix->mC * mTy + matrix->mTx * W,
                    matrix->mB * mTx + matrix->mD * mTy + matrix->mTy * W);
}

- (void)translateXBy:(float)dx yBy:(float)dy
{
    mTx += dx;
    mTy += dy;    
}

- (void)scaleXBy:(float)sx yBy:(float)sy
{
    mA *= sx;
    mB *= sy;
    mC *= sx;
    mD *= sy;
    mTx *= sx;
    mTy *= sy;
}

- (void)scaleBy:(float)scale
{
    [self scaleXBy:scale yBy:scale];
}

- (void)rotateBy:(float)angle
{
    SPMatrix *rotMatrix = [[SPMatrix alloc] initWithA:cosf(angle) b:sinf(angle)
                                                    c:-sinf(angle) d:cosf(angle) tx:0 ty:0];
    [self concatMatrix:rotMatrix];
    [rotMatrix release];    
}

- (void)identity
{
    setValues(self, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f);
}

- (SPPoint*)transformPoint:(SPPoint*)point
{
    return [SPPoint pointWithX:mA*point.x + mC*point.y + mTx
                             y:mB*point.x + mD*point.y + mTy];
}

- (void)invert
{
    float det = self.determinant;
    setValues(self, mD/det, -mB/det, -mC/det, mA/det, (mC*mTy-mD*mTx)/det, (mB*mTx-mA*mTy)/det);
}

- (BOOL)isEqual:(id)other 
{
    if (other == self) return YES;
    else if (!other || ![other isKindOfClass:[self class]]) return NO;
    else 
    {    
        SPMatrix *matrix = (SPMatrix*)other;
        return SP_IS_FLOAT_EQUAL(mA, matrix->mA) && SP_IS_FLOAT_EQUAL(mB, matrix->mB) &&
               SP_IS_FLOAT_EQUAL(mC, matrix->mC) && SP_IS_FLOAT_EQUAL(mD, matrix->mD) &&
               SP_IS_FLOAT_EQUAL(mTx, matrix->mTx) && SP_IS_FLOAT_EQUAL(mTy, matrix->mTy);
    }
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"(a=%f, b=%f, c=%f, d=%f, tx=%f, ty=%f)", 
            mA, mB, mC, mD, mTx, mTy];
}

+ (SPMatrix*)matrixWithA:(float)a b:(float)b c:(float)c d:(float)d tx:(float)tx ty:(float)ty
{
    return [[[SPMatrix alloc] initWithA:a b:b c:c d:d tx:tx ty:ty] autorelease];
}

+ (SPMatrix*)matrixWithIdentity
{
    return [[[SPMatrix alloc] init] autorelease];
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone*)zone;
{
    return [[[self class] allocWithZone:zone] initWithA:mA b:mB c:mC d:mD 
                                                     tx:mTx ty:mTy];
}

#pragma mark SPPoolObject

+ (SPPoolInfo *)poolInfo
{
    static SPPoolInfo poolInfo;
    return &poolInfo;
}

@end
