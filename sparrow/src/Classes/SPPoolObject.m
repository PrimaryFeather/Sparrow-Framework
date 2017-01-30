//
//  SPPoolObject.m
//  Sparrow
//
//  Created by Daniel Sperl on 17.09.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPPoolObject.h"
#import <malloc/malloc.h>
#import <libkern/OSAtomic.h>

#define COMPLAIN_MISSING_IMP @"Class %@ needs this code:\nSP_IMPLEMENT_MEMORY_POOL();"

@implementation SPPoolInfo
// empty
@end

#ifndef DISABLE_MEMORY_POOLING

@implementation SPPoolObject

+ (id)allocWithZone:(NSZone *)zone
{
    BOOL recycled = NO;
    SPPoolObject *object = nil;
    SPPoolInfo *poolInfo = [self poolInfo];
    @synchronized(poolInfo) 
    {
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
            object = NSAllocateObject(self, 0, NULL);
        }
        else 
        {
            // recycle element, update poolInfo
            object = poolInfo->lastElement;
            poolInfo->lastElement = object->mPoolPredecessor;
            recycled = YES;
        }
    }
    
    if (recycled) 
    {
        // zero out memory. (do not overwrite isa & mPoolPredecessor, thus the offset)
        unsigned int sizeOfFields = sizeof(Class) + sizeof(SPPoolObject *);
        memset((char*)(id)object + sizeOfFields, 0, malloc_size(object) - sizeOfFields);
    }
    
    object->mRetainCount = 1;
    return object;
}

- (uint32_t)retainCount
{
    return mRetainCount;
}

- (id)retain
{
    OSAtomicIncrement32Barrier((int32_t*) &mRetainCount);
    return self;
}

- (oneway void)release
{   
    if (!OSAtomicDecrement32Barrier((int32_t*) &mRetainCount))
    {
        SPPoolInfo *poolInfo = [isa poolInfo];
        @synchronized(poolInfo) 
        {
            self->mPoolPredecessor = poolInfo->lastElement;
            poolInfo->lastElement = self;
        }
    }
}

- (void)purge
{
    // will call 'dealloc' internally --
    // which should not be called directly.
    [super release];
}

+ (int)purgePool
{
    SPPoolInfo *poolInfo = [self poolInfo];
    @synchronized(poolInfo)
    {
        SPPoolObject *lastElement;    
        
        int count=0;
        while ((lastElement = poolInfo->lastElement))
        {
            ++count;        
            poolInfo->lastElement = lastElement->mPoolPredecessor;
            [lastElement purge];
        }
        
        return count;
    }
}

+ (SPPoolInfo *)poolInfo
{
    [NSException raise:NSGenericException format:COMPLAIN_MISSING_IMP, self];
    return 0;
}

@end

#else

@implementation SPPoolObject

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