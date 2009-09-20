//
//  SPPoint.h
//  Sparrow
//
//  Created by Daniel Sperl on 23.03.09.
//  Copyright 2009 Incognitek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPPoolObject.h"

@interface SPPoint : SPPoolObject <NSCopying>
{
  @private
    float mX;
    float mY;
}

@property (nonatomic, assign) float x;
@property (nonatomic, assign) float y;
@property (readonly) float length;
@property (readonly) float angle;

// designated initializer
- (id)initWithX:(float)x y:(float)y;
- (id)initWithPolarLength:(float)length angle:(float)angle;
- (id)init;
- (BOOL)isEqual:(id)other;

- (SPPoint*)addPoint:(SPPoint*)point;
- (SPPoint*)subtractPoint:(SPPoint*)point;
- (SPPoint*)normalize;

+ (float)distanceFromPoint:(SPPoint*)p1 toPoint:(SPPoint*)p2;
+ (SPPoint *)pointWithPolarLength:(float)length angle:(float)angle;
+ (SPPoint *)pointWithX:(float)x y:(float)y;
+ (SPPoint *)point;

@end
