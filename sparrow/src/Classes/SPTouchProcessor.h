//
//  SPTouchProcessor.h
//  Sparrow
//
//  Created by Daniel Sperl on 03.05.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>

@class SPDisplayObjectContainer;

/** ------------------------------------------------------------------------------------------------

 The SPTouchProcesser processes raw touch information and dispatches it on display objects.
 
 _This is an internal class. You do not have to use it manually._

------------------------------------------------------------------------------------------------- */

@interface SPTouchProcessor : NSObject 
{
  @private
    SPDisplayObjectContainer *mRoot;
    NSMutableSet *mCurrentTouches;
}

/// ------------------
/// @name Initializers
/// ------------------

/// Initializes a touch processor with a certain root object.
- (id)initWithRoot:(SPDisplayObjectContainer*)root;

/// -------------
/// @name Methods
/// -------------

/// @name Processes raw touches and dispatches events on the touched display objects.
- (void)processTouches:(NSSet*)touches;

/// ----------------
/// @name Properties
/// ----------------

/// The root display container to check for touched targets.
@property (nonatomic, assign) SPDisplayObjectContainer *root;

@end
