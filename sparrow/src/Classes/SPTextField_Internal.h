//
//  SPTextField_Internal.h
//  Sparrow
//
//  Created by Daniel Sperl on 06.01.12.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.

#import "SPTextField.h"

@class SPBitmapFont;

@interface SPTextField (Internal)

- (void)redrawContents;
- (SPDisplayObject *)createRenderedContents;
- (SPDisplayObject *)createComposedContents;

@end
