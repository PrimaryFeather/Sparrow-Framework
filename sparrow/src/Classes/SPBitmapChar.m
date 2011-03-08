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

- (id)initWithID:(int)charID texture:(SPTexture *)texture
         xOffset:(float)xOffset yOffset:(float)yOffset xAdvance:(float)xAdvance;
{
    if (self = [super initWithTexture:texture])
    {
        mCharID = charID;
        mXOffset = xOffset;
        mYOffset = yOffset;
        mXAdvance = xAdvance;
		mKernings = [[NSMutableDictionary alloc] init];
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

- (void)addKerning:(int)toCharID amount:(int)amount
{
	NSNumber *n = [[NSNumber numberWithInt:amount] retain];
	[mKernings setObject:n forKey:[NSNumber numberWithInt:toCharID]];
}

- (int)getKerning:(int)toCharID
{
	int result = 0;
	
	NSNumber *amount = (NSNumber *)[mKernings objectForKey:[NSNumber numberWithInt:toCharID]];
	if (amount)
	{
		result = [amount intValue];
	}
	
	return result;
}

- (void)dealloc
{
    [mKernings release];
    [super dealloc];
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone*)zone;
{
    return [[[self class] allocWithZone:zone] initWithID:mCharID texture:self.texture 
                                                 xOffset:mXOffset yOffset:mYOffset 
                                                xAdvance:mXAdvance];
}

@end
