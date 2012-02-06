//
//  SPBitmapFont.h
//  Sparrow
//
//  Created by Daniel Sperl on 12.10.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>
#import "SPBitmapChar.h"
#import "SPTextField.h"
#import "SPMacros.h"

@class SPTexture;
@class SPDisplayObject;

/** ------------------------------------------------------------------------------------------------

 The SPBitmapFont class parses bitmap font files and arranges the glyphs in the form of a text.
 
 The class parses the XML format as it is used in the AngelCode Bitmap Font Generator. This is what
 the file format looks like:
 
	<font>
	  <info face="BranchingMouse" size="40" />
	  <common lineHeight="40" />
	  <pages>  <!-- currently, only one page is supported -->
	    <page id="0" file="texture.png" />
	  </pages>
	  <chars>
	    <char id="32" x="60" y="29" width="1" height="1" xoffset="0" yoffset="27" xadvance="8" />
	    <char id="33" x="155" y="144" width="9" height="21" xoffset="0" yoffset="6" xadvance="9" />
	  </chars>
	  <kernings> <!-- Kerning is optional -->
	    <kerning first="83" second="83" amount="-4"/>
	  </kernings>
	</font>
  
 _You don't have to use this class directly in most cases. SPTextField contains methods that
 handle bitmap fonts for you._
 
------------------------------------------------------------------------------------------------- */

#ifdef __IPHONE_4_0
@interface SPBitmapFont : NSObject <NSXMLParserDelegate>
#else
@interface SPBitmapFont : NSObject
#endif
{
  @private
    SPTexture *mFontTexture;
    NSString *mName;
    NSString *mPath;
    NSMutableDictionary *mChars;    
    float mSize;
    float mLineHeight;
}

/// ------------------
/// @name Initializers
/// ------------------

/// Initializes a bitmap font by parsing an XML file and uses the specified texture.
- (id)initWithContentsOfFile:(NSString *)path texture:(SPTexture *)texture;

/// Initializes a bitmap font by parsing an XML file and loads the texture that is specified there.
- (id)initWithContentsOfFile:(NSString *)path;

/// -------------
/// @name Methods
/// -------------

/// Returns a single bitmap char with a certain character ID.
- (SPBitmapChar *)charByID:(int)charID;

/// Creates a display object that contains the given text by arranging individual chars.
- (SPDisplayObject *)createDisplayObjectWithWidth:(float)width height:(float)height
                                             text:(NSString *)text fontSize:(float)size color:(uint)color 
                                           hAlign:(SPHAlign)hAlign vAlign:(SPVAlign)vAlign
                                           border:(BOOL)border kerning:(BOOL)kerning;

/// ----------------
/// @name Properties
/// ----------------

/// The name of the font as it was parsed from the font file.
@property (nonatomic, readonly) NSString *name;

/// The native size of the font.
@property (nonatomic, readonly) float size;

/// The height of one line in pixels.
@property (nonatomic, assign)   float lineHeight;

@end
