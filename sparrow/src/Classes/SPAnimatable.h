//
//  SPAnimatable.h
//  Sparrow
//
//  Created by Daniel Sperl on 09.05.09.
//  Copyright 2009 Incognitek. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SPAnimatable

@property (nonatomic, readonly) double totalTime;
@property (nonatomic, assign)   double currentTime;

@end
