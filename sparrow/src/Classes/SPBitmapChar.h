//
//  SPBitmapChar.h
//  Sparrow
//
//  Created by Daniel Sperl on 12.10.09.
//  Copyright 2009 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>
#import "SPImage.h"

/** ------------------------------------------------------------------------------------------------

 An SPBitmapChar is an image that contains one char of a bitmap font. Its properties contain all
 the information that is needed to arrange the char in a text. 
 
 _You don't have to use this class directly in most cases._
 
------------------------------------------------------------------------------------------------- */ 

@interface SPBitmapChar : SPImage <NSCopying> 
{
  @private
    int mCharID;
    float mXOffset;
    float mYOffset;
    float mXAdvance;    
}

/// ------------------
/// @name Initializers
/// ------------------

/// Initializes a char with a texture and his properties.
- (id)initWithID:(int)charID texture:(SPTexture *)texture
         xOffset:(float)xOffset yOffset:(float)yOffset xAdvance:(float)xAdvance;

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

@end
