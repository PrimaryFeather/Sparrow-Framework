//
//  SPNSExtensions.m
//  Sparrow
//
//  Created by Daniel Sperl on 13.05.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <zlib.h>
#import "SPNSExtensions.h"
#import "SPDisplayObject.h"


// --- structs and enums ---------------------------------------------------------------------------

static char encodingTable[64] = {
    'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P',
    'Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f',
    'g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v',
    'w','x','y','z','0','1','2','3','4','5','6','7','8','9','+','/' };


// --- extension implementations -------------------------------------------------------------------

#pragma mark - NSInvocation

@implementation NSInvocation (SPNSExtensions)

+ (NSInvocation*)invocationWithTarget:(id)target selector:(SEL)selector
{
    NSMethodSignature *signature = [target methodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.selector = selector;
    invocation.target = target;
    return invocation;
}

@end

#pragma mark - NSString

@implementation NSString (SPNSExtensions)

- (NSString *)fullPathExtension
{
    NSString *filename = [self lastPathComponent];
    NSRange range = { .location = 1, .length = filename.length - 1 }; // ignore first letter -> '.hidden' files
    uint dotLocation = [filename rangeOfString:@"." options:NSLiteralSearch range:range].location;
    return dotLocation == NSNotFound ? @"" : [filename substringFromIndex:dotLocation + 1];
}

- (NSString *)stringByDeletingFullPathExtension
{
    NSString *base = self;
    while (![base isEqualToString:(base = [base stringByDeletingPathExtension])]) {}
    return base;
}

- (NSString *)stringByAppendingSuffixToFilename:(NSString *)suffix
{
    return [[self stringByDeletingFullPathExtension] stringByAppendingFormat:@"%@.%@", 
            suffix, [self fullPathExtension]];
}

- (NSString *)stringByAppendingScaleSuffixToFilename:(float)scale
{
    NSString *result = self;
    
    if (scale != 1.0f)
    {
        NSString *scaleSuffix = [NSString stringWithFormat:@"@%@x", @(scale)];
        result = [result stringByReplacingOccurrencesOfString:scaleSuffix withString:@""];
        result = [result stringByAppendingSuffixToFilename:scaleSuffix];
    }
    
    return result;
}

- (float)contentScaleFactor
{
    NSString *filename = [self lastPathComponent];
    NSRange atRange = [filename rangeOfString:@"@"];
    if (atRange.length == 0) return 1.0f;
    else
    {
        int factor = [[filename substringWithRange:NSMakeRange(atRange.location+1, 1)] intValue];
        return factor ? factor : 1.0f;
    }
}

@end

#pragma mark - NSBundle

@implementation NSBundle (SPNSExtensions)

- (NSString *)pathForResource:(NSString *)name
{
    if (!name) return nil;
    
    NSString *directory = [name stringByDeletingLastPathComponent];
    NSString *file = [name lastPathComponent];    
    return [self pathForResource:file ofType:nil inDirectory:directory];
}

- (NSString *)pathForResource:(NSString *)name withScaleFactor:(float)factor
{
    if (factor != 1.0f)
    {
        NSString *suffix = [NSString stringWithFormat:@"@%@x", @(factor)];
        NSString *path = [self pathForResource:[name stringByAppendingSuffixToFilename:suffix]];
        if (path) return path;
    }    
    
    return [self pathForResource:name];
}

+ (NSBundle *)appBundle
{
    return [NSBundle bundleForClass:[SPDisplayObject class]];
}

@end

#pragma mark - NSData

@implementation NSData (SPNSExtensions)

#pragma mark Base64

+ (NSData *)dataWithBase64EncodedString:(NSString *)string
{
    return [[NSData alloc] initWithBase64EncodedString:string];
}

- (id)initWithBase64EncodedString:(NSString *)string
{
    NSMutableData *mutableData = nil;
    
    if (string)
    {
        unsigned long ixtext = 0;
        unsigned long lentext = 0;
        unsigned char ch = 0;
        unsigned char inbuf[4] = { 0, 0, 0, 0 };
        unsigned char outbuf[3] = { 0, 0, 0 };
        short i = 0, ixinbuf = 0;
        BOOL flignore = NO;
        BOOL flendtext = NO;
        NSData *base64Data = nil;
        const unsigned char *base64Bytes = nil;
        
        // Convert the string to ASCII data.
        base64Data = [string dataUsingEncoding:NSASCIIStringEncoding];
        base64Bytes = [base64Data bytes];
        mutableData = [NSMutableData dataWithCapacity:[base64Data length]];
        lentext = [base64Data length];
        
        while (YES)
        {
            if (ixtext >= lentext) break;
            ch = base64Bytes[ixtext++];
            flignore = NO;
            
            if ((ch >= 'A') && (ch <= 'Z')) ch = ch - 'A';
            else if ((ch >= 'a') && (ch <= 'z')) ch = ch - 'a' + 26;
            else if ((ch >= '0') && (ch <= '9')) ch = ch - '0' + 52;
            else if (ch == '+') ch = 62;
            else if (ch == '=') flendtext = YES;
            else if (ch == '/') ch = 63;
            else flignore = YES;
            
            if (!flignore)
            {
                short ctcharsinbuf = 3;
                BOOL flbreak = NO;
                
                if (flendtext)
                {
                    if (!ixinbuf) break;
                    if ((ixinbuf == 1) || (ixinbuf == 2)) ctcharsinbuf = 1;
                    else ctcharsinbuf = 2;
                    ixinbuf = 3;
                    flbreak = YES;
                }
                
                inbuf [ixinbuf++] = ch;
                
                if (ixinbuf == 4)
                {
                    ixinbuf = 0;
                    outbuf[0] = (inbuf[0] << 2) | ((inbuf[1] & 0x30) >> 4);
                    outbuf[1] = ((inbuf[1] & 0x0F) << 4) | ((inbuf[2] & 0x3C) >> 2);
                    outbuf[2] = ((inbuf[2] & 0x03) << 6) | (inbuf[3] & 0x3F);
                    
                    for (i=0; i<ctcharsinbuf; ++i)
                        [mutableData appendBytes:&outbuf[i] length:1];
                }
                
                if (flbreak) break;
            }
        }
    }
    
    self = [self initWithData:mutableData];
    return self;
}

- (NSString *)base64Encoding
{
    return [self base64EncodingWithLineLength:0];
}

- (NSString *)base64EncodingWithLineLength:(uint)lineLength
{
    const unsigned char *bytes = [self bytes];
    NSMutableString *result = [NSMutableString stringWithCapacity:[self length]];
    unsigned long ixtext = 0;
    unsigned long lentext = [self length];
    long ctremaining = 0;
    unsigned char inbuf[3], outbuf[4];
    short i = 0;
    short charsonline = 0, ctcopy = 0;
    unsigned long ix = 0;
    
    while (YES)
    {
        ctremaining = lentext - ixtext;
        if (ctremaining <= 0) break;
        
        for(i=0; i<3; ++i)
        {
            ix = ixtext + i;
            if (ix < lentext) inbuf[i] = bytes[ix];
            else inbuf[i] = 0;
        }
        
        outbuf[0] = (inbuf[0] & 0xFC) >> 2;
        outbuf[1] = ((inbuf[0] & 0x03) << 4) | ((inbuf [1] & 0xF0) >> 4);
        outbuf[2] = ((inbuf[1] & 0x0F) << 2) | ((inbuf [2] & 0xC0) >> 6);
        outbuf[3] = inbuf[2] & 0x3F;
        ctcopy = 4;
        
        switch (ctremaining)
        {
            case 1:
                ctcopy = 2;
                break;
            case 2:
                ctcopy = 3;
                break;
        }
        
        for (i=0; i<ctcopy; ++i)
            [result appendFormat:@"%c", encodingTable[outbuf[i]]];
        
        for (i=ctcopy; i<4; ++i)
            [result appendFormat:@"%c",'='];
        
        ixtext += 3;
        charsonline += 4;
        
        if (lineLength > 0)
        {
            if (charsonline >= lineLength)
            {
                charsonline = 0;
                [result appendString:@"\n"];
            }
        }
    }
    
    return result;
}

#pragma mark GZIP

+ (NSData *)dataWithUncompressedContentsOfFile:(NSString *)file
{
    if ([[file pathExtension] isEqualToString:@"gz"])
        return [[NSData dataWithContentsOfFile:file] gzipInflate];
    else
        return [NSData dataWithContentsOfFile:file];
}

- (NSData *)gzipDeflate
{
    if ([self length] == 0) return self;
    
    z_stream strm;
    
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    strm.opaque = Z_NULL;
    strm.total_out = 0;
    strm.next_in=(Bytef *)[self bytes];
    strm.avail_in = [self length];
    
    // Compresssion Levels:
    //   Z_NO_COMPRESSION
    //   Z_BEST_SPEED
    //   Z_BEST_COMPRESSION
    //   Z_DEFAULT_COMPRESSION
    
    if (deflateInit2(&strm, Z_DEFAULT_COMPRESSION, Z_DEFLATED, (15+16), 8, Z_DEFAULT_STRATEGY) != Z_OK)
        return nil;
    
    NSMutableData *compressed = [NSMutableData dataWithLength:16384];  // 16K chunks for expansion
    
    do
    {
        if (strm.total_out >= [compressed length])
            [compressed increaseLengthBy: 16384];
        
        strm.next_out = [compressed mutableBytes] + strm.total_out;
        strm.avail_out = [compressed length] - strm.total_out;
        
        deflate(&strm, Z_FINISH);
    }
    while (strm.avail_out == 0);
    
    deflateEnd(&strm);
    
    [compressed setLength:strm.total_out];
    return [NSData dataWithData:compressed];
}

- (NSData *)gzipInflate
{
    if ([self length] == 0) return self;
    
    unsigned full_length = [self length];
    unsigned half_length = [self length] / 2;
    
    NSMutableData *decompressed = [NSMutableData dataWithLength:full_length + half_length];
    BOOL done = NO;
    int status;
    
    z_stream strm;
    strm.next_in = (Bytef *)[self bytes];
    strm.avail_in = [self length];
    strm.total_out = 0;
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    
    if (inflateInit2(&strm, (15+32)) != Z_OK) return nil;
    while (!done)
    {
        // Make sure we have enough room and reset the lengths.
        if (strm.total_out >= [decompressed length])
            [decompressed increaseLengthBy: half_length];
        strm.next_out = [decompressed mutableBytes] + strm.total_out;
        strm.avail_out = [decompressed length] - strm.total_out;
        
        // Inflate another chunk.
        status = inflate (&strm, Z_SYNC_FLUSH);
        if (status == Z_STREAM_END) done = YES;
        else if (status != Z_OK) break;
    }
    if (inflateEnd (&strm) != Z_OK) return nil;
    
    // Set real length.
    if (done)
    {
        [decompressed setLength: strm.total_out];
        return [NSData dataWithData: decompressed];
    }
    else return nil;
}

@end


