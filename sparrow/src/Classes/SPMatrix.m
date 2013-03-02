//
//  SPMatrix.m
//  Sparrow
//
//  Created by Daniel Sperl on 26.03.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPMatrix.h"
#import "SPPoint.h"
#import "SPMacros.h"

@implementation SPMatrix
{
    float mA, mB, mC, mD;
    float mTx, mTy;
}

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
    if ((self = [super init]))
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

- (void)setA:(float)a b:(float)b c:(float)c d:(float)d tx:(float)tx ty:(float)ty
{
    mA = a; mB = b; mC = c; mD = d;
    mTx = tx; mTy = ty;
}

- (float)determinant
{
    return mA * mD - mC * mB;
}

- (void)appendMatrix:(SPMatrix*)lhs
{
    setValues(self, lhs->mA * mA  + lhs->mC * mB, 
                    lhs->mB * mA  + lhs->mD * mB, 
                    lhs->mA * mC  + lhs->mC * mD,
                    lhs->mB * mC  + lhs->mD * mD,
                    lhs->mA * mTx + lhs->mC * mTy + lhs->mTx,
                    lhs->mB * mTx + lhs->mD * mTy + lhs->mTy);
}

- (void)prependMatrix:(SPMatrix *)rhs
{
    setValues(self, mA * rhs->mA + mC * rhs->mB,
                    mB * rhs->mA + mD * rhs->mB,
                    mA * rhs->mC + mC * rhs->mD,
                    mB * rhs->mC + mD * rhs->mD,
                    mTx + mA * rhs->mTx + mC * rhs->mTy,
                    mTy + mB * rhs->mTx + mD * rhs->mTy);
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
    float cos = cosf(angle);
    float sin = sinf(angle);
    
    setValues(self, mA*cos  - mB*sin,    mA*sin  + mB*cos, 
                    mC*cos  - mD*sin,    mC*sin  + mD*cos, 
                    mTx*cos - mTy * sin, mTx*sin + mTy*cos);
}

- (void)skewXBy:(float)sx yBy:(float)sy
{
    float sinX = sinf(sx);
    float cosX = cosf(sx);
    float sinY = sinf(sy);
    float cosY = cosf(sy);
    
    setValues(self, mA  * cosY - mB  * sinX,
                    mA  * sinY + mB  * cosX,
                    mC  * cosY - mD  * sinX,
                    mC  * sinY + mD  * cosX,
                    mTx * cosY - mTy * sinX,
                    mTx * sinY + mTy * cosX);
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

- (SPPoint *)transformPointWithX:(float)x y:(float)y
{
    return [SPPoint pointWithX:mA*x + mC*y + mTx
                             y:mB*x + mD*y + mTy];
}

- (void)invert
{
    float det = self.determinant;
    setValues(self, mD/det, -mB/det, -mC/det, mA/det, (mC*mTy-mD*mTx)/det, (mB*mTx-mA*mTy)/det);
}

- (void)copyFromMatrix:(SPMatrix *)matrix
{
    setValues(self, matrix->mA, matrix->mB, matrix->mC, matrix->mD, matrix->mTx, matrix->mTy);
}

- (GLKMatrix4)convertToGLKMatrix4
{
    GLKMatrix4 matrix = GLKMatrix4Identity;
    
    matrix.m00 = mA;
    matrix.m01 = mB;
    matrix.m10 = mC;
    matrix.m11 = mD;
    matrix.m30 = mTx;
    matrix.m31 = mTy;
    
    return matrix;
}

- (GLKMatrix3)convertToGLKMatrix3
{
    return GLKMatrix3Make(mA,  mB,  0.0f,
                          mC,  mD,  0.0f,
                          mTx, mTy, 1.0f);
}

- (BOOL)isEquivalent:(SPMatrix *)other
{
    if (other == self) return YES;
    else if (!other) return NO;
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
    return [NSString stringWithFormat:@"[SPMatrix: a=%f, b=%f, c=%f, d=%f, tx=%f, ty=%f]", 
            mA, mB, mC, mD, mTx, mTy];
}

+ (id)matrixWithA:(float)a b:(float)b c:(float)c d:(float)d tx:(float)tx ty:(float)ty
{
    return [[self alloc] initWithA:a b:b c:c d:d tx:tx ty:ty];
}

+ (id)matrixWithIdentity
{
    return [[self alloc] init];
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone*)zone
{
    return [[[self class] allocWithZone:zone] initWithA:mA b:mB c:mC d:mD 
                                                     tx:mTx ty:mTy];
}

#pragma mark SPPoolObject

+ (SPPoolInfo *)poolInfo
{
    static SPPoolInfo *poolInfo = nil;
    if (!poolInfo) poolInfo = [[SPPoolInfo alloc] init];
    return poolInfo;
}

@end
