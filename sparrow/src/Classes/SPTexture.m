//
//  SPTexture.m
//  Sparrow
//
//  Created by Daniel Sperl on 19.06.09.
//  Copyright 2009 Incognitek. All rights reserved.
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

// --- PVRTC structs & enums -----------------------------------------------------------------------

typedef struct
{
	uint headerSize;          // size of the structure
	uint height;              // height of surface to be created
	uint width;               // width of input surface 
	uint numMipmaps;          // number of mip-map levels requested
	uint pfFlags;             // pixel format flags
	uint textureDataSize;     // total size in bytes
	uint bitCount;            // number of bits per pixel 
	uint rBitMask;            // mask for red bit
	uint gBitMask;            // mask for green bits
	uint bBitMask;            // mask for blue bits
	uint alphaBitMask;        // mask for alpha channel
	uint pvr;                 // magic number identifying pvr file
	uint numSurfs;            // number of surfaces present in the pvr
} PVRTextureHeader;

enum PVRPixelType
{
	OGL_RGBA_4444 = 0x10,
	OGL_RGBA_5551,
	OGL_RGBA_8888,
	OGL_RGB_565,
	OGL_RGB_555,
	OGL_RGB_888,
	OGL_I_8,
	OGL_AI_88,
	OGL_PVRTC2,
	OGL_PVRTC4
};
    
// --- private interface ---------------------------------------------------------------------------

@interface SPTexture ()

- (id)initWithContentsOfPvrFile:(NSString *)path;

@end

// --- class implementation ------------------------------------------------------------------------

@implementation SPTexture

- (id)init
{    
    if ([self isMemberOfClass:[SPTexture class]]) 
    {
        [self release];
        [NSException raise:SP_EXC_ABSTRACT_CLASS 
                    format:@"Attempting to initialize abstract class SPTexture."];        
        return nil;
    }
    
    return [super init];
}

- (id)initWithContentsOfFile:(NSString *)path
{
    float contentScaleFactor = [SPStage contentScaleFactor];
    
    NSString *fullPath = [path isAbsolutePath] ? 
        path : [[NSBundle mainBundle] pathForResource:path withScaleFactor:contentScaleFactor];

    if (![[NSFileManager defaultManager] fileExistsAtPath:fullPath])
    {
        [self release];
        [NSException raise:SP_EXC_FILE_NOT_FOUND format:@"file '%@' not found", path];
    }
    
    NSString *imgType = [[path pathExtension] lowercaseString];
    if ([imgType rangeOfString:@"pvr"].location == 0)
        return [self initWithContentsOfPvrFile:fullPath];            
    else
        return [self initWithContentsOfImage:[UIImage imageWithContentsOfFile:fullPath]];        
}

- (id)initWithWidth:(float)width height:(float)height draw:(SPTextureDrawingBlock)drawingBlock
{
    return [self initWithWidth:width height:height scale:[SPStage contentScaleFactor]
                    colorSpace:SPColorSpaceRGBA draw:drawingBlock];
}

- (id)initWithWidth:(float)width height:(float)height scale:(float)scale 
         colorSpace:(SPColorSpace)colorSpace draw:(SPTextureDrawingBlock)drawingBlock
{
    [self release]; // class factory - we'll return a subclass!

    // only textures with sides that are powers of 2 are allowed by OpenGL ES. 
    int legalWidth  = [SPUtils nextPowerOfTwo:width  * scale];
    int legalHeight = [SPUtils nextPowerOfTwo:height * scale];
    
    SPTextureFormat textureFormat;
    CGColorSpaceRef cgColorSpace;
    CGBitmapInfo bitmapInfo;
    BOOL premultipliedAlpha;
    int bytesPerPixel;
    
    if (colorSpace == SPColorSpaceRGBA)
    {
        bytesPerPixel = 4;
        textureFormat = SPTextureFormatRGBA;
        cgColorSpace = CGColorSpaceCreateDeviceRGB();
        bitmapInfo = kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast;
        premultipliedAlpha = YES;
    }
    else
    {
        bytesPerPixel = 1;
        textureFormat = SPTextureFormatAlpha;
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
    
    SPTextureProperties properties = {    
        .format = textureFormat,
        .width = legalWidth,
        .height = legalHeight,
        .generateMipmaps = YES,
        .premultipliedAlpha = premultipliedAlpha
    };
    
    SPGLTexture *glTexture = [[SPGLTexture alloc] initWithData:imageData properties:properties];    
    glTexture.scale = scale;
    
    CGContextRelease(context);
    free(imageData);    
    
    SPRectangle *region = [SPRectangle rectangleWithX:0 y:0 width:width height:height];
    SPTexture *subTexture = [[SPTexture alloc] initWithRegion:region ofTexture:glTexture];
    [glTexture release];
    return subTexture;
}

- (id)initWithContentsOfImage:(UIImage *)image
{  
    float scale = [image respondsToSelector:@selector(scale)] ? [image scale] : 1.0f;
    
    return [self initWithWidth:image.size.width height:image.size.height
                         scale:scale colorSpace:SPColorSpaceRGBA draw:^(CGContextRef context)
            {
                [image drawAtPoint:CGPointMake(0, 0)];
            }];
}

- (id)initWithContentsOfPvrFile:(NSString*)path
{
    [self release]; // class factory - we'll return a subclass!

    NSData *fileData = [[NSData alloc] initWithContentsOfFile:path];
    PVRTextureHeader *header = (PVRTextureHeader *)[fileData bytes];    
    bool hasAlpha = header->alphaBitMask ? YES : NO;
    
    SPTextureProperties properties = {
        .width = header->width,
        .height = header->height,
        .numMipmaps = header->numMipmaps,
        .premultipliedAlpha = NO
    };
    
    switch (header->pfFlags & 0xff)
    {
        case OGL_RGB_565:
            properties.format = SPTextureFormat565;
            break;
        case OGL_RGBA_5551:
            properties.format = SPTextureFormat5551;
            break;
        case OGL_RGBA_4444:
            properties.format = SPTextureFormat4444;
            break;            
        case OGL_PVRTC2:
            properties.format = hasAlpha ? SPTextureFormatPvrtcRGBA2 : SPTextureFormatPvrtcRGB2;
            break;
        case OGL_PVRTC4:
            properties.format = hasAlpha ? SPTextureFormatPvrtcRGBA4 : SPTextureFormatPvrtcRGB4;
            break;
        default: 
            [fileData release];
            [NSException raise:SP_EXC_INVALID_OPERATION format:@"Unsupported PRV image format"];
            return nil;
    }
    
    void *imageData = (unsigned char *)header + header->headerSize;

    SPGLTexture *glTexture = [[SPGLTexture alloc] initWithData:imageData properties:properties];
    [fileData release];
    
    NSString *baseFilename = [[path lastPathComponent] stringByDeletingPathExtension];
    if ([baseFilename rangeOfString:@"@2x"].location == baseFilename.length - 3)
        glTexture.scale = 2.0f;
    
    return glTexture;
}

- (id)initWithRegion:(SPRectangle*)region ofTexture:(SPTexture*)texture
{
    [self release]; // class factory - we'll return a subclass!
    
    if (region.x == 0.0f && region.y == 0.0f && 
        region.width == texture.width && region.height == texture.height)
    {
        return [texture retain];
    }
    else
    {
        return [[SPSubTexture alloc] initWithRegion:region ofTexture:texture];
    }
}

+ (SPTexture *)emptyTexture
{
    return [[[SPGLTexture alloc] init] autorelease];
}

+ (SPTexture *)textureWithContentsOfFile:(NSString *)path
{
    return [[[SPTexture alloc] initWithContentsOfFile:path] autorelease];
}

+ (SPTexture *)textureWithRegion:(SPRectangle *)region ofTexture:(SPTexture *)texture
{
    return [[[SPTexture alloc] initWithRegion:region ofTexture:texture] autorelease];
}

+ (SPTexture *)textureWithWidth:(float)width height:(float)height draw:(SPTextureDrawingBlock)drawingBlock
{
    return [[[SPTexture alloc] initWithWidth:width height:height draw:drawingBlock] autorelease];
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

- (BOOL)hasPremultipliedAlpha
{
    [NSException raise:SP_EXC_ABSTRACT_METHOD format:@"Override this method in subclasses."];
    return NO;
}

- (float)scale
{
    [NSException raise:SP_EXC_ABSTRACT_METHOD format:@"Override this method in subclasses."];
    return 1.0f;
}

@end
