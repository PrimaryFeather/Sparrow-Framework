//
//  SPPoolObject.m
//  Sparrow
//
//  Created by Daniel Sperl on 17.09.09.
//  Copyright 2009 Incognitek. All rights reserved.
//

#import "SPPoolObject.h"
#include <malloc/malloc.h>

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

+ (SPPoolInfo *)poolInfo
{
    [NSException raise:NSGenericException format:COMPLAIN_MISSING_IMP, self];
    return 0;
}

@end

#endif