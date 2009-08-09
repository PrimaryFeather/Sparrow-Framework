//
//  SPMatrix.m
//  Sparrow
//
//  Created by Daniel Sperl on 26.03.09.
//  Copyright 2009 Incognitek. All rights reserved.
//

#import "SPMatrix.h"
#import "SPPoint.h"
#import "SPMakros.h"

#define U 0
#define V 0
#define W 1

// --- private interface ---------------------------------------------------------------------------

@interface SPMatrix ()

@property (nonatomic, readonly) float determinant;

- (void)setValuesA:(float)a b:(float)b c:(float)c d:(float)d tx:(float)tx ty:(float)ty;

@end

// --- class implementation ------------------------------------------------------------------------

@implementation SPMatrix

@synthesize a=mA, b=mB, c=mC, d=mD, tx=mTx, ty=mTy;

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
    [self setValuesA: matrix.a * mA  + matrix.c * mB 
                   b: matrix.b * mA  + matrix.d * mB 
                   c: matrix.a * mC  + matrix.c * mD
                   d: matrix.b * mC  + matrix.d * mD
                  tx: matrix.a * mTx + matrix.c * mTy + matrix.tx * W
                  ty: matrix.b * mTx + matrix.d * mTy + matrix.ty * W];
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
    [self setValuesA:1.0f b:0.0f c:0.0f d:1.0f tx:0.0f ty:0.0f];
}

- (SPPoint*)transformPoint:(SPPoint*)point
{
    return [SPPoint pointWithX:mA*point.x + mC*point.y + mTx
                             y:mB*point.x + mD*point.y + mTy];
}

- (void)invert
{
    float det = self.determinant;
    [self setValuesA:mD/det b:-mB/det c:-mC/det d:mA/det 
                  tx:(mC*mTy-mD*mTx)/det 
                  ty:(mB*mTx-mA*mTy)/det];
}

- (BOOL)isEqual:(id)other 
{
    if (other == self) return YES;
    else if (!other || ![other isKindOfClass:[self class]]) return NO;
    else 
    {    
        SPMatrix *matrix = (SPMatrix*)other;
        return SP_IS_FLOAT_EQUAL(mA, matrix.a) && SP_IS_FLOAT_EQUAL(mB, matrix.b) &&
               SP_IS_FLOAT_EQUAL(mB, matrix.b) && SP_IS_FLOAT_EQUAL(mC, matrix.c) &&
               SP_IS_FLOAT_EQUAL(mTx, matrix.tx) && SP_IS_FLOAT_EQUAL(mTy, matrix.ty);
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

@end
