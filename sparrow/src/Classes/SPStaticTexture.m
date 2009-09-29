//
//  SPStaticTexture.m
//  Sparrow
//
//  Created by Daniel Sperl on 27.06.09.
//  Copyright 2009 Incognitek. All rights reserved.
//

#import "SPStaticTexture.h"
#import "SPMakros.h"
#import "SPRectangle.h"

#import <UIKit/UIKit.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <QuartzCore/QuartzCore.h>

// --- private interface ---------------------------------------------------------------------------

@interface SPStaticTexture ()

- (id)initWithContentsOfPvrtcFile:(NSString*)path;
- (id)initWithImage:(UIImage*)image;

@end

// --- class implementation ------------------------------------------------------------------------

@implementation SPStaticTexture

@synthesize textureID = mTextureID;
@synthesize repeat = mRepeat;

- (id)initWithData:(const void*)imgData width:(int)width height:(int)height
            format:(SPTextureFormat)format premultipliedAlpha:(BOOL)pma
{
    if (self = [super init])
    {        
        mWidth = width;
        mHeight = height;
        mRepeat = NO;
        mPremultipliedAlpha = pma;
        
        if (imgData)
        {
            GLenum glTexFormat;            
            if (format == SPTextureFormatRGBA) glTexFormat = GL_RGBA;            
            else                               glTexFormat = GL_ALPHA;
            
            glGenTextures(1, &mTextureID);
            glBindTexture(GL_TEXTURE_2D, mTextureID);    
            
            glTexParameteri(GL_TEXTURE_2D, GL_GENERATE_MIPMAP, GL_TRUE);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_NEAREST);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);   
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, mRepeat ? GL_REPEAT : GL_CLAMP_TO_EDGE); 
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, mRepeat ? GL_REPEAT : GL_CLAMP_TO_EDGE); 
           
            glTexImage2D(GL_TEXTURE_2D, 0, glTexFormat, width, height, 0, glTexFormat, 
                         GL_UNSIGNED_BYTE, imgData);
            
            glBindTexture(GL_TEXTURE_2D, 0);
            
        }
        else
        {
            mTextureID = 0;
        }
    }
    return self; 
}

- (id)initWithContentsOfFile:(NSString*)path
{    
    NSString *fullPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: path];
    if (![[NSFileManager defaultManager] fileExistsAtPath:fullPath])
        return nil;
    
    NSString *imgType = [[path pathExtension] lowercaseString];
    if ([imgType isEqualToString:@"pvrtc"])
        return [self initWithContentsOfPvrtcFile:fullPath];            
    else
        return [self initWithImage:[UIImage imageNamed:path]];    
}

- (id)init
{
    return [self initWithData:NULL width:32 height:32 
                       format:SPTextureFormatRGBA premultipliedAlpha:NO];
}

- (id)initWithImage:(UIImage*)image
{  
    if (!image) return nil;
    
    float origWidth = CGImageGetWidth(image.CGImage);
    float origHeight = CGImageGetHeight(image.CGImage);    
    
    // only textures with sides that are powers of 2 are allowed by OpenGL ES.
    // thus, we find the next legal size and draw the texture into a valid image.    
    int legalWidth = 2;    while (legalWidth < origWidth) legalWidth *= 2;
    int legalHeight = 2;   while (legalHeight < origHeight) legalHeight *=2;
        
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    void *imageData = malloc(legalWidth * legalHeight * 4);
    CGContextRef context = CGBitmapContextCreate(imageData, legalWidth, legalHeight,
                                                 8, 4 * legalWidth, colorSpace, 
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextClearRect(context, CGRectMake(0, 0, legalWidth, legalHeight));
    CGContextDrawImage(context, CGRectMake(0, legalHeight-origHeight, origWidth, origHeight), 
                       image.CGImage);

    self = [self initWithData:imageData width:legalWidth height:legalHeight 
                       format:SPTextureFormatRGBA premultipliedAlpha:YES];   
    
    CGContextRelease(context);
    free(imageData);    

    self.clipping = [SPRectangle rectangleWithX:0 y:0 width:origWidth/legalWidth 
                                                     height:origHeight/legalHeight];    
    return self;
}

- (id)initWithContentsOfPvrtcFile:(NSString*)path
{
    [NSException raise:@"NotImplemented" format:@"this is not yet supported"];
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

- (float)width
{
    return mWidth * mClipping.width;
}

- (float)height
{
    return mHeight * mClipping.height;
}

- (void)setRepeat:(BOOL)value
{
    mRepeat = value;
    glBindTexture(GL_TEXTURE_2D, mTextureID);    
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, mRepeat ? GL_REPEAT : GL_CLAMP_TO_EDGE);     
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, mRepeat ? GL_REPEAT : GL_CLAMP_TO_EDGE); 
    glBindTexture(GL_TEXTURE_2D, 0);  
}

+ (SPStaticTexture*)textureWithContentsOfFile:(NSString*)path
{
    return [[[SPStaticTexture alloc] initWithContentsOfFile:path] autorelease];
}

+ (SPStaticTexture*)textureWithData:(const void*)imgData width:(int)width height:(int)height
                             format:(SPTextureFormat)format premultipliedAlpha:(BOOL)pma
{
    return [[[SPStaticTexture alloc] initWithData:imgData width:width height:height 
                                           format:format premultipliedAlpha:pma] autorelease];
}

- (void)dealloc
{     
    glDeleteTextures(1, &mTextureID); 
    [super dealloc];
}

@end
