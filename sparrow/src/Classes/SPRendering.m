//
//  SPRenderingGLES.m
//  Sparrow
//
//  Created by Daniel Sperl on 16.03.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPMacros.h"
#import "SPDisplayObjectContainer.h"
#import "SPQuad.h"
#import "SPStage.h"
#import "SPImage.h"
#import "SPTextField.h"
#import "SPTexture.h"
#import "SPRenderSupport.h"

#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>


@implementation SPStage (Rendering)

- (void)render:(SPRenderSupport *)support
{
    [SPRenderSupport clearWithColor:mColor alpha:1.0f];
    [SPRenderSupport setupOrthographicRenderingWithLeft:0 right:mWidth bottom:mHeight top:0];    
    
    [super render:support];
    
    #if DEBUG
    [SPRenderSupport checkForOpenGLError];
    #endif
}

@end


@implementation SPDisplayObjectContainer (Rendering)

- (void)render:(SPRenderSupport *)support
{    
    float alpha = self.alpha;
    
    for (SPDisplayObject *child in mChildren)
    {
        float childAlpha = child.alpha;
        if (childAlpha != 0.0f && child.visible)
        {            
            glPushMatrix();
            
            [SPRenderSupport transformMatrixForObject:child];
            
            child.alpha *= alpha;
            [child render:support];
            child.alpha = childAlpha;
            
            glPopMatrix();        
        }
    }
}

@end


@implementation SPQuad (Rendering)

- (void)render:(SPRenderSupport *)support
{    
    static uint colors[4];
    float alpha = self.alpha;
    
    [support bindTexture:nil];
    
    for (int i=0; i<4; ++i)
        colors[i] = [support convertColor:mVertexColors[i] alpha:alpha];
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);    
    
    glVertexPointer(2, GL_FLOAT, 0, mVertexCoords);
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, colors);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_COLOR_ARRAY);
}

@end


@implementation SPImage (Rendering)

- (void)render:(SPRenderSupport *)support
{    
    static float texCoords[8];     
    static uint colors[4];
    float alpha = self.alpha;
    
    [support bindTexture:mTexture];  
    [mTexture adjustTextureCoordinates:mTexCoords saveAtTarget:texCoords numVertices:4];          
    
    for (int i=0; i<4; ++i)
        colors[i] = [support convertColor:mVertexColors[i] alpha:alpha];    
    
    SPRectangle *frame = mTexture.frame;
    if (frame)
    {               
        glTranslatef(-frame.x, -frame.y, 0.0f);
        glScalef(mTexture.width / frame.width, mTexture.height / frame.height, 1.0f);        
    }
    
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);    
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);    
    
    glTexCoordPointer(2, GL_FLOAT, 0, texCoords);
    glVertexPointer(2, GL_FLOAT, 0, mVertexCoords);
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, colors);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_COLOR_ARRAY);    
    
    // Rendering was tested with vertex buffers, too -- but for simple quads and images like these, 
    // the overhead seems to outweigh the benefit. The "glDrawArrays"-approach is faster here.
}
 
@end
