//
//  SPNSAdditions.m
//  Sparrow
//
//  Created by Daniel Sperl on 13.05.09.
//  Copyright 2009 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPNSExtensions.h"

@implementation NSInvocation (SPNSExtensions)

+ (NSInvocation*)invocationWithTarget:(id)target selector:(SEL)selector
{
    NSMethodSignature *signature = [target methodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.selector = selector;
    invocation.target = target;
    return invocation;
}

@end
