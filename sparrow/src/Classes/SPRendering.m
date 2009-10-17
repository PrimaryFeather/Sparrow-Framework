//
//  SPRenderingGLES.m
//  Sparrow
//
//  Created by Daniel Sperl on 16.03.09.
//  Copyright 2009 Incognitek. All rights reserved.
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
    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();    
    glScalef(1.0f, -1.0f, 1.0f);
    glTranslatef(-mWidth/2.0f, -mHeight/2.0f, 0.0f);
    
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
    if (self.alpha == 0 || !self.visible) return;
    
    for (SPDisplayObject *child in self)
    {        
        glPushMatrix();        
        glTranslatef(child.x, child.y, ZPOS);        
        glRotatef(SP_R2D(child.rotationZ), 0.0f, 0.0f, 1.0f);
        glScalef(child.scaleX, child.scaleY, 1.0f);        
        
        float originalAlpha = child.alpha;        
        child.alpha *= self.alpha;
        [child render:support];
        child.alpha = originalAlpha;
        
        glPopMatrix();        
    }
}

@end

@implementation SPQuad (Rendering)

- (void)render:(SPRenderSupport *)support;
{
    if (self.alpha == 0 || !self.visible) return;
    
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
    if (self.alpha == 0 || !self.visible) return;    
    
    static float texCoords[8];     
    [mTexture adjustTextureCoordinates:mTexCoords saveAtTarget:texCoords numVertices:4];    
    
    [support bindTexture:mTexture];
    
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glTexCoordPointer(2, GL_FLOAT, 0, texCoords);
    
    [super render:support];    
    
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
}

@end
