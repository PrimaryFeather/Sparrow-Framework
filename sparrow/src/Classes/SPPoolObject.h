//
//  SPPoolObject.h
//  Sparrow
//
//  Created by Daniel Sperl on 17.09.09.
//  Copyright 2009 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>

@class SPPoolObject;

typedef struct
{
    Class poolClass;
    SPPoolObject *lastElement;    
} SPPoolInfo;

#ifndef DISABLE_MEMORY_POOLING


/** ------------------------------------------------------------------------------------------------
 
 The SPPoolObject class is an alternative to the base class `NSObject` that manages a pool of 
 objects.
 
 Subclasses of SPPoolObject do not deallocate object instances when the retain counter reaches
 zero. Instead, the objects stay in memory and will be re-used when a new instance of the object
 is requested. That way, object initialization is accelerated. You can release the memory of all 
 recycled objects anytime by calling the `purgePool` method.
 
 Sparrow uses this class for `SPPoint`, `SPRectangle` and `SPMatrix`, as they are created very often 
 as helper objects.
 
 To use memory pooling for another class, you just have to inherit from SPPoolObject and implement
 the following method:
 
 	+ (SPPoolInfo *) poolInfo
 	{
 	    static SPPoolInfo poolInfo;
 	    return &poolInfo;
 	}
 
 ------------------------------------------------------------------------------------------------- */

@interface SPPoolObject : NSObject 
{
    SPPoolObject *mPoolPredecessor;
}

/// The pool info structure needed to access the pool. Needs to be implemented in any inheriting class.
+ (SPPoolInfo *)poolInfo;

/// Purge all unused objects.
+ (int)purgePool;

@end

#else

typedef NSObject SPPoolObject;

/// Sparrow extensions for NSObject.
@interface NSObject (SPPoolObjectExtensions)

/// Dummy implementation of SPPoolObject method to simplify switching between NSObject and SPPoolObject.
+ (SPPoolInfo *)poolInfo;

/// Dummy implementation of SPPoolObject method to simplify switching between NSObject and SPPoolObject.
+ (int)purgePool;

@end


#endif