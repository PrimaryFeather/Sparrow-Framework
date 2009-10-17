//
//  SPTweenedProperty.m
//  Sparrow
//
//  Created by Daniel Sperl on 17.10.09.
//  Copyright 2009 Incognitek. All rights reserved.
//

#import "SPTweenedProperty.h"


@implementation SPTweenedProperty

@synthesize getter = mGetter; 
@synthesize setter = mSetter;
@synthesize startValue = mStartValue;
@synthesize endValue = mEndValue;
@synthesize numericType = mNumericType;

- (id)initWithGetter:(NSInvocation *)getter setter:(NSInvocation *)setter 
          startValue:(float)startValue endValue:(float)endValue numericType:(char)type
{
    if (self = [super init])
    {
        mGetter = [getter retain];
        mSetter = [setter retain];
        mStartValue = startValue;
        mEndValue = endValue;
        mNumericType = type;
    }
    return self;
}

- (id)init
{
    return [self initWithGetter:nil setter:nil startValue:0.0f endValue:0.0f numericType:'f'];
}

- (void)dealloc
{
    [mGetter release];
    [mSetter release];
    [super dealloc];
}

@end
