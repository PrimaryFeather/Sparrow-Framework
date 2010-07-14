//
//  SPNSAdditions.h
//  Sparrow
//
//  Created by Daniel Sperl on 13.05.09.
//  Copyright 2009 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>

@interface NSInvocation (SPNSExtensions)

+ (NSInvocation *)invocationWithTarget:(id)target selector:(SEL)selector;

@end

@interface NSString (SPNSExtensions)

- (NSString *)stringByAppendingSuffixToFilename:(NSString *)suffix;

@end

@interface NSBundle (SPNSExtensions)

- (NSString *)pathForResource:(NSString *)name withScaleFactor:(float)factor;

@end