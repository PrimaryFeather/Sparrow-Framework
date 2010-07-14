//
//  SPGLTexture.h
//  Sparrow
//
//  Created by Daniel Sperl on 27.06.09.
//  Copyright 2009 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>

#import "SPTexture.h"
#import "SPMacros.h"

@class SPRectangle;

@interface SPGLTexture : SPTexture
{
  @private
    uint mTextureID;
    float mWidth;
    float mHeight;
    float mScale;
    BOOL mRepeat;
    BOOL mPremultipliedAlpha;    
}

- (id)initWithData:(const void*)imgData width:(int)width height:(int)height 
            format:(SPTextureFormat)format premultipliedAlpha:(BOOL)pma;

+ (SPGLTexture*)textureWithData:(const void*)imgData width:(int)width height:(int)height
                         format:(SPTextureFormat)format premultipliedAlpha:(BOOL)pma;

@property (nonatomic, assign) BOOL repeat;
@property (nonatomic, assign) float scale;

@end