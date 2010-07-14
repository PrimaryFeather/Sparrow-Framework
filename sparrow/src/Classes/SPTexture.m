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
#import "SPNSExtensions.h"
#import "SPStage.h"

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

// --- private interface ---------------------------------------------------------------------------

@interface SPTexture ()

- (id)initWithContentsOfPvrtcFile:(NSString *)path;
- (id)initWithContentsOfImage:(UIImage *)image;

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
        [NSException raise:SP_EXC_FILE_NOT_FOUND format:@"file %@ not found", fullPath];
    }
    
    NSString *imgType = [[path pathExtension] lowercaseString];
    if ([imgType isEqualToString:@"pvrtc"])
        return [self initWithContentsOfPvrtcFile:fullPath];            
    else
        return [self initWithContentsOfImage:[UIImage imageWithContentsOfFile:fullPath]];        
}

- (id)initWithContentsOfImage:(UIImage *)image
{  
    [self release]; // class factory - we'll return a subclass!
    
    float width  = CGImageGetWidth(image.CGImage);
    float height = CGImageGetHeight(image.CGImage);    
    
    // only textures with sides that are powers of 2 are allowed by OpenGL ES.
    // thus, we find the next legal size and draw the texture into a valid image.    
    int legalWidth  = 2;   while (legalWidth  < width)  legalWidth *= 2;
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
    
    SPGLTexture *glTexture = [[SPGLTexture alloc] initWithData:imageData 
        width:legalWidth height:legalHeight format:SPTextureFormatRGBA premultipliedAlpha:YES];    
    
    if ([image respondsToSelector:@selector(scale)])
        glTexture.scale = [image scale];
    
    CGContextRelease(context);
    free(imageData);    
    
    if (legalWidth == width && legalHeight == height)
    {
        return glTexture;
    }        
    else 
    {
        float scale = glTexture.scale;
        SPRectangle *region = [SPRectangle rectangleWithX:0 y:0 width:width/scale height:height/scale];
        SPSubTexture *subTexture = [[SPSubTexture alloc] initWithRegion:region ofTexture:glTexture];
        [glTexture release];
        return subTexture;
    }
}

- (id)initWithContentsOfPvrtcFile:(NSString*)path
{
    [self release];
    [NSException raise:@"NotImplemented" format:@"PVRTC images are not yet supported"];    
    return nil;   
}

+ (SPTexture *)emptyTexture
{
    return [[[SPGLTexture alloc] init] autorelease];
}

+ (SPTexture *)textureWithContentsOfFile:(NSString *)path
{
    return [[[SPTexture alloc] initWithContentsOfFile:path] autorelease];
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
