//
//  SPBitmapFont.h
//  Sparrow
//
//  Created by Daniel Sperl on 12.10.09.
//  Copyright 2009 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>
#import "SPTextField.h"
#import "SPMacros.h"

@class SPTexture;
@class SPDisplayObject;

#ifdef __IPHONE_4_0
@interface SPBitmapFont : NSObject <NSXMLParserDelegate>
#else
@interface SPBitmapFont : NSObject
#endif
{
  @private
    SPTexture *mFontTexture;
    NSMutableDictionary *mChars;
    NSString *mName;
    float mSize;
    float mLineHeight;
}

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) float size;
@property (nonatomic, assign)   float lineHeight;

- (id)initWithContentsOfFile:(NSString *)path texture:(SPTexture *)texture;
- (id)initWithContentsOfFile:(NSString *)path;

- (SPDisplayObject *)createDisplayObjectWithWidth:(float)width height:(float)height
                                             text:(NSString *)text fontSize:(float)size color:(uint)color 
                                           hAlign:(SPHAlign)hAlign vAlign:(SPVAlign)vAlign
                                           border:(BOOL)border;

@end
