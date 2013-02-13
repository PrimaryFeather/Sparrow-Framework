//
//  SPTexture.m
//  Sparrow
//
//  Created by Daniel Sperl on 19.06.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPTexture.h"
#import "SPMacros.h"
#import "SPUtils.h"
#import "SPRectangle.h"
#import "SPGLTexture.h"
#import "SPSubTexture.h"
#import "SPNSExtensions.h"
#import "SPStage.h"
#import "SparrowClass.h"

// --- class implementation ------------------------------------------------------------------------

@implementation SPTexture

- (id)init
{    
    if ([self isMemberOfClass:[SPTexture class]]) 
    {
        return [self initWithWidth:32 height:32];
    }
    
    return [super init];
}

- (id)initWithContentsOfFile:(NSString *)path
{
    return [self initWithContentsOfFile:path generateMipmaps:NO];
}

- (id)initWithContentsOfFile:(NSString *)path generateMipmaps:(BOOL)mipmaps
{
    float contentScaleFactor = Sparrow.contentScaleFactor;
    NSString *fullPath = [SPUtils absolutePathToFile:path withScaleFactor:contentScaleFactor];
    
    if (!fullPath)
        [NSException raise:SP_EXC_FILE_NOT_FOUND format:@"file '%@' not found", path];
    
    NSError *error = NULL;
    NSData *data = [NSData dataWithUncompressedContentsOfFile:fullPath];
    NSDictionary *options = @{ GLKTextureLoaderGenerateMipmaps: @(mipmaps) };
    GLKTextureInfo *info = [GLKTextureLoader textureWithContentsOfData:data
                                                               options:options error:&error];
    
    if (!info)
    {
        [NSException raise:SP_EXC_FILE_INVALID
                    format:@"Error loading texture: %@", [error localizedDescription]];
        return nil;
    }
    
    return [[SPGLTexture alloc] initWithTextureInfo:info scale:[fullPath contentScaleFactor]];
}

/// Initializes an empty texture with a certain size (in points).
- (id)initWithWidth:(float)width height:(float)height
{
    return [self initWithWidth:width height:height draw:NULL];
}

- (id)initWithWidth:(float)width height:(float)height draw:(SPTextureDrawingBlock)drawingBlock
{
    return [self initWithWidth:width height:height generateMipmaps:NO draw:drawingBlock];
}

- (id)initWithWidth:(float)width height:(float)height generateMipmaps:(BOOL)mipmaps
               draw:(SPTextureDrawingBlock)drawingBlock
{
    return [self initWithWidth:width height:height generateMipmaps:mipmaps
                    colorSpace:SPColorSpaceRGBA draw:drawingBlock];
}

- (id)initWithWidth:(float)width height:(float)height generateMipmaps:(BOOL)mipmaps
         colorSpace:(SPColorSpace)colorSpace draw:(SPTextureDrawingBlock)drawingBlock
{
    return [self initWithWidth:width height:height generateMipmaps:mipmaps
                    colorSpace:colorSpace scale:Sparrow.contentScaleFactor draw:drawingBlock];
}

- (id)initWithWidth:(float)width height:(float)height generateMipmaps:(BOOL)mipmaps
         colorSpace:(SPColorSpace)colorSpace scale:(float)scale
               draw:(SPTextureDrawingBlock)drawingBlock
{
    // only textures with sides that are powers of 2 are allowed by OpenGL ES.
    int legalWidth  = [SPUtils nextPowerOfTwo:width  * scale];
    int legalHeight = [SPUtils nextPowerOfTwo:height * scale];
    
    CGColorSpaceRef cgColorSpace;
    CGBitmapInfo bitmapInfo;
    BOOL premultipliedAlpha;
    int bytesPerPixel;
    
    if (colorSpace == SPColorSpaceRGBA)
    {
        bytesPerPixel = 4;
        cgColorSpace = CGColorSpaceCreateDeviceRGB();
        bitmapInfo = kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast;
        premultipliedAlpha = YES;
    }
    else
    {
        bytesPerPixel = 1;
        cgColorSpace = CGColorSpaceCreateDeviceGray();
        bitmapInfo = kCGImageAlphaNone;
        premultipliedAlpha = NO;
    }
    
    void *imageData = calloc(legalWidth * legalHeight * bytesPerPixel, 1);
    CGContextRef context = CGBitmapContextCreate(imageData, legalWidth, legalHeight, 8, 
                                                 bytesPerPixel * legalWidth, cgColorSpace, 
                                                 bitmapInfo);
    CGColorSpaceRelease(cgColorSpace);
    
    // UIKit referential is upside down - we flip it and apply the scale factor
    CGContextTranslateCTM(context, 0.0f, legalHeight);
	CGContextScaleCTM(context, scale, -scale);
   
    if (drawingBlock)
    {
        UIGraphicsPushContext(context);
        drawingBlock(context);
        UIGraphicsPopContext();        
    }
    
    SPGLTexture *glTexture = [[SPGLTexture alloc] initWithData:imageData
                                                         width:legalWidth
                                                        height:legalHeight
                                               generateMipmaps:mipmaps
                                                    colorSpace:colorSpace
                                                         scale:scale
                                            premultipliedAlpha:premultipliedAlpha];
    
    CGContextRelease(context);
    free(imageData);
    
    SPRectangle *region = [SPRectangle rectangleWithX:0 y:0 width:width height:height];
    return [[SPTexture alloc] initWithRegion:region ofTexture:glTexture];
}

- (id)initWithContentsOfImage:(UIImage *)image
{
    return [self initWithContentsOfImage:image generateMipmaps:NO];
}

- (id)initWithContentsOfImage:(UIImage *)image generateMipmaps:(BOOL)mipmaps
{
    return [self initWithWidth:image.size.width height:image.size.height generateMipmaps:mipmaps
                    colorSpace:SPColorSpaceRGBA scale:image.scale draw:^(CGContextRef context)
            {
                [image drawAtPoint:CGPointMake(0, 0)];
            }];
}

- (id)initWithRegion:(SPRectangle*)region ofTexture:(SPTexture*)texture
{
    return [self initWithRegion:region frame:nil ofTexture:texture];
}

- (id)initWithRegion:(SPRectangle*)region frame:(SPRectangle *)frame ofTexture:(SPTexture*)texture
{
    if (frame || region.x != 0.0f || region.width  != texture.width
              || region.y != 0.0f || region.height != texture.height)
    {
        return [[SPSubTexture alloc] initWithRegion:region frame:frame ofTexture:texture];
    }
    else
    {
        return texture;
    }
}

+ (id)textureWithContentsOfFile:(NSString *)path
{
    return [[self alloc] initWithContentsOfFile:path];
}

+ (id)textureWithContentsOfFile:(NSString*)path generateMipmaps:(BOOL)mipmaps
{
    return [[self alloc] initWithContentsOfFile:path generateMipmaps:mipmaps];
}

+ (id)textureWithRegion:(SPRectangle *)region ofTexture:(SPTexture *)texture
{
    return [[self alloc] initWithRegion:region ofTexture:texture];
}

+ (id)textureWithWidth:(float)width height:(float)height draw:(SPTextureDrawingBlock)drawingBlock
{
    return [[self alloc] initWithWidth:width height:height draw:drawingBlock];
}

- (void)adjustTextureCoordinates:(const float *)texCoords saveAtTarget:(float *)targetTexCoords 
                     numVertices:(int)numVertices
{
    memcpy(targetTexCoords, texCoords, numVertices * 2 * sizeof(float));
}

- (float)width
{
    [NSException raise:SP_EXC_ABSTRACT_METHOD format:@"Override this method in subclasses."];
    return 0;
}

- (float)height
{
    [NSException raise:SP_EXC_ABSTRACT_METHOD format:@"Override this method in subclasses."];
    return 0;
}

- (uint)textureID
{
    [NSException raise:SP_EXC_ABSTRACT_METHOD format:@"Override this method in subclasses."];
    return 0;    
}

- (void)setRepeat:(BOOL)value
{
    [NSException raise:SP_EXC_ABSTRACT_METHOD format:@"Override this method in subclasses."];    
}

- (BOOL)repeat
{
    [NSException raise:SP_EXC_ABSTRACT_METHOD format:@"Override this method in subclasses."];
    return NO;
}

- (SPTextureFilter)filter
{
    [NSException raise:SP_EXC_ABSTRACT_METHOD format:@"Override this method in subclasses."];
    return SPTextureFilterBilinear;
}

- (void)setFilter:(SPTextureFilter)filter
{
    [NSException raise:SP_EXC_ABSTRACT_METHOD format:@"Override this method in subclasses."];
}

- (BOOL)premultipliedAlpha
{
    return NO;
}

- (float)scale
{
    return 1.0f;
}

- (SPRectangle *)frame
{
    return nil;
}

#pragma mark - Asynchronous Texture Loading

+ (void)loadTextureFromFile:(NSString *)path onComplete:(SPTextureLoadingBlock)callback
{
    return [self loadTextureFromFile:path generateMipmaps:NO onComplete:callback];
}

+ (void)loadTextureFromFile:(NSString *)path generateMipmaps:(BOOL)mipmaps
                 onComplete:(SPTextureLoadingBlock)callback
{
    float contentScaleFactor = Sparrow.contentScaleFactor;
    NSString *fullPath = [SPUtils absolutePathToFile:path withScaleFactor:contentScaleFactor];
    float actualScaleFactor = [fullPath contentScaleFactor];
    
    if (!fullPath)
        [NSException raise:SP_EXC_FILE_NOT_FOUND format:@"file '%@' not found", path];
    
    NSDictionary *options = @{ GLKTextureLoaderGenerateMipmaps: @(mipmaps) };
    EAGLSharegroup *sharegroup = Sparrow.currentController.context.sharegroup;
    GLKTextureLoader *loader = [[GLKTextureLoader alloc] initWithSharegroup:sharegroup];

    [loader textureWithContentsOfFile:fullPath options:options queue:NULL
                    completionHandler:^(GLKTextureInfo *info, NSError *outError)
     {
         SPTexture *texture = nil;
         
         if (!outError)
             texture = [[SPGLTexture alloc] initWithTextureInfo:info scale:actualScaleFactor];
         
         callback(texture, outError);
     }];
}

+ (void)loadTextureFromURL:(NSURL *)url onComplete:(SPTextureLoadingBlock)callback
{
    return [self loadTextureFromURL:url generateMipmaps:NO onComplete:callback];
}

+ (void)loadTextureFromURL:(NSURL *)url generateMipmaps:(BOOL)mipmaps
                onComplete:(SPTextureLoadingBlock)callback
{
    float scale = [[url path] contentScaleFactor];
    return [self loadTextureFromURL:url generateMipmaps:mipmaps scale:scale onComplete:callback];
}

+ (void)loadTextureFromURL:(NSURL *)url generateMipmaps:(BOOL)mipmaps scale:(float)scale
                onComplete:(SPTextureLoadingBlock)callback
{
    NSDictionary *options = @{ GLKTextureLoaderGenerateMipmaps: @(mipmaps) };
    EAGLSharegroup *sharegroup = Sparrow.currentController.context.sharegroup;
    GLKTextureLoader *loader = [[GLKTextureLoader alloc] initWithSharegroup:sharegroup];
    
    [loader textureWithContentsOfURL:url options:options queue:NULL
                   completionHandler:^(GLKTextureInfo *info, NSError *outError)
     {
         SPTexture *texture = nil;
         
         if (!outError)
             texture = [[SPGLTexture alloc] initWithTextureInfo:info scale:scale];
         
         callback(texture, outError);
     }];
}

+ (void)loadTextureFromSuffixedURL:(NSURL *)url onComplete:(SPTextureLoadingBlock)callback
{
    return [self loadTextureFromSuffixedURL:url generateMipmaps:NO onComplete:callback];
}

+ (void)loadTextureFromSuffixedURL:(NSURL *)url generateMipmaps:(BOOL)mipmaps
                        onComplete:(SPTextureLoadingBlock)callback
{
    float scale = Sparrow.contentScaleFactor;
    NSString *suffixedString = [[url absoluteString] stringByAppendingScaleSuffixToFilename:scale];
    NSURL *suffixedURL = [NSURL URLWithString:suffixedString];
    return [self loadTextureFromURL:suffixedURL generateMipmaps:mipmaps scale:scale
                         onComplete:callback];
}

@end
