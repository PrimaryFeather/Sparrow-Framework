//
//  RoundButton.m
//  Demo
//
//  Created by Daniel Sperl on 22.08.09.
//  Copyright 2009 Incognitek. All rights reserved.
//

#import "RoundButton.h"


@implementation RoundButton

- (SPDisplayObject*)hitTestPoint:(SPPoint*)localPoint
{
    // when the user touches the screen, this method is used to find out if it hit an object.
    // by default, this method uses the bounding box. 
    // by overriding this method, we can change the box (rectangle) to a circle (or whatever
    // necessary).
    
    if (!self.isVisible) return nil; // when the button is invisible, the hit test must fail.
    
    // get center of button
    SPRectangle *bounds = self.bounds;    
    float centerX = bounds.width / 2;
    float centerY = bounds.height / 2;    
    
    // calculate distance of localPoint to center. 
    // we keep it squared, since we want to avoid the 'sqrt()'-call.
    float sqDist = (localPoint.x - centerX) * (localPoint.x - centerX) + 
                   (localPoint.y - centerY) * (localPoint.y - centerX);

    // when the squared distance is smaller than the squared radius, the point is inside
    // the circle
    float radius = bounds.width / 2;
    if (sqDist < radius * radius) return self;
    else return nil;
}

@end
