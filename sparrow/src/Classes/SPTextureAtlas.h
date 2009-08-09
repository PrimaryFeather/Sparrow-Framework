//
//  SPTextureAtlas.h
//  Sparrow
//
//  Created by Daniel Sperl on 27.06.09.
//  Copyright 2009 Incognitek. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SPTexture;

@interface SPTextureAtlas : NSObject 
{
  @private
    SPTexture *mAtlasTexture;
    NSMutableDictionary *mTextureRegions;
}

@property (nonatomic, readonly) int count;

- (id)initWithContentsOfFile:(NSString*)path;
- (SPTexture*)textureByName:(NSString*)name;

+ (SPTextureAtlas*)atlasWithContentsOfFile:(NSString*)path;

@end
