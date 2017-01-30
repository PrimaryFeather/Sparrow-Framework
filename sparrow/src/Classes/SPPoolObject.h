//
//  SPPoolObject.h
//  Sparrow
//
//  Created by Daniel Sperl on 17.09.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>

@class SPPoolObject;

/// Internal Helper class for `SPPoolObject`.
@interface SPPoolInfo : NSObject
{
  @public
    Class poolClass;
    SPPoolObject *lastElement;
}

@end

#ifdef SP_ENABLE_MEMORY_POOLING
    #define SP_IMPLEMENT_MEMORY_POOL() \
    + (SPPoolInfo *)poolInfo \
    {   \
        static dispatch_once_t once; \
        static SPPoolInfo *poolInfo = nil;  \
        dispatch_once(&once, ^{ poolInfo = [[SPPoolInfo alloc] init]; }); \
        return poolInfo;    \
    }   \
#else
    #define SP_IMPLEMENT_MEMORY_POOL() + (SPPoolInfo *)poolInfo { return nil; }
#endif

/** ------------------------------------------------------------------------------------------------
 
 The SPPoolObject class is an alternative to the base class `NSObject` that manages a pool of 
 objects.
 
 Subclasses of SPPoolObject do not deallocate object instances when the retain counter reaches
 zero. Instead, the objects stay in memory and will be re-used when a new instance of the object
 is requested. That way, object initialization is accelerated. You can release the memory of all 
 recycled objects anytime by calling the `purgePool` method.
 
 Because it is not thread-safe, memory pooling is disabled by default. To enable it, you should
 define SP_ENABLE_MEMORY_POOLING in Sparrow, and in your project. (SPPoolObject is unsafe for
 use in multithreaded applications. If your game has multiple threads (e.g. for loading assets
 or network communication), you should not use SPPoolObject.)

 Sparrow uses this class for `SPPoint`, `SPRectangle` and `SPMatrix`, as they are created very often 
 as helper objects.
 
 To use memory pooling for another class, you just have to inherit from SPPoolObject and put
 the following macro somewhere in your implementation:
 
    SP_IMPLEMENT_MEMORY_POOL();
 
 ------------------------------------------------------------------------------------------------- */

#ifdef SP_ENABLE_MEMORY_POOLING

@interface SPPoolObject : NSObject 
{
  @private
    SPPoolObject *mPoolPredecessor;
    uint mRetainCount;
}

/// The pool info structure needed to access the pool. Needs to be implemented in any inheriting class.
+ (SPPoolInfo *)poolInfo;

/// Purge all unused objects.
+ (int)purgePool;

@end

#else

@interface SPPoolObject : NSObject 

/// Dummy implementation of SPPoolObject method to simplify switching between NSObject and SPPoolObject.
+ (SPPoolInfo *)poolInfo;

/// Dummy implementation of SPPoolObject method to simplify switching between NSObject and SPPoolObject.
+ (int)purgePool;

@end

#endif