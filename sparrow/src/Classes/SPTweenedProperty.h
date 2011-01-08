//
//  SPTweenedProperty.h
//  Sparrow
//
//  Created by Daniel Sperl on 17.10.09.
//  Copyright 2009 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>

/** ------------------------------------------------------------------------------------------------
 
 An SPTweenedProperty stores the information about the tweening of a single property of an object.
 Its `currentValue` property updates the specified property of the target object.
 
 _This is an internal class. You do not have to use it manually._
 
------------------------------------------------------------------------------------------------- */

@interface SPTweenedProperty : NSObject
{
  @private
    id  mTarget;
    
    SEL mGetter;
    IMP mGetterFunc;    
    SEL mSetter;    
    IMP mSetterFunc;

    float mStartValue;
    float mEndValue;
    char  mNumericType;
}

/// ------------------
/// @name Initializers
/// ------------------

/// Initializes a tween property on a certain target. The start value will be zero.
- (id)initWithTarget:(id)target name:(NSString *)name endValue:(float)endValue;

/// ----------------
/// @name Properties
/// ----------------

/// The start value of the tween.
@property (nonatomic, assign) float startValue;

/// The current value of the tween. Setting this property updates the target property.
@property (nonatomic, assign) float currentValue;

/// The end value of the tween.
@property (nonatomic, assign) float endValue;

/// The animation delta (endValue - startValue)
@property (nonatomic, readonly) float delta;


@end