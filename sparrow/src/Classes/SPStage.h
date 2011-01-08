//
//  SPStage.h
//  Sparrow
//
//  Created by Daniel Sperl on 15.03.09.
//  Copyright 2009 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>
#import "SPDisplayObjectContainer.h"

@class SPTouchProcessor;
@class SPJuggler;

/** ------------------------------------------------------------------------------------------------

 An SPStage is the root of the display tree. It represents the rendering area of the application.
 
 To create a Sparrow application, you create a class that inherits from SPStage and populates
 the display tree.
 
 The stage allows you to access the native view object it is drawing its content to. (Currently,
 this is always an SPView). Furthermore, you can change the framerate in which the contents is 
 rendered.
 
 A stage also contains a default juggler which you can use for your animations. It is advanced 
 automatically once per frame. You can access this juggler from any display object by calling
 
	self.stage.juggler
 
 You have to take care, however, that the display object you are making this call from is already
 connected to the stage - otherwise, the method will return `nil`, and you won't have access to 
 the juggler.
 
------------------------------------------------------------------------------------------------- */

@interface SPStage : SPDisplayObjectContainer
{
  @private
    float mWidth;
    float mHeight;
 
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

/// ----------------
/// @name Properties
/// ----------------

/// The requested number of frames per second. Must be a divisor of 60 (like 30, 20, 15, 12, 10, etc.).
/// The actual frame rate might be lower if there is too much to process.
@property (nonatomic, assign)   float frameRate;

/// A juggler that is automatically advanced once per frame.
@property (nonatomic, readonly) SPJuggler *juggler;

/// The native view the stage is connected to. Normally an SPView.
@property (nonatomic, readonly) id nativeView;

@end


@interface SPStage (HDSupport)

/// Enables support for high resolutions (aka retina displays).
+ (void)setSupportHighResolutions:(BOOL)value;

/// Determines if high resolution support is activated.
+ (BOOL)supportHighResolutions;

/// Sets the content scale factor, which determines the relationship between points and pixels.
+ (void)setContentScaleFactor:(float)value;

/// The current content scale factor.
+ (float)contentScaleFactor;

@end