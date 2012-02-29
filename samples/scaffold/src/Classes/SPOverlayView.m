//
//  SPOverlayView.m
//  AppScaffold
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
