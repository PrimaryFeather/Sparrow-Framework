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
{
  @private
    float mWidth;
    float mHeight;
    uint  mColor;
 
    // helpers
    SPTouchProcessor *mTouchProcessor;
    SPJuggler *mJuggler;
    
    id mNativeView;
}

/// --------------------
/// @name Initialization
/// --------------------

/// Initializes a stage with a certain size in points.
- (id)initWithWidth:(float)width height:(float)height;

/// Dispatches an enter frame event on all children and advances the juggler.
- (void)advanceTime:(double)seconds;

/// Process a new set up touches. Dispatches touch events on affected children.
- (void)processTouches:(NSSet*)touches;

/// -------------
/// @name Methods
/// -------------

/// Returns the first available stage instance. (In most cases, there is only one stage, anyway.)
+ (SPStage *)mainStage;

/// ----------------
/// @name Properties
/// ----------------

/// The requested number of frames per second. Must be a divisor of 60 (like 30, 20, 15, 12, 10, etc.).
/// The actual frame rate might be lower if there is too much to process.
@property (nonatomic, assign)   float frameRate;

/// The background color of the stage. Default: black.
@property (nonatomic, assign)   uint color;

/// A juggler that is automatically advanced once per frame.
@property (nonatomic, readonly) SPJuggler *juggler;

/// The native view the stage is connected to. Normally an SPView.
@property (nonatomic, readonly) id nativeView;

@end


@interface SPStage (HDSupport)

/// Enables support for high resolutions (aka retina displays).
+ (void)setSupportHighResolutions:(BOOL)hd;

/// Enables support for high resolutions (aka retina displays). If 'doubleOnPad' is true, 
/// pad devices will use twice the resolution ('@2x' on iPad 1+2, '@4x' on iPad 3+).
+ (void)setSupportHighResolutions:(BOOL)hd doubleOnPad:(BOOL)pad;

/// Determines if high resolution support is activated.
+ (BOOL)supportHighResolutions;

/// Determines if pad devices use twice the resolution.
+ (BOOL)doubleResolutionsOnPad;

/// Sets the content scale factor, which determines the relationship between points and pixels.
/// DEPRECATED! Use `doubleResolutionsOnPad` instead.
+ (void)setContentScaleFactor:(float)value SP_DEPRECATED; 

/// The current content scale factor.
+ (float)contentScaleFactor;

@end
