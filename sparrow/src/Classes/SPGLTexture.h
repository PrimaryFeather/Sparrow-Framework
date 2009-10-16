//
//  SPGLTexture.h
//  Sparrow
//
//  Created by Daniel Sperl on 27.06.09.
//  Copyright 2009 Incognitek. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SPTexture.h"
#import "SPMakros.h"

@class SPRectangle;

@interface SPGLTexture : SPTexture
{
  @private
    uint mTextureID;
    float mWidth;
    float mHeight;
    BOOL mRepeat;
}

- (id)initWithData:(const void*)imgData width:(int)width height:(int)height 
            format:(SPTextureFormat)format premultipliedAlpha:(BOOL)pma;

+ (SPGLTexture*)textureWithData:(const void*)imgData width:(int)width height:(int)height
                             format:(SPTextureFormat)format premultipliedAlpha:(BOOL)pma;

@property (nonatomic, assign) BOOL repeat;

@end