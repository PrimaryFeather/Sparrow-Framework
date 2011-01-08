//
//  SPTextureAtlas.h
//  Sparrow
//
//  Created by Daniel Sperl on 27.06.09.
//  Copyright 2009 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>

@class SPTexture;
@class SPRectangle;

/** ------------------------------------------------------------------------------------------------

 A texture atlas is a collection of many smaller textures in one big image. The class
 `SPTextureAtlas` is used to access textures from such an atlas.
 
 Using a texture atlas for your textures has two main advantages:
 
 * In OpenGL, there’s always one texture active at a given moment. Whenever you change the active 
   texture, a "texture-switch" has to be executed, and that switch takes time.
 * To use a texture in OpenGL, its height and width must each be a power of 2. Sparrow hides this 
   limitation from you, but you will nevertheless use more memory if you do not follow that rule.
 
 By using a texture atlas, you avoid both texture switches and the power-of-two limitation. All 
 textures are within one big "super-texture", and Sparrow takes care that the correct part of this 
 texture is displayed.
 
 There are several ways to create a texture atlas. One is to use the atlas generator script that
 is provided with Sparrow. Here is a sample on how to use it:
 
	# creates "atlas.xml" and "atlas.png" from the	provided images 
	./generate_atlas.rb input/*.png output/atlas.xml
 
 The atlas generator can be found in the 'utils' directory in the Sparrow package. A README file
 shows you how to install and use it. If you want to have more control over your atlas, you will
 find great alternative tools on the Internet (e.g. "Texture Packer").
 
 Whatever tool you use, Sparrow expects the following file format:

	<TextureAtlas imagePath='atlas.png'>
	  <SubTexture name='texture_1' x='0'  y='0' height='50' width='50'/>
	  <SubTexture name='texture_2' x='50' y='0' height='30' width='20'/> 
	</TextureAtlas>
 
------------------------------------------------------------------------------------------------- */

#ifdef __IPHONE_4_0
@interface SPTextureAtlas : NSObject <NSXMLParserDelegate>
#else
@interface SPTextureAtlas : NSObject
#endif
{
  @private
    SPTexture *mAtlasTexture;
    NSMutableDictionary *mTextureRegions;
}

/// ------------------
/// @name Initializers
/// ------------------

/// Initializes a texture atlas from an XML file and a custom texture. _Designated Initializer_.
- (id)initWithContentsOfFile:(NSString *)path texture:(SPTexture *)texture;

/// Initializes a texture atlas from an XML file, loading the texture that is specified in the XML.
- (id)initWithContentsOfFile:(NSString *)path;

/// Initializes a teture atlas from a texture. Add the regions manually with `addName:forRegion:`.
- (id)initWithTexture:(SPTexture *)texture;

/// Factory Method.
+ (SPTextureAtlas *)atlasWithContentsOfFile:(NSString *)path;

/// -------------
/// @name Methods
/// -------------

/// Retrieve a subtexture by name. Returns `nil` if it is not found.
- (SPTexture *)textureByName:(NSString *)name;

/// Returns all textures that start with a certain string, sorted alphabetically
/// (especially useful for `SPMovieClip`).
- (NSArray *)texturesStartingWith:(NSString *)name;

/// Creates a region for a subtexture and gives it a name.
- (void)addRegion:(SPRectangle *)region withName:(NSString *)name;

/// Removes a region with a certain name.
- (void)removeRegion:(NSString *)name;

/// ----------------
/// @name Properties
/// ----------------

/// The number of available subtextures.
@property (nonatomic, readonly) int count;

@end
