//
//  SPTweenedProperty.h
//  Sparrow
//
//  Created by Daniel Sperl on 17.10.09.
//  Copyright 2009 Incognitek. All rights reserved.
//

#import <Foundation/Foundation.h>


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

@property (nonatomic, assign) float startValue;
@property (nonatomic, assign) float currentValue;
@property (nonatomic, assign) float endValue;
@property (nonatomic, readonly) float delta;

- (id)initWithTarget:(id)target name:(NSString *)name endValue:(float)endValue;

@end