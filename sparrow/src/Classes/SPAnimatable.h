//
//  SPAnimatable.h
//  Sparrow
//
//  Created by Daniel Sperl on 09.05.09.
//  Copyright 2009 Incognitek. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SPAnimatable

- (void)advanceTime:(double)seconds;

@property (nonatomic, readonly) BOOL isComplete;

@end
