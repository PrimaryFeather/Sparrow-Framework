//
//  SPRenderContext.h
//  Sparrow
//
//  Created by Daniel Sperl on 28.09.09.
//  Copyright 2009 Incognitek. All rights reserved.
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

@property (nonatomic, readonly) BOOL usingPremultipliedAlpha;

@end
