//
//  SPTweenedProperty.m
//  Sparrow
//
//  Created by Daniel Sperl on 17.10.09.
//  Copyright 2009 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPTweenedProperty.h"
#import "SPMacros.h"

typedef float  (*FnPtrGetterF) (id, SEL);
typedef double (*FnPtrGetterD) (id, SEL);
typedef int    (*FnPtrGetterI) (id, SEL);

typedef void (*FnPtrSetterF) (id, SEL, float);
typedef void (*FnPtrSetterD) (id, SEL, double);
typedef void (*FnPtrSetterI) (id, SEL, int);
 
@implementation SPTweenedProperty

@synthesize startValue = mStartValue;
@synthesize endValue = mEndValue;

- (id)initWithTarget:(id)target name:(NSString *)name endValue:(float)endValue;
{
    if (self = [super init])
    {
        mTarget = [target retain];        
        mEndValue = endValue;
        
        mGetter = NSSelectorFromString(name);
        mSetter = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:", 
                                        [[name substringToIndex:1] uppercaseString], 
                                        [name substringFromIndex:1]]);
        
        if (![mTarget respondsToSelector:mGetter] || ![mTarget respondsToSelector:mSetter])
            [NSException raise:SP_EXC_INVALID_OPERATION format:@"property not found or readonly: '%@'", 
             name];    
        
        // query argument type
        NSMethodSignature *sig = [mTarget methodSignatureForSelector:mGetter];
        mNumericType = *[sig methodReturnType];    
        if (mNumericType != 'f' && mNumericType != 'i' && mNumericType != 'd')
            [NSException raise:SP_EXC_INVALID_OPERATION format:@"property not numeric: '%@'", name];
        
        mGetterFunc = [mTarget methodForSelector:mGetter];
        mSetterFunc = [mTarget methodForSelector:mSetter];       
    }
    return self;
}

- (id)init
{
    return [self initWithTarget:nil name:nil endValue:0.0f];
}

- (void)setCurrentValue:(float)value
{
    if (mNumericType == 'f')
    {
        FnPtrSetterF func = (FnPtrSetterF)mSetterFunc;
        func(mTarget, mSetter, value);
    }        
    else if (mNumericType == 'd')
    {
        FnPtrSetterD func = (FnPtrSetterD)mSetterFunc;
        func(mTarget, mSetter, (double)value);
    }        
    else
    {
        FnPtrSetterI func = (FnPtrSetterI)mSetterFunc;
        func(mTarget, mSetter, (int)(value+0.5f));
    }        
}

- (float)currentValue
{
    if (mNumericType == 'f')
    {
        FnPtrGetterF func = (FnPtrGetterF)mGetterFunc;
        return func(mTarget, mGetter);
    }
    else if (mNumericType == 'd')
    {
        FnPtrGetterD func = (FnPtrGetterD)mGetterFunc;
        return func(mTarget, mGetter);
    }
    else 
    {
        FnPtrGetterI func = (FnPtrGetterI)mGetterFunc;
        return func(mTarget, mGetter);
    }
}

- (float)delta
{
    return mEndValue - mStartValue;
}

- (void)dealloc
{
    [mTarget release];
    [super dealloc];
}

@end
