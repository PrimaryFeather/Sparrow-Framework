//
//  SPOverlayView.m
//  Sparrow
//
//  Created by Daniel Sperl on 26.01.13.
//  Copyright 2013 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPOverlayView.h"

@implementation SPOverlayView

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    for (UIView *subview in self.subviews)
    {
        CGPoint innerPoint = CGPointMake(point.x - subview.frame.origin.x,
                                         point.y - subview.frame.origin.y);
        if ([subview pointInside:innerPoint withEvent:event]) return YES;
    }
    
    return NO;
}

@end
