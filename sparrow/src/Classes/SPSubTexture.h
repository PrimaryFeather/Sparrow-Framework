//
//  SPSubTexture.h
//  Sparrow
//
//  Created by Daniel Sperl on 27.06.09.
//  Copyright 2009 Incognitek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPTexture.h"

@interface SPSubTexture : SPTexture 
{
  @private
    SPTexture *mBaseTexture;
}

@property (nonatomic, readonly) SPTexture *baseTexture;

- (id)initWithRegion:(SPRectangle*)region ofTexture:(SPTexture*)texture;
+ (SPSubTexture*)textureWithRegion:(SPRectangle*)region ofTexture:(SPTexture*)texture;

@end
