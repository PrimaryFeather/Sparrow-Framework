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
    NSInvocation *mSetter;
    NSInvocation *mGetter;
    float mStartValue;
    float mEndValue;
    char  mNumericType;
}

@property (nonatomic, retain) NSInvocation *setter;
@property (nonatomic, retain) NSInvocation *getter;
@property (nonatomic, assign) float startValue;
@property (nonatomic, assign) float endValue;
@property (nonatomic, assign) char numericType;

- (id)initWithGetter:(NSInvocation *)getter setter:(NSInvocation *)setter 
          startValue:(float)startValue endValue:(float)endValue numericType:(char)type;

@end