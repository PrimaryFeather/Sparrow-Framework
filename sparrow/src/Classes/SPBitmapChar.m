//
//  SPBitmapChar.m
//  Sparrow
//
//  Created by Daniel Sperl on 12.10.09.
//  Copyright 2009 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
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

- (id)init
{
    [self release];
    return nil;
}

- (void)dealloc
{
    [mTexture release];    
    [super dealloc];
}

@end
