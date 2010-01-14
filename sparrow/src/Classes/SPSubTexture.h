//
//  SPSubTexture.h
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

@interface SPSubTexture : SPTexture 
{
  @private
    SPTexture *mBaseTexture;
    SPRectangle *mClipping;
    SPRectangle *mRootClipping;
}

@property (nonatomic, readonly) SPTexture *baseTexture;
@property (nonatomic, copy) SPRectangle *clipping;

- (id)initWithRegion:(SPRectangle*)region ofTexture:(SPTexture*)texture;
+ (SPSubTexture*)textureWithRegion:(SPRectangle*)region ofTexture:(SPTexture*)texture;

@end
