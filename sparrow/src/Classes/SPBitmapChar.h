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

@class SPTexture;

@interface SPBitmapChar : NSObject 
{
  @private
    int mCharID;
    float mXOffset;
    float mYOffset;
    float mXAdvance;
    SPTexture *mTexture;
}

@property (nonatomic, readonly) int charID;
@property (nonatomic, readonly) float xOffset;
@property (nonatomic, readonly) float yOffset;
@property (nonatomic, readonly) float xAdvance;
@property (nonatomic, readonly) SPTexture *texture;

- (id)initWithID:(int)charID texture:(SPTexture *)texture
         xOffset:(float)xOffset yOffset:(float)yOffset xAdvance:(float)xAdvance;

@end
