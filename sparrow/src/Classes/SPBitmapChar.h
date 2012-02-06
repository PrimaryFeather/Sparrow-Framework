//
//  SPBitmapChar.h
//  Sparrow
//
//  Created by Daniel Sperl on 12.10.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>
#import "SPImage.h"

/** ------------------------------------------------------------------------------------------------

 A BitmapChar contains the information about one char of a bitmap font.
 
 _You don't have to use this class directly in most cases._
 
------------------------------------------------------------------------------------------------- */ 

@interface SPBitmapChar : NSObject
{
  @private
    SPTexture *mTexture;
    int mCharID;
    float mXOffset;
    float mYOffset;
    float mXAdvance;
    NSMutableDictionary *mKernings;
}

/// ------------------
/// @name Initializers
/// ------------------

/// Initializes a char with a texture and its properties.
- (id)initWithID:(int)charID texture:(SPTexture *)texture
         xOffset:(float)xOffset yOffset:(float)yOffset xAdvance:(float)xAdvance;

/// -------------
/// @name Methods
/// -------------

/// Adds kerning information relative to a specific other character ID.
- (void)addKerning:(float)amount toChar:(int)charID;

/// Retrieve kerning information relative to the given character ID.
- (float)kerningToChar:(int)charID;

/// Creates an image of the char.
- (SPImage *)createImage;

/// ----------------
/// @name Properties
/// ----------------

/// The unicode ID of the char.
@property (nonatomic, readonly) int charID;

/// The number of pixels to move the char in x direction on character arrangement.
@property (nonatomic, readonly) float xOffset;

/// The number of pixels to move the char in y direction on character arrangement.
@property (nonatomic, readonly) float yOffset;

/// The number of pixels the cursor has to be moved to the right for the next char.
@property (nonatomic, readonly) float xAdvance;

/// The texture of the character.
@property (nonatomic, retain) SPTexture *texture;

@end
