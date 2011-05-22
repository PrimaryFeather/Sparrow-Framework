//
//  SPSprite.h
//  Sparrow
//
//  Created by Daniel Sperl on 21.03.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>
#import "SPDisplayObjectContainer.h"

/** ------------------------------------------------------------------------------------------------

 An SPSprite is the most lightweight, non-abstract container class. 

 Use it as a simple means of grouping objects together in one coordinate system.
 
	SPSprite *sprite = [SPSprite sprite];
	
	// create children
	SPImage *venus = [SPImage imageWithContentsOfFile:@"venus.png"];
	SPImage *mars = [SPImage imageWithContentsOfFile:@"mars.png"];
	
	// move children to some relative positions
	venus.x = 50;
	mars.x = -20;
	
	// add children to the sprite
	[sprite addChild:venus];
	[sprite addChild:mars];
	
	// calculate total width of all children
	float totalWidth = sprite.width;
	
	// rotate the whole group
	sprite.rotation = PI;
 
------------------------------------------------------------------------------------------------- */

@interface SPSprite : SPDisplayObjectContainer 

/// Create a new, empty sprite.
+ (SPSprite*)sprite;

@end
