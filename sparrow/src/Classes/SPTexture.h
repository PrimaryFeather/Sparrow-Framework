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
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class SPRectangle;

typedef enum 
{
    SPColorSpaceRGBA,
    SPColorSpaceAlpha
} SPColorSpace;

typedef void (^SPTextureDrawingBlock)(CGContextRef context);

@interface SPTexture : NSObject

- (id)initWithWidth:(float)width height:(float)height draw:(SPTextureDrawingBlock)drawingBlock;
- (id)initWithWidth:(float)width height:(float)height scale:(float)scale 
         colorSpace:(SPColorSpace)colorSpace draw:(SPTextureDrawingBlock)drawingBlock;

- (id)initWithContentsOfFile:(NSString *)path;
- (id)initWithContentsOfImage:(UIImage *)image;
- (id)initWithRegion:(SPRectangle*)region ofTexture:(SPTexture*)texture;

- (void)adjustTextureCoordinates:(const float *)texCoords saveAtTarget:(float *)targetTexCoords 
                     numVertices:(int)numVertices;

+ (SPTexture *)textureWithContentsOfFile:(NSString*)path;
+ (SPTexture *)textureWithRegion:(SPRectangle *)region ofTexture:(SPTexture *)texture;
+ (SPTexture *)textureWithWidth:(float)width height:(float)height draw:(SPTextureDrawingBlock)drawingBlock;
+ (SPTexture *)emptyTexture;

@property (nonatomic, readonly) float width;
@property (nonatomic, readonly) float height;
@property (nonatomic, readonly) uint textureID;
@property (nonatomic, readonly) BOOL hasPremultipliedAlpha;
@property (nonatomic, readonly) float scale;

@end
