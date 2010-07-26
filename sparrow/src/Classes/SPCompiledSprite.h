//
//  SPCompiledContainer.h
//  Sparrow
//
//  Created by Daniel Sperl on 15.07.10.
//  Copyright 2010 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>
#import "SPSprite.h"

@interface SPCompiledSprite : SPSprite
{
  @private
    NSArray *mTextureSwitches;    
    NSMutableData *mColorData;
    uint *mCurrentColors;
    BOOL mAlphaChanged;
    
    uint mIndexBuffer;
    uint mVertexBuffer;
    uint mColorBuffer;
    uint mTexCoordBuffer;
}

- (id)init;
- (BOOL)compile;
+ (SPCompiledSprite *)sprite;

@end