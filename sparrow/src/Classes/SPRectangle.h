//
//  SPRectangle.h
//  Sparrow
//
//  Created by Daniel Sperl on 21.03.09.
//  Copyright 2009 Incognitek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPPoint.h"

@interface SPRectangle : NSObject <NSCopying>
{
  @private
    float mX;
    float mY;
    float mWidth;
    float mHeight;
}

@property (nonatomic, assign) float x;
@property (nonatomic, assign) float y;
@property (nonatomic, assign) float width;
@property (nonatomic, assign) float height;

- (id)initWithX:(float)x y:(float)y width:(float)width height:(float)height;
- (BOOL)containsPoint:(SPPoint*)point;
- (BOOL)containsX:(float)x y:(float)y;

+ (SPRectangle*)rectangleWithX:(float)x y:(float)y width:(float)width height:(float)height;

/*
// todo: add at least the following methods:
- (BOOL)containsRectangle:(SPRectangle*)rectangle;
- (BOOL)intersectsRectangle:(SPRectangle*)rectangle;
- (SPRectangle*)intersectionWithRectangle:(SPRectangle*)rectangle;
- (SPRectangle*)uniteWithRectangle:(SPRectangle*)rectangle; 
- (BOOL)isEqual;
// property: empty (set+get)
*/
 
@end