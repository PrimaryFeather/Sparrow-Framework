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
    
    for (SPDisplayObject *child in self)
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
            if (rotation != 0.0f)                 glRotatef(SP_R2D(child.rotation), 0.0f, 0.0f, 1.0f);
            if (scaleX != 0.0f || scaleY != 0.0f) glScalef(child.scaleX, child.scaleY, 1.0f);        
       
            child.alpha *= alpha;
            [child render:support];
            child.alpha = childAlpha;
            
            glPopMatrix();        
        }
    }
}

@end

@implementation SPQuad (Rendering)

- (void)render:(SPRenderSupport *)support;
{
    // If this method is called from a subclass, it has most probably bound a texture (on purpose).
    // But if this is a 'real' quad, we have to disable any texture.
    if (self->isa == [SPQuad class])
        [support bindTexture:nil];
    
    static GLfloat vertices[8];   
    static GLubyte colors[16];   
    
    vertices[2] = mWidth;
    vertices[4] = mWidth;
    vertices[5] = mHeight;
    vertices[7] = mHeight;         
    
    float alpha = self.alpha;
    GLubyte* pos = colors;
    for (int i=0; i<4; ++i) 
    {
        uint color = mVertexColors[i];        
        
        if (support.usingPremultipliedAlpha)
        {
            *(pos++) = (GLubyte) (SP_COLOR_PART_RED(color) * alpha);
            *(pos++) = (GLubyte) (SP_COLOR_PART_GREEN(color) * alpha);
            *(pos++) = (GLubyte) (SP_COLOR_PART_BLUE(color) * alpha);        
        }
        else 
        {
            *(pos++) = (GLubyte) SP_COLOR_PART_RED(color);
            *(pos++) = (GLubyte) SP_COLOR_PART_GREEN(color);
            *(pos++) = (GLubyte) SP_COLOR_PART_BLUE(color);
        }        
        
        *(pos++) = (GLubyte) (alpha * 255);
    }
        
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);    
    
    glVertexPointer(2, GL_FLOAT, 0, vertices);
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, colors);
    
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_COLOR_ARRAY);
}

@end

@implementation SPImage (Rendering)

- (void)render:(SPRenderSupport *)support;
{    
    static float texCoords[8];     
    [mTexture adjustTextureCoordinates:mTexCoords saveAtTarget:texCoords numVertices:4];    
    
    [support bindTexture:mTexture];
    
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glTexCoordPointer(2, GL_FLOAT, 0, texCoords);
    
    [super render:support];    
    
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
}

@end
