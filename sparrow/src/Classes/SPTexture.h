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
#import <QuartzCore/QuartzCore.h>

@class SPRectangle;

typedef enum 
{
    SPColorSpaceRGBA,
    SPColorSpaceAlpha
} SPColorSpace;

typedef void (^SPTextureDrawingBlock)(CGContextRef context);

@interface SPTexture : NSObject

- (id)initWithContentsOfFile:(NSString *)path;
- (id)initWithWidth:(int)width height:(int)height draw:(SPTextureDrawingBlock)drawingBlock;
- (id)initWithWidth:(int)width height:(int)height scale:(float)scale 
         colorSpace:(SPColorSpace)colorSpace draw:(SPTextureDrawingBlock)drawingBlock;

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
