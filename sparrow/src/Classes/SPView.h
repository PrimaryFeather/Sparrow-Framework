//
//  EAGLView.h
//  Sparrow
//
//  Created by Daniel Sperl on 13.03.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//


#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

@class SPStage;
@class SPRenderSupport;

/** ------------------------------------------------------------------------------------------------

 An SPView is the UIView object that Sparrow renders its content into. 
 
 Add it to the UIKit display list like any other view. Beware that Sparrow will only receive
 multitouch events if the `multitouchEnabled` property of the view is enabled.
 
 To start Sparrow, connect this class to your stage subclass and call the `start` method. When
 the application ends or moves into the background, you should call the `stop` method.
 
------------------------------------------------------------------------------------------------- */

@interface SPView : UIView
{ 
  @private  
    int mWidth;
    int mHeight;
    
    SPStage *mStage;
    SPRenderSupport *mRenderSupport;
    
    EAGLContext *mContext;    
    GLuint mRenderbuffer;
    GLuint mFramebuffer;    
    
    float mFrameRate;
    NSTimer *mTimer;
    id mDisplayLink;
    BOOL mDisplayLinkSupported;        
    
    double mLastFrameTimestamp;
    double mLastTouchTimestamp;
}

/// ----------------
/// @name Properties
/// ----------------

/// Indicates if start was called.
@property (nonatomic, readonly) BOOL isStarted;

/// Assigns the desired framerate. Only dividers of 60 are allowed (60, 30, 20, 15, 12, 10, etc.)
@property (nonatomic, assign) float frameRate;

/// The stage object that will be processed.
@property (nonatomic, retain) SPStage *stage;

/// -------------
/// @name Methods
/// -------------

/// Starts rendering and event handling.
- (void)start;

/// Stops rendering and event handling. Call this when the application moves into the background.
- (void)stop;

@end
