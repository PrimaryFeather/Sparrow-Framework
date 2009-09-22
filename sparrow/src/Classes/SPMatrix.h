//
//  SPMatrix.h
//  Sparrow
//
//  Created by Daniel Sperl on 26.03.09.
//  Copyright 2009 Incognitek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPPoolObject.h"

@class SPPoint;

// this is the form of the matrix:
// |a c tx|
// |b d ty|
// |0 0  1|
 
@interface SPMatrix : SPPoolObject <NSCopying>
{
  @private
    float mA, mB, mC, mD;
    float mTx, mTy;
}

@property (nonatomic, assign) float a;
@property (nonatomic, assign) float b;
@property (nonatomic, assign) float c;
@property (nonatomic, assign) float d;
@property (nonatomic, assign) float tx;
@property (nonatomic, assign) float ty;
@property (nonatomic, readonly) float determinant;

// designated initializer
- (id)initWithA:(float)a b:(float)b c:(float)c d:(float)d tx:(float)tx ty:(float)ty;
- (id)init;
- (BOOL)isEqual:(id)other;

- (void)concatMatrix:(SPMatrix*)matrix;
- (void)translateXBy:(float)dx yBy:(float)dy;
- (void)scaleXBy:(float)sx yBy:(float)sy;
- (void)scaleBy:(float)scale;
- (void)rotateBy:(float)angle;
- (void)identity;
- (void)invert;
- (SPPoint*)transformPoint:(SPPoint*)point;

+ (SPMatrix*)matrixWithA:(float)a b:(float)b c:(float)c d:(float)d tx:(float)tx ty:(float)ty;
+ (SPMatrix*)matrixWithIdentity;

@end
