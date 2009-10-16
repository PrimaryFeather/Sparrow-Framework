//
//  SPBitmapChar.m
//  Sparrow
//
//  Created by Daniel Sperl on 12.10.09.
//  Copyright 2009 Incognitek. All rights reserved.
//

#import "SPBitmapChar.h"
#import "SPTexture.h"

@implementation SPBitmapChar

@synthesize charID = mCharID;
@synthesize xOffset = mXOffset;
@synthesize yOffset = mYOffset;
@synthesize xAdvance = mXAdvance;
@synthesize texture = mTexture;

- (id)initWithID:(int)charID texture:(SPTexture *)texture
         xOffset:(float)xOffset yOffset:(float)yOffset xAdvance:(float)xAdvance;
{
    if (self = [super init])
    {
        mCharID = charID;
        mTexture = [texture retain];
        mXOffset = xOffset;
        mYOffset = yOffset;
        mXAdvance = xAdvance;
    }
    return self;
}

- (void)dealloc
{
    [mTexture release];    
    [super dealloc];
}

@end
