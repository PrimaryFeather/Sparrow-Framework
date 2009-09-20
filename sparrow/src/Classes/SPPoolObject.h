//
//  SPPoolObject.h
//  Sparrow
//
//  Created by Daniel Sperl on 17.09.09.
//  Copyright 2009 Incognitek. All rights reserved.
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

@end

#else

typedef NSObject SPPoolObject;

#endif