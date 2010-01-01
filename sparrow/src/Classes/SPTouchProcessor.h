//
//  SPTouchProcessor.h
//  Sparrow
//
//  Created by Daniel Sperl on 03.05.09.
//  Copyright 2009 Incognitek. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SPDisplayObjectContainer;

@interface SPTouchProcessor : NSObject 
{
  @private
    SPDisplayObjectContainer *mRoot;
    NSMutableSet *mCurrentTouches;
}

@property (nonatomic, assign) SPDisplayObjectContainer *root;

- (id)initWithRoot:(SPDisplayObjectContainer*)root;
- (void)processTouches:(NSSet*)touches;

@end
