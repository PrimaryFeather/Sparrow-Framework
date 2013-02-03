//
//  SPSparrow.h
//  Sparrow
//
//  Created by Daniel Sperl on 27.01.13.
//  Copyright 2013 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>
#import "SPViewController.h"
#import "SPJuggler.h"

@interface Sparrow : NSObject

+ (SPViewController *)currentController;
+ (SPJuggler *)juggler;
+ (SPStage *)stage;
+ (float)contentScaleFactor;

@end
