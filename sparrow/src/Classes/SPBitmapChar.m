//
//  SPBitmapChar.m
//  Sparrow
//
//  Created by Daniel Sperl on 12.10.09.
//  Copyright 2011 Gamua. All rights reserved.
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
    if ((self = [super init]))
    {
        mTexture = [texture retain];
        mCharID = charID;
        mXOffset = xOffset;
        mYOffset = yOffset;
        mXAdvance = xAdvance;
		mKernings = nil;
    }
    return self;
}

- (id)initWithTexture:(SPTexture *)texture
{
    return [self initWithID:0 texture:texture xOffset:0 yOffset:0 xAdvance:texture.width];
}

- (id)init
{
    [self release];
    return nil;
}

- (void)addKerning:(float)amount toChar:(int)charID
{
    if (!mKernings)
        mKernings = [[NSMutableDictionary alloc] init];    

	[mKernings setObject:[NSNumber numberWithFloat:amount] 
                  forKey:[NSNumber numberWithInt:charID]];
}

- (float)kerningToChar:(int)charID
{
	NSNumber *amount = (NSNumber *)[mKernings objectForKey:[NSNumber numberWithInt:charID]];
	return [amount floatValue];
}

- (SPImage *)createImage
{
    return [SPImage imageWithTexture:mTexture];
}

- (void)dealloc
{
    [mKernings release];
    [mTexture release];
    [super dealloc];
}

@end
