//
//  EAGLView.h
//  Sparrow
//
//  Created by Daniel Sperl on 13.03.09.
//  Copyright Incognitek 2009. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

@class SPStage;

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
    
    EAGLContext *mContext;    
    GLuint mRenderbuffer;
    GLuint mFramebuffer;
    
    NSTimer *mTimer;
    double mFrameRate;
    double mLastFrameTimestamp;
    double mLastTouchTimestamp;
}

- (id)initWithFrame:(CGRect)aRect;
- (id)initWithCoder:(NSCoder*)coder;

@property (nonatomic, assign) BOOL isStarted;
@property (nonatomic, assign) double frameRate;
@property (nonatomic, retain) SPStage *stage;

@end
