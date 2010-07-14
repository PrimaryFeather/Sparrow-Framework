//
//  SPTexture.h
//  Sparrow
//
//  Created by Daniel Sperl on 19.06.09.
//  Copyright 2009 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>

typedef enum 
{
    SPTextureFormatRGBA,
    SPTextureFormatAlpha
} SPTextureFormat;

@class SPRectangle;

@interface SPTexture : NSObject

- (id)initWithContentsOfFile:(NSString *)path;
- (void)adjustTextureCoordinates:(const float *)texCoords saveAtTarget:(float *)targetTexCoords 
                     numVertices:(int)numVertices;

+ (SPTexture *)textureWithContentsOfFile:(NSString*)path;
+ (SPTexture *)emptyTexture;

@property (nonatomic, readonly) float width;
@property (nonatomic, readonly) float height;
@property (nonatomic, readonly) uint textureID;
@property (nonatomic, readonly) BOOL hasPremultipliedAlpha;
@property (nonatomic, readonly) float scale;

@end
