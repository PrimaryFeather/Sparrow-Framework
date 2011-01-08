//
//  SPCompiledContainer.h
//  Sparrow
//
//  Created by Daniel Sperl on 15.07.10.
//  Copyright 2010 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>
#import "SPSprite.h"

/** ------------------------------------------------------------------------------------------------

 An SPCompiledSprite allows you to optimize the rendering of static parts of your display list.
 
 It analyzes the tree of children attached to it and optimizes the OpenGL rendering calls in a 
 way that makes rendering them extremely fast. The downside is that you will no longe see any 
 changes in the properties of the childs (position, rotation, alpha, etc.). To update the object
 after changes have happened, simply call `compile` again.
 
 With the exception of this peculiarity, a compiled sprite can be use just like any other sprite.
 
	SPCompiledSprite *sprite = [SPCompiledSprite sprite];
	[sprite addChild:object1];
	[sprite addChild:object2];
	
	[sprite compile]; // this call is optional, it will be done on rendering automatically.
  
------------------------------------------------------------------------------------------------- */

@interface SPCompiledSprite : SPSprite
{
  @private
    NSArray *mTextureSwitches;    
    NSMutableData *mColorData;
    uint *mCurrentColors;
    BOOL mAlphaChanged;
    
    uint mIndexBuffer;
    uint mVertexBuffer;
    uint mColorBuffer;
    uint mTexCoordBuffer;
}

/// -------------
/// @name Methods
/// -------------

/// Compiles the children of the sprite to optimize rendering. After compilation, no changes in
/// the children will show up. Call the method again to make changes visible.
/// 
/// @return Returns `YES` if compilation was successful. On error, it will `NSLog` the problem.
- (BOOL)compile;

/// Factory method.
+ (SPCompiledSprite *)sprite;

@end