//
//  SPStage.h
//  Sparrow
//
//  Created by Daniel Sperl on 15.03.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>
#import "SPDisplayObjectContainer.h"
#import "SPMacros.h"

@class SPTouchProcessor;
@class SPJuggler;

/** ------------------------------------------------------------------------------------------------

 An SPStage is the root of the display tree. It represents the rendering area of the application.
 
 To create a Sparrow application, you create a class that inherits from SPStage and populates
 the display tree.
 
 The stage allows you to access the native view object it is drawing its content to. (Currently,
 this is always an SPView). Furthermore, you can change the framerate in which the contents is 
 rendered.
 
 You can access the stage from anywhere in your code with the following static method:

    [SPStage mainStage];
 
 A stage also contains a default juggler which you can use for your animations. It is advanced 
 automatically once per frame. You can access this juggler from any display object by calling
 
	[SPStage mainStage].juggler
  
------------------------------------------------------------------------------------------------- */

@interface SPStage : SPDisplayObjectContainer

/// --------------------
/// @name Initialization
/// --------------------

/// Initializes a stage with a certain size in points.
- (id)initWithWidth:(float)width height:(float)height;

/// ----------------
/// @name Properties
/// ----------------

/// The background color of the stage. Default: black.
@property (nonatomic, assign) uint color;

@end
