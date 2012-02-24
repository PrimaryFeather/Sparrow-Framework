//
//  OverlayView.m
//  AppScaffold
//
//  Created by Sperl Daniel on 20.02.12.
//  Copyright (c) 2012 Gamua. All rights reserved.
//

#import "OverlayView.h"

@implementation OverlayView

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    // This class makes a UIView work just like a sprite in Sparrow:
    // it will react only on touches of child objects, and won't block touches on 
    // empty areas any longer. That makes it perfect for an overlay view, on which
    // we can then add all kinds of UIKit elements: textfields, iAd banners, etc.
    
    for (UIView *subview in self.subviews)
    {
        CGPoint innerPoint = CGPointMake(point.x - subview.frame.origin.x,
                                         point.y - subview.frame.origin.y);
        if ([subview pointInside:innerPoint withEvent:event]) return YES;
    }
    
    return NO;
}

@end
