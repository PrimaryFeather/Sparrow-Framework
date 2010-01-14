//
//  SPPoolObject.m
//  Sparrow
//
//  Created by Daniel Sperl on 17.09.09.
//  Copyright 2009 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPPoolObject.h"
#import <malloc/malloc.h>

#ifndef DISABLE_MEMORY_POOLING

#define COMPLAIN_MISSING_IMP @"Class %@ needs this code:\n\
+ (SPPoolInfo *) poolInfo\n\
{\n\
  static SPPoolInfo poolInfo;\n\
  return &poolInfo;\n\
}"

@implementation SPPoolObject

+ (id)allocWithZone:(NSZone *)zone
{
    SPPoolInfo *poolInfo = [self poolInfo];
    if (!poolInfo->poolClass) // first allocation
    {
        poolInfo->poolClass = self;
        poolInfo->lastElement = NULL;
    }
    else 
    {
        if (poolInfo->poolClass != self)
            [NSException raise:NSGenericException format:COMPLAIN_MISSING_IMP, self];
    }
    
    if (!poolInfo->lastElement) 
    {
        // pool is empty -> allocate
        return NSAllocateObject(self, 0, NULL);
    }
    else 
    {
        // recycle element, update poolInfo
        SPPoolObject *object = poolInfo->lastElement;
        poolInfo->lastElement = object->mPoolPredecessor;

        // zero out memory. (do not overwrite isa & mPoolPredecessor, thus "+2" and "-8")
        memset((id)object + 2, 0, malloc_size(object) - 8);
        
        return object;
    }
}

- (void)dealloc
{
    SPPoolInfo *poolInfo = [isa poolInfo];
    self->mPoolPredecessor = poolInfo->lastElement;
    poolInfo->lastElement = self;
    
    if (0) [super dealloc]; // just to shut down a compiler warning ...
}

- (void)purge
{
    [super dealloc];
}

+ (int)purgePool
{
    SPPoolInfo *poolInfo = [self poolInfo];    
    SPPoolObject *lastElement;    
    
    int count=0;
    while (lastElement = poolInfo->lastElement)
    {
        ++count;        
        poolInfo->lastElement = lastElement->mPoolPredecessor;
        [lastElement purge];
    }
    
    return count;
}

+ (SPPoolInfo *)poolInfo
{
    [NSException raise:NSGenericException format:COMPLAIN_MISSING_IMP, self];
    return 0;
}

@end

#else

@implementation NSObject (SPPoolObjectExtensions)

+ (SPPoolInfo *)poolInfo 
{
    return nil;
}

+ (int)purgePool
{
    return 0;
}

@end


#endif