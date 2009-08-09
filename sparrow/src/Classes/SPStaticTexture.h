//
//  SPStaticTexture.h
//  Sparrow
//
//  Created by Daniel Sperl on 27.06.09.
//  Copyright 2009 Incognitek. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SPTexture.h"
#import "SPMakros.h"

@class SPRectangle;

@interface SPStaticTexture : SPTexture
{
  @private
    uint mTextureID;
    float mWidth;
    float mHeight;
    BOOL mRepeat;
}

// designated initializer; data format: RGBA / unsigned byte
- (id)initWithData:(const void*)imgData width:(int)width height:(int)height;
- (id)initWithContentsOfFile:(NSString*)path;
+ (SPStaticTexture*)textureWithContentsOfFile:(NSString*)path;
+ (SPStaticTexture*)textureWithData:(const void*)imgData width:(int)width height:(int)height;

@property (nonatomic, assign) BOOL repeat;

@end