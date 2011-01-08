//
//  SPTextureAtlas.m
//  Sparrow
//
//  Created by Daniel Sperl on 27.06.09.
//  Copyright 2009 Incognitek. All rights reserved.
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
#import "SPNSExtensions.h"
#import "SPStage.h"

// --- private interface ---------------------------------------------------------------------------

@interface SPTextureAtlas()

- (void)parseAtlasXml:(NSString*)path;

@end

// --- class implementation ------------------------------------------------------------------------

@implementation SPTextureAtlas

- (id)initWithContentsOfFile:(NSString *)path texture:(SPTexture *)texture
{
    if (self = [super init])
    {
        mTextureRegions = [[NSMutableDictionary alloc] init];
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
    SP_CREATE_POOL(pool);
    
    if (!path) return;
    
    float scale = [SPStage contentScaleFactor];
    NSString *fullPath = [[NSBundle mainBundle] pathForResource:path withScaleFactor:scale];
    NSURL *xmlUrl = [NSURL fileURLWithPath:fullPath];
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:xmlUrl];
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
        
        NSString *name = [attributeDict valueForKey:@"name"];
        float x = [[attributeDict valueForKey:@"x"] floatValue] / scale;
        float y = [[attributeDict valueForKey:@"y"] floatValue] / scale;
        float width = [[attributeDict valueForKey:@"width"] floatValue] / scale;
        float height = [[attributeDict valueForKey:@"height"] floatValue] / scale;
        
        [self addRegion:[SPRectangle rectangleWithX:x y:y width:width height:height] withName:name];
    }
    else if ([elementName isEqualToString:@"TextureAtlas"] && !mAtlasTexture)
    {
        // load atlas texture
        NSString *imagePath = [attributeDict valueForKey:@"imagePath"];        
        mAtlasTexture = [[SPTexture alloc] initWithContentsOfFile:imagePath];
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
    return [SPSubTexture textureWithRegion:region ofTexture:mAtlasTexture];    
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
    [mTextureRegions setObject:region forKey:name];
}

- (void)removeRegion:(NSString *)name
{
    [mTextureRegions removeObjectForKey:name];
}

+ (SPTextureAtlas *)atlasWithContentsOfFile:(NSString *)path
{
    return [[[SPTextureAtlas alloc] initWithContentsOfFile:path] autorelease];
}

- (void)dealloc
{
    [mAtlasTexture release];
    [mTextureRegions release];
    [super dealloc];
}

@end
