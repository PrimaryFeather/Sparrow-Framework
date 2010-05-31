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
#import "SPRectangle.h"
#import "SPGLTexture.h"
#import "SPSubTexture.h"

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

// --- private interface ---------------------------------------------------------------------------

@interface SPTexture ()

+ (id)textureWithContentsOfPvrtcFile:(NSString*)path;
+ (id)textureWithContentsOfImage:(UIImage*)image;

@end

// --- class implementation ------------------------------------------------------------------------

@implementation SPTexture

@synthesize hasPremultipliedAlpha = mPremultipliedAlpha;

- (id)init
{    
    #ifdef DEBUG
    if ([[self class] isEqual:[SPTexture class]]) 
    {
        [NSException raise:SP_EXC_ABSTRACT_CLASS 
                    format:@"Attempting to instantiate abstract class SPTexture. " \
                           @"Use factory methods instead."];
        [self release];
        return nil;
    }
    #endif
    
    return [super init];
}

+ (SPTexture *)emptyTexture
{
    return [[[SPGLTexture alloc] init] autorelease];
}

+ (SPTexture *)textureWithContentsOfFile:(NSString*)path
{    
    NSString *fullPath = [[NSBundle mainBundle] pathForResource:path ofType:nil];
    if (![[NSFileManager defaultManager] fileExistsAtPath:fullPath])
        [NSException raise:SP_EXC_FILE_NOT_FOUND format:@"file %@ not found", fullPath];
    
    NSString *imgType = [[path pathExtension] lowercaseString];
    if ([imgType isEqualToString:@"pvrtc"])
        return [self textureWithContentsOfPvrtcFile:fullPath];            
    else
        return [self textureWithContentsOfImage:[UIImage imageNamed:path]];    
}

+ (id)textureWithContentsOfImage:(UIImage*)image
{  
    float width = CGImageGetWidth(image.CGImage);
    float height = CGImageGetHeight(image.CGImage);    
    
    // only textures with sides that are powers of 2 are allowed by OpenGL ES.
    // thus, we find the next legal size and draw the texture into a valid image.    
    int legalWidth = 2;    while (legalWidth < width) legalWidth *= 2;
    int legalHeight = 2;   while (legalHeight < height) legalHeight *=2;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    void *imageData = malloc(legalWidth * legalHeight * 4);
    CGContextRef context = CGBitmapContextCreate(imageData, legalWidth, legalHeight,
                                                 8, 4 * legalWidth, colorSpace, 
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextClearRect(context, CGRectMake(0, 0, legalWidth, legalHeight));
    CGContextDrawImage(context, CGRectMake(0, legalHeight-height, width, height), 
                       image.CGImage);
    
    SPGLTexture *glTexture = [SPGLTexture textureWithData:imageData 
        width:legalWidth height:legalHeight format:SPTextureFormatRGBA premultipliedAlpha:YES];    
    
    CGContextRelease(context);
    free(imageData);    
    
    if (legalWidth == width && legalHeight == height)
        return glTexture;
    else 
    {
        SPRectangle *region = [SPRectangle rectangleWithX:0 y:0 width:width height:height];
        return [SPSubTexture textureWithRegion:region ofTexture:glTexture];
    }
}

+ (id)textureWithContentsOfPvrtcFile:(NSString*)path
{
    [NSException raise:@"NotImplemented" format:@"PVRTC images are not yet supported"];
    return nil;
    
    // todo: find out how to get width, height and compression type from pvrtc-file --
    //       this is required to complete this method.    
    
    /*
     
     NSString *fullPath = [[NSBundle mainBundle] pathForResource:path ofType:nil];
     NSData *texData = [[NSData alloc] initWithContentsOfFile:fullPath];
     
     // This assumes that source PVRTC image is 4 bits per pixel and RGB not RGBA
     // If you use the default settings in texturetool, e.g.:
     //
     //      texturetool -e PVRTC -o texture.pvrtc texture.png
     //
     // then this code should work fine for you.
     glCompressedTexImage2D(GL_TEXTURE_2D, 0, GL_COMPRESSED_RGB_PVRTC_4BPPV1_IMG, 512, 512, 0, 
     [texData length], [texData bytes]);
     
     */    
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

@end
