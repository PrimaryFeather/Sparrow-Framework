//
//  SPBitmapFont.m
//  Sparrow
//
//  Created by Daniel Sperl on 12.10.09.
//  Copyright 2009 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPBitmapFont.h"
#import "SPBitmapChar.h"
#import "SPTexture.h"
#import "SPRectangle.h"
#import "SPSubTexture.h"
#import "SPDisplayObject.h"
#import "SPSprite.h"
#import "SPImage.h"
#import "SPTextField.h"
#import "SPStage.h"
#import "SPNSExtensions.h"
#import "SPCompiledSprite.h"

#define CHAR_SPACE   32
#define CHAR_TAB      9
#define CHAR_NEWLINE 10

// --- private interface ---------------------------------------------------------------------------

@interface SPBitmapFont ()

- (void)parseFontXml:(NSString*)path;

@end

// --- class implementation ------------------------------------------------------------------------

@implementation SPBitmapFont

@synthesize name = mName;
@synthesize lineHeight = mLineHeight;
@synthesize size = mSize;

- (id)initWithContentsOfFile:(NSString *)path texture:(SPTexture *)texture
{
    if (self = [super init])
    {
        mName = [[NSString alloc] initWithString:@"unknown"];
        mLineHeight = mSize = SP_DEFAULT_FONT_SIZE;
        mFontTexture = [texture retain];
        
        [self parseFontXml:path];
    }
    return self;
}

- (id)initWithContentsOfFile:(NSString *)path
{
    return [self initWithContentsOfFile:path texture:nil];
}

- (id)init
{
    [self release];
    return nil;
}

- (void)parseFontXml:(NSString*)path
{
    SP_CREATE_POOL(pool);
    
    [mChars release];    
    mChars = [[NSMutableDictionary alloc] init];
    
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
                    format:@"could not parse bitmap font xml %@. Error code: %d, domain: %@", 
                           path, xmlParser.parserError.code, xmlParser.parserError.domain];
    
    [xmlParser release];    
}

- (void)parser:(NSXMLParser*)parser didStartElement:(NSString*)elementName 
  namespaceURI:(NSString*)namespaceURI 
 qualifiedName:(NSString*)qName 
    attributes:(NSDictionary*)attributeDict 
{
    if ([elementName isEqualToString:@"char"])
    {
        int charID = [[attributeDict valueForKey:@"id"] intValue];        
        float scale = mFontTexture.scale;
        
        SPRectangle *region = [[SPRectangle alloc] init];
        region.x = [[attributeDict valueForKey:@"x"] floatValue] / scale;
        region.y = [[attributeDict valueForKey:@"y"] floatValue] / scale;
        region.width = [[attributeDict valueForKey:@"width"] floatValue] / scale;
        region.height = [[attributeDict valueForKey:@"height"] floatValue] / scale;
        SPSubTexture *texture = [[SPSubTexture alloc] initWithRegion:region ofTexture:mFontTexture];
        [region release];
        
        float xOffset = [[attributeDict valueForKey:@"xoffset"] floatValue] / scale;
        float yOffset = [[attributeDict valueForKey:@"yoffset"] floatValue] / scale;
        float xAdvance = [[attributeDict valueForKey:@"xadvance"] floatValue] / scale;
        
        SPBitmapChar *bitmapChar = [[SPBitmapChar alloc] initWithID:charID texture:texture
                                                            xOffset:xOffset yOffset:yOffset 
                                                           xAdvance:xAdvance];
        [texture release];
        
        [mChars setObject:bitmapChar forKey:[NSNumber numberWithInt:charID]];
        [bitmapChar release];
    }
    else if ([elementName isEqualToString:@"info"])
    {
        [mName release];
        mName = [[attributeDict valueForKey:@"face"] copy];
        mSize = [[attributeDict valueForKey:@"size"] floatValue];
    }
    else if ([elementName isEqualToString:@"common"])
    {
        mLineHeight = [[attributeDict valueForKey:@"lineHeight"] floatValue];
    }
    else if ([elementName isEqualToString:@"page"])
    {
        int id = [[attributeDict valueForKey:@"id"] intValue];
        if (id != 0) [NSException raise:SP_EXC_FILE_INVALID 
                                 format:@"Bitmap fonts with multiple pages are not supported"];
        if (!mFontTexture)
        {
            NSString *filename = [attributeDict valueForKey:@"file"];
            mFontTexture = [[SPTexture alloc] initWithContentsOfFile:filename]; 
            
            // update sizes, now that we know the scale setting
            mSize /= mFontTexture.scale;
            mLineHeight /= mFontTexture.scale;            
        }
    }
}

- (SPBitmapChar *)charByID:(int)charID
{
    SPBitmapChar *bitmapChar = (SPBitmapChar *)[mChars objectForKey:[NSNumber numberWithInt:charID]];
    return [[bitmapChar copy] autorelease];
}

- (SPDisplayObject *)createDisplayObjectWithWidth:(float)width height:(float)height
                                             text:(NSString *)text fontSize:(float)size color:(uint)color 
                                           hAlign:(SPHAlign)hAlign vAlign:(SPVAlign)vAlign
                                           border:(BOOL)border
{    
    SPSprite *lineContainer = [SPSprite sprite];
    
    if (size == SP_NATIVE_FONT_SIZE) size = mSize;    
    float scale = size / mSize;    
    lineContainer.scaleX = lineContainer.scaleY = scale;        
    float containerWidth = width / scale;
    float containerHeight = height / scale;    
    
    int lastWhiteSpace = -1;
    float currentX = 0;
    SPSprite *currentLine = [SPSprite sprite];
    
    for (int i=0; i<text.length; i++)
    {        
        BOOL lineFull = NO;

        int charID = [text characterAtIndex:i];    
        if (charID == CHAR_NEWLINE)        
        {
            lineFull = YES;
        }            
        else 
        {        
            if (charID == CHAR_SPACE || charID == CHAR_TAB)        
                lastWhiteSpace = i;        
            
            SPBitmapChar *bitmapChar = [self charByID:charID];
            if (!bitmapChar) bitmapChar = [self charByID:CHAR_SPACE];
            
            bitmapChar.x = currentX + bitmapChar.xOffset;
            bitmapChar.y = bitmapChar.yOffset;
            bitmapChar.color = color;
            [currentLine addChild:bitmapChar];
            
            currentX += bitmapChar.xAdvance;
            
            if (currentX > containerWidth)        
            {
                // remove characters and add them again to next line
                int numCharsToRemove = lastWhiteSpace == -1 ? 1 : i - lastWhiteSpace;
                int removeIndex = currentLine.numChildren - numCharsToRemove;
                
                for (int i=0; i<numCharsToRemove; ++i)
                    [currentLine removeChildAtIndex:removeIndex];
                
                if (currentLine.numChildren == 0)
                    break;
                
                SPDisplayObject *lastChar = [currentLine childAtIndex:currentLine.numChildren-1];
                currentX = lastChar.x + lastChar.width;
                
                i -= numCharsToRemove;
                lineFull = YES;                
            }
        }
        
        if (lineFull || i == text.length - 1)
        {
            float nextLineY = currentLine.y + mLineHeight;             
            [lineContainer addChild:currentLine];                        
            
            if (nextLineY + mLineHeight <= containerHeight)
            {
                currentLine = [SPSprite sprite];
                currentLine.y = nextLineY;            
                lastWhiteSpace = -1;
                currentX = 0;
            }
            else
            {
                break;
            }
        }
    }
    
    // hAlign
    if (hAlign != SPHAlignLeft)
    {
        for (SPSprite *line in lineContainer)
        {
            SPDisplayObject *lastChar = [line childAtIndex:line.numChildren-1];
            float lineWidth = lastChar.x + lastChar.width;
            float widthDiff = containerWidth - lineWidth;
            line.x = (int) (hAlign == SPHAlignRight ? widthDiff : widthDiff / 2);
        }
    }
    
    SPSprite *outerContainer = [SPCompiledSprite sprite];
    [outerContainer addChild:lineContainer];    
    
    if (vAlign != SPVAlignTop)
    {
        float contentHeight = lineContainer.numChildren * mLineHeight * scale;
        float heightDiff = height - contentHeight;
        lineContainer.y = (int)(vAlign == SPVAlignBottom ? heightDiff : heightDiff / 2.0f);
    }
    
    if (border)
    {
        SPQuad *topBorder = [SPQuad quadWithWidth:width height:1];
        SPQuad *bottomBorder = [SPQuad quadWithWidth:width height:1];
        SPQuad *leftBorder = [SPQuad quadWithWidth:1 height:height-2];
        SPQuad *rightBorder = [SPQuad quadWithWidth:1 height:height-2];
        
        topBorder.color = bottomBorder.color = leftBorder.color = rightBorder.color = color;
        bottomBorder.y = height - 1;
        leftBorder.y = rightBorder.y = 1;
        rightBorder.x = width - 1;
        
        [outerContainer addChild:topBorder];
        [outerContainer addChild:bottomBorder];
        [outerContainer addChild:leftBorder];
        [outerContainer addChild:rightBorder];        
    }    
    
    return outerContainer;
}

- (void)dealloc
{
    [mFontTexture release];
    [mChars release];
    [mName release];
    [super dealloc];
}

@end
