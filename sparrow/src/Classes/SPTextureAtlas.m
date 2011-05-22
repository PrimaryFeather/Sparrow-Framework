//
//  SPTextureAtlas.m
//  Sparrow
//
//  Created by Daniel Sperl on 27.06.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPTextureAtlas.h"
#import "SPMacros.h"
#import "SPTexture.h"
#import "SPSubTexture.h"
#import "SPGLTexture.h"
#import "SPRectangle.h"
#import "SPUtils.h"
#import "SPStage.h"

// --- private interface ---------------------------------------------------------------------------

@interface SPTextureAtlas()

- (void)parseAtlasXml:(NSString*)path;

@end

// --- class implementation ------------------------------------------------------------------------

@implementation SPTextureAtlas

- (id)initWithContentsOfFile:(NSString *)path texture:(SPTexture *)texture
{
    if ((self = [super init]))
    {
        mTextureRegions = [[NSMutableDictionary alloc] init];
        mTextureFrames  = [[NSMutableDictionary alloc] init];
        mAtlasTexture = [texture retain];
        [self parseAtlasXml:path];
    }
    return self;    
}

- (id)initWithContentsOfFile:(NSString *)path
{
    return [self initWithContentsOfFile:path texture:nil];
}

- (id)initWithTexture:(SPTexture *)texture
{
    return [self initWithContentsOfFile:nil texture:(SPTexture *)texture];
}

- (id)init
{
    return [self initWithContentsOfFile:nil texture:nil];
}

- (void)parseAtlasXml:(NSString *)path
{
    if (!path) return;

    float scaleFactor = [SPStage contentScaleFactor];
    mPath = [[SPUtils absolutePathToFile:path withScaleFactor:scaleFactor] retain];    
    if (!mPath) [NSException raise:SP_EXC_FILE_NOT_FOUND format:@"file not found: %@", path];
    
    SP_CREATE_POOL(pool);
    
    NSData *xmlData = [[NSData alloc] initWithContentsOfFile:mPath];
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:xmlData];
    [xmlData release];
    
    xmlParser.delegate = self;    
    BOOL success = [xmlParser parse];
    
    SP_RELEASE_POOL(pool);
    
    if (!success)    
        [NSException raise:SP_EXC_FILE_INVALID 
                    format:@"could not parse texture atlas %@. Error code: %d, domain: %@", 
                           path, xmlParser.parserError.code, xmlParser.parserError.domain];

    [xmlParser release];    
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
                                        namespaceURI:(NSString *)namespaceURI 
                                       qualifiedName:(NSString *)qName 
                                          attributes:(NSDictionary *)attributeDict 
{
    if ([elementName isEqualToString:@"SubTexture"])
    {
        float scale = mAtlasTexture.scale;
        
        NSString *name = [attributeDict objectForKey:@"name"];
        SPRectangle *frame = nil;
        
        float x = [[attributeDict objectForKey:@"x"] floatValue] / scale;
        float y = [[attributeDict objectForKey:@"y"] floatValue] / scale;
        float width = [[attributeDict objectForKey:@"width"] floatValue] / scale;
        float height = [[attributeDict objectForKey:@"height"] floatValue] / scale;
        float frameX = [[attributeDict objectForKey:@"frameX"] floatValue] / scale;
        float frameY = [[attributeDict objectForKey:@"frameY"] floatValue] / scale;
        float frameWidth = [[attributeDict objectForKey:@"frameWidth"] floatValue] / scale;
        float frameHeight = [[attributeDict objectForKey:@"frameHeight"] floatValue] / scale;
        
        if (frameWidth && frameHeight)
            frame = [SPRectangle rectangleWithX:frameX y:frameY width:frameWidth height:frameHeight];
        
        [self addRegion:[SPRectangle rectangleWithX:x y:y width:width height:height] 
               withName:name frame:frame];
    }
    else if ([elementName isEqualToString:@"TextureAtlas"] && !mAtlasTexture)
    {
        // load atlas texture
        NSString *filename = [attributeDict valueForKey:@"imagePath"];        
        NSString *folder = [mPath stringByDeletingLastPathComponent];
        NSString *absolutePath = [folder stringByAppendingPathComponent:filename];
        mAtlasTexture = [[SPTexture alloc] initWithContentsOfFile:absolutePath];
    }
}

- (int)count
{
    return [mTextureRegions count];
}

- (SPTexture *)textureByName:(NSString *)name
{
    SPRectangle *region = [mTextureRegions objectForKey:name];
    if (!region) return nil;    
    
    SPTexture *texture = [SPSubTexture textureWithRegion:region ofTexture:mAtlasTexture];
    texture.frame = [mTextureFrames objectForKey:name];
    return texture;
}

- (NSArray *)texturesStartingWith:(NSString *)name
{
    NSMutableArray *textureNames = [[NSMutableArray alloc] init];
    
    for (NSString *textureName in mTextureRegions)
        if ([textureName rangeOfString:name].location == 0)
            [textureNames addObject:textureName];
    
    // note: when switching to iOS 4, 'localizedStandardCompare:' would be preferable    
    [textureNames sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    NSMutableArray *textures = [NSMutableArray arrayWithCapacity:textureNames.count];
    for (NSString *textureName in textureNames)
        [textures addObject:[self textureByName:textureName]];
    
    [textureNames release];
    return textures;
}

- (void)addRegion:(SPRectangle *)region withName:(NSString *)name
{
    [self addRegion:region withName:name frame:nil];
}

- (void)addRegion:(SPRectangle *)region withName:(NSString *)name frame:(SPRectangle *)frame
{
    [mTextureRegions setObject:region forKey:name];    
    if (frame) [mTextureFrames setObject:frame forKey:name];
}

- (void)removeRegion:(NSString *)name
{
    [mTextureRegions removeObjectForKey:name];
    [mTextureFrames  removeObjectForKey:name];
}

+ (SPTextureAtlas *)atlasWithContentsOfFile:(NSString *)path
{
    return [[[SPTextureAtlas alloc] initWithContentsOfFile:path] autorelease];
}

- (void)dealloc
{
    [mPath release];
    [mAtlasTexture release];
    [mTextureRegions release];
    [mTextureFrames release];
    [super dealloc];
}

@end
