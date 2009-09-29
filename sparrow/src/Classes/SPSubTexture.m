//
//  SPSubTexture.m
//  Sparrow
//
//  Created by Daniel Sperl on 27.06.09.
//  Copyright 2009 Incognitek. All rights reserved.
//

#import "SPSubTexture.h"
#import "SPRectangle.h"
#import "SPStaticTexture.h"

@implementation SPSubTexture

@synthesize baseTexture = mBaseTexture;

- (id)initWithRegion:(SPRectangle*)region ofTexture:(SPTexture*)texture
{
    if (self = [super init])
    {
        mBaseTexture = [texture retain];
        mPremultipliedAlpha = texture.hasPremultipliedAlpha;

        // convert region to clipping rectangle (which has values between 0 and 1)
        float clipWidth = texture.clipping.width;
        float clipHeight = texture.clipping.height;
        self.clipping = [SPRectangle rectangleWithX:region.x/texture.width * clipWidth
                                                  y:region.y/texture.height * clipHeight
                                              width:region.width/texture.width * clipWidth
                                             height:region.height/texture.height * clipHeight];
    }
    return self;
}

- (id)init
{
    SPTexture *texture = [[[SPStaticTexture alloc] init] autorelease];
    SPRectangle *region = [SPRectangle rectangleWithX:0 y:0 width:texture.width height:texture.height];
    return [self initWithRegion:region ofTexture:texture];
}

- (float)width
{
    return mBaseTexture.width * mClipping.width;
}

- (float)height
{
    return mBaseTexture.height * mClipping.height;
}

- (uint)textureID
{
    return mBaseTexture.textureID;
}

+ (SPSubTexture*)textureWithRegion:(SPRectangle*)region ofTexture:(SPTexture*)texture
{
    return [[[SPSubTexture alloc] initWithRegion:region ofTexture:texture] autorelease];
}

- (void)dealloc
{
    [mBaseTexture release];
    [super dealloc];
}

@end
