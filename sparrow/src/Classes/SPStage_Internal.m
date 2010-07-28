//
//  SPStage_Internal.m
//  Sparrow
//
//  Created by Daniel Sperl on 30.08.09.
//  Copyright 2009 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPStage_Internal.h"
#import <UIKit/UIKit.h>

@implementation SPStage (Internal)

- (void)setNativeView:(id)nativeView
{
    if ([nativeView respondsToSelector:@selector(setContentScaleFactor:)])
        [nativeView setContentScaleFactor:[SPStage contentScaleFactor]];    
    
    mNativeView = nativeView;
}

@end
