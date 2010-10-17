//
//  SPRenderingGLES.m
//  Sparrow
//
//  Created by Daniel Sperl on 16.03.09.
//  Copyright 2009 Incognitek. All rights reserved.
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

#define ZPOS 0

@implementation SPStage (Rendering)

- (void)render:(SPRenderSupport *)support;
{
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glDisable(GL_CULL_FACE);
    glDisable(GL_LIGHTING);
    glDisable(GL_DEPTH_TEST);
    
    glEnable(GL_TEXTURE_2D);
    glEnable(GL_BLEND);
    
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();    
    
    glOrthof(-mWidth/2.0f, mWidth/2.0f, -mHeight/2.0f, mHeight/2.0f, -1.0f, 1.0f);
    
    // use glFrustum instead of glOrtho for experiments in a perspective 3D space
    // glFrustumf(-mWidth/2.0, mWidth/2.0f, -mHeight/2.0f, mHeight/2.0f, 250.0f, 1000.0f);
    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();    
    glScalef(1.0f, -1.0f, 1.0f);    
    glTranslatef(-mWidth/2.0f, -mHeight/2.0f, -ZPOS);
    
    [super render:support];
    
    glDisable(GL_BLEND);
    glDisable(GL_TEXTURE_2D);
    
    #if DEBUG
    GLenum error = glGetError();
    if (error != 0) NSLog(@"Warning: There was an OpenGL error: #%d", error);
    #endif
}

@end

@implementation SPDisplayObjectContainer (Rendering)

- (void)render:(SPRenderSupport *)support;
{    
    float alpha = self.alpha;
    
    for (SPDisplayObject *child in mChildren)
    {
        float childAlpha = child.alpha;
        if (childAlpha != 0.0f && child.visible)
        {            
            float x = child.x;
            float y = child.y;
            float rotation = child.rotation;
            float scaleX = child.scaleX;
            float scaleY = child.scaleY;
            
            glPushMatrix();
            
            if (x != 0.0f || y != 0.0f)           glTranslatef(x, y, 0);
            if (rotation != 0.0f)                 glRotatef(SP_R2D(rotation), 0.0f, 0.0f, 1.0f);
            if (scaleX != 0.0f || scaleY != 0.0f) glScalef(scaleX, scaleY, 1.0f);        
       
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

- (void)render:(SPRenderSupport *)support;
{    
    static float texCoords[8];     
    static uint colors[4];
    float alpha = self.alpha;
    
    [support bindTexture:mTexture];  
    [mTexture adjustTextureCoordinates:mTexCoords saveAtTarget:texCoords numVertices:4];          
    
    for (int i=0; i<4; ++i)
        colors[i] = [support convertColor:mVertexColors[i] alpha:alpha];    
    
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
