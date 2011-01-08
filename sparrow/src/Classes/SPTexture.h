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

/** ------------------------------------------------------------------------------------------------

 A texture stores the information that represents an image. It cannot be displayed directly, 
 but has to be mapped onto a display object. In Sparrow, that display object is `SPImage`.
 
 *Image formats*
 
 Sparrow supports different file formats for textures. The most common formats are `PNG`, which
 contains an alpha channel, and `JPG` (without an alpha channel). You can also load files in 
 the `PVR` format (compressed or uncompressed). That's a special format of the graphics chip of
 iOS devices that is very efficient.
 
 *HD textures*
 
 Furthermore, Sparrow supports development in multiple resolutions, i.e. creating a game
 simultaneously for normal and retina displays. If HD texture support is activated (via
 `[SPStage setSupportHighResolutions:]`) and you load a texture like this:
 
	SPTexture *texture = [[SPTexture alloc] initWithContentsOfFile:@"image.png"];
 
 Sparrow will check if it finds the file `"image@2x.png"`, and will load that instead (provided that
 it is available and the application is running on a HD device). The texture object will then
 return values for width and height that are the original number of pixels divided by 2 
 (by setting their scale-factor to `2.0`). That way, you will always work with the same values 
 for width and height - regardless of the device type.
 
 *Drawing API*
 
 Sparrow lets you create custom graphics directly at run-time by using the `Core Graphics` API.
 You access the drawing API with a special init-method of SPTexture, which takes a `block`-parameter
 you can fill with your drawing code. 
  
	SPTexture *customTexture = [[SPTexture alloc] initWithWidth:200 height:100
	    draw:^(CGContextRef context)
	    {
	        // draw a string
	        CGContextSetGrayFillColor(context, 1.0f, 1.0f);
	        NSString *string = @"Hello Core Graphics";
	        [string drawAtPoint:CGPointMake(20.0f, 20.0f) 
                       withFont:[UIFont fontWithName:@"Arial" size:25]];
	    }];
 
------------------------------------------------------------------------------------------------- */

@interface SPTexture : NSObject

/// ------------------
/// @name Initializers
/// ------------------

/// Initializes a texture with a certain size (in points) and a block containing Core Graphics commands. 
/// The texture will have the current scale factor of the stage and an RGBA color space.
- (id)initWithWidth:(float)width height:(float)height draw:(SPTextureDrawingBlock)drawingBlock;

/// Initializes a texture with size and color properties, as well as a block containing 
/// Core Graphics commands.
- (id)initWithWidth:(float)width height:(float)height scale:(float)scale 
         colorSpace:(SPColorSpace)colorSpace draw:(SPTextureDrawingBlock)drawingBlock;

/// Initializes a texture with the contents of a file. Recommended formats: png, jpg, pvr.
- (id)initWithContentsOfFile:(NSString *)path;

/// Initializes a texture with the contents of a UIImage.
- (id)initWithContentsOfImage:(UIImage *)image;

/// Initializes a texture with a region (in points) of another texture.
- (id)initWithRegion:(SPRectangle*)region ofTexture:(SPTexture*)texture;

/// Factory method.
+ (SPTexture *)textureWithContentsOfFile:(NSString*)path;

/// Factory method.
+ (SPTexture *)textureWithRegion:(SPRectangle *)region ofTexture:(SPTexture *)texture;

/// Factory method.
+ (SPTexture *)textureWithWidth:(float)width height:(float)height draw:(SPTextureDrawingBlock)drawingBlock;

/// Factory method. Creates an empty (white) texture.
+ (SPTexture *)emptyTexture;

/// -------------
/// @name Methods
/// -------------

/// Convertes texture coordinates in the format required for rendering.
- (void)adjustTextureCoordinates:(const float *)texCoords saveAtTarget:(float *)targetTexCoords 
                     numVertices:(int)numVertices;

/// ----------------
/// @name Properties
/// ----------------

/// The width of the image in points.
@property (nonatomic, readonly) float width;

/// The height of the image in points.
@property (nonatomic, readonly) float height;

/// The OpenGL texture ID.
@property (nonatomic, readonly) uint textureID;

/// Indicates if the alpha values are premultiplied into the RGB values.
@property (nonatomic, readonly) BOOL hasPremultipliedAlpha;

/// The scale factor, which influences `width` and `height` properties.
@property (nonatomic, readonly) float scale;

@end
