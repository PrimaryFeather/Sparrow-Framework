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

@interface SPPoolObject : NSObject 
{
    SPPoolObject *mPoolPredecessor;
}

+ (SPPoolInfo *)poolInfo;
+ (int)purgePool;

@end

#else

typedef NSObject SPPoolObject;

@interface NSObject (SPPoolObjectExtensions)

+ (SPPoolInfo *)poolInfo;
+ (int)purgePool;

@end


#endif