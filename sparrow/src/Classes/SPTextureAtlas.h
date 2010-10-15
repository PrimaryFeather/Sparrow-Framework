//
//  SPTextureAtlas.h
//  Sparrow
//
//  Created by Daniel Sperl on 27.06.09.
//  Copyright 2009 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>

@class SPTexture;

#ifdef __IPHONE_4_0
@interface SPTextureAtlas : NSObject <NSXMLParserDelegate>
#else
@interface SPTextureAtlas : NSObject
#endif
{
  @private
    SPTexture *mAtlasTexture;
    NSMutableDictionary *mTextureRegions;
}

@property (nonatomic, readonly) int count;

- (id)initWithContentsOfFile:(NSString *)path;
- (SPTexture *)textureByName:(NSString *)name;
- (NSArray *)texturesStartingWith:(NSString *)name;

+ (SPTextureAtlas *)atlasWithContentsOfFile:(NSString *)path;

@end
