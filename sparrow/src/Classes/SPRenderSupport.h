//
//  SPRenderContext.h
//  Sparrow
//
//  Created by Daniel Sperl on 28.09.09.
//  Copyright 2009 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>

@class SPTexture;

@interface SPRenderSupport : NSObject 
{
  @private
    uint mBoundTextureID;
    BOOL mPremultipliedAlpha;
}

- (void)bindTexture:(SPTexture *)texture;
- (uint)convertColor:(uint)color alpha:(float)alpha;

+ (uint)convertColor:(uint)color alpha:(float)alpha premultiplyAlpha:(BOOL)pma;

@property (nonatomic, readonly) BOOL usingPremultipliedAlpha;

@end
