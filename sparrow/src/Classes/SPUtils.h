//
//  SPUtils.h
//  Sparrow
//
//  Created by Daniel Sperl on 04.01.11.
//  Copyright 2011 Incognitek. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SPUtils : NSObject 

+ (int)nextPowerOfTwo:(int)number;
+ (int)randomIntBetween:(int)minValue and:(int)maxValue;
+ (float)randomFloat;

@end
