//
//  SPTexture.m
//  Sparrow
//
//  Created by Daniel Sperl on 19.06.09.
//  Copyright 2009 Incognitek. All rights reserved.
//

#import "SPTexture.h"
#import "SPMakros.h"
#import "SPRectangle.h"

@implementation SPTexture

@synthesize clipping = mClipping;
@synthesize hasPremultipliedAlpha = mPremultipliedAlpha;

- (id)init
{    
    if ([[self class] isEqual:[SPTexture class]]) 
    {
        [NSException raise:SP_EXC_ABSTRACT_CLASS 
                    format:@"Attempting to instantiate abstract class SPTexture."];
        [self release];
        return nil;
    }    
    
    if (self = [super init])
    {
        mClipping = [[SPRectangle alloc] initWithX:0.0f y:0.0f width:1.0f height:1.0f];
    }
    return self;
}

- (float)width
{
    [NSException raise:SP_EXC_ABSTRACT_CLASS 
                format:@"This method needs to be implemented by any subclasses."];
    return 0;
}

- (float)height
{
    [NSException raise:SP_EXC_ABSTRACT_CLASS 
                format:@"This method needs to be implemented by any subclasses."];
    return 0;
}

- (uint)textureID
{
    [NSException raise:SP_EXC_ABSTRACT_CLASS 
                format:@"This method needs to be implemented by any subclasses."];
    return 0;    
}

- (void)dealloc
{
    [mClipping release];
    [super dealloc];
}

@end
