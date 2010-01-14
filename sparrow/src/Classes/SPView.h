//
//  EAGLView.h
//  Sparrow
//
//  Created by Daniel Sperl on 13.03.09.
//  Copyright 2009 Incognitek. All rights reserved.
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

/*
This class wraps the CAEAGLLayer from CoreAnimation into a convenient UIView subclass.
The view content is basically an EAGL surface you render your OpenGL scene into.
Note that setting the view non-opaque will only work if the EAGL surface has an alpha channel.
*/
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

@property (nonatomic, readonly) BOOL isStarted;
@property (nonatomic, assign) float frameRate;
@property (nonatomic, retain) SPStage *stage;

- (void)start;
- (void)stop;

@end
