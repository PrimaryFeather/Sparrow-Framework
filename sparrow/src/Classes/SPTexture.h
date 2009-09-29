//
//  SPTexture.h
//  Sparrow
//
//  Created by Daniel Sperl on 19.06.09.
//  Copyright 2009 Incognitek. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SPRectangle;

// Abstract class! Use SPStaticTexture instead.

@interface SPTexture : NSObject
{
  @protected    
    SPRectangle *mClipping;
    BOOL mPremultipliedAlpha;
}

@property (nonatomic, readonly) float width;
@property (nonatomic, readonly) float height;
@property (nonatomic, readonly) uint textureID;
@property (nonatomic, readonly) BOOL hasPremultipliedAlpha;
@property (nonatomic, retain) SPRectangle *clipping;

@end
