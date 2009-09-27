//
//  SPRenderingGLES.m
//  Sparrow
//
//  Created by Daniel Sperl on 16.03.09.
//  Copyright 2009 Incognitek. All rights reserved.
//

#import "SPMakros.h"
#import "SPDisplayObjectContainer.h"
#import "SPQuad.h"
#import "SPStage.h"
#import "SPImage.h"
#import "SPTextField.h"
#import "SPTexture.h"

#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#define ZPOS 0

// --- c functions ---

static void bindTexture(uint textureID)
{
    static uint lastTextureID = UINT_MAX;
    
    if (lastTextureID != textureID)
    {    
        lastTextureID = textureID;
        glBindTexture(GL_TEXTURE_2D, textureID);
    }    
}

// ---

@implementation SPStage (Rendering)

- (void)render
{    
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA); // note: not GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA,
                                                 //       because of premultiplied png textures!
    
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
    
    [super render];
    
    glDisable(GL_BLEND);
    glDisable(GL_TEXTURE_2D);
    
    #if DEBUG
    GLenum error = glGetError();
    if (error != 0) NSLog(@"Warning: There was an OpenGL error: #%d", error);
    #endif
}

@end

@implementation SPDisplayObjectContainer (Rendering)

- (void)render
{    
    if (self.alpha == 0 || !self.isVisible) return;
    
    for (SPDisplayObject *child in self)
    {        
        glPushMatrix();        
        glTranslatef(child.x, child.y, ZPOS);        
        glRotatef(SP_R2D(child.rotationZ), 0.0f, 0.0f, 1.0f);
        glScalef(child.scaleX, child.scaleY, 1.0f);        
        
        float originalAlpha = child.alpha;        
        child.alpha *= self.alpha;
        [child render];
        child.alpha = originalAlpha;
        
        glPopMatrix();        
    }
}

@end



@implementation SPQuad (Rendering)

- (void)render
{
    if (self.alpha == 0 || !self.isVisible) return;
    
    static GLfloat vertices[8];   
    static GLubyte colors[16];   
    
    vertices[2] = mWidth;
    vertices[4] = mWidth;
    vertices[5] = mHeight;
    vertices[7] = mHeight;        
 
    // Since the iPhone loads png images with premultiplied alpha values, we need to use the
    // blending function "GL_ONE, GL_ONE_MINUS_SRC_ALPHA" (instead of the usual blending function, 
    // "GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA"). Thus, we have to premultiply the alpha values
    // generally. This might change in the future, when more texture formats are supported.
    
    float alpha = self.alpha;
    GLubyte* pos = colors;
    for (int i=0; i<4; ++i) 
    {
        uint color = mVertexColors[i];        
        *(pos++) = (GLubyte) (SP_COLOR_PART_RED(color) * alpha);
        *(pos++) = (GLubyte) (SP_COLOR_PART_GREEN(color) * alpha);
        *(pos++) = (GLubyte) (SP_COLOR_PART_BLUE(color) * alpha);        
        *(pos++) = (GLubyte) (alpha * 255);
    }
    
    // If this method is called from a subclass, it has most probably bound a texture (on purpose).
    // But if this is a 'real' quad, we have to disable any texture.
    if (self->isa == [SPQuad class])
        bindTexture(0);
    
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

- (void)render
{
    if (self.alpha == 0 || !self.isVisible) return;    
    
    static float texCoords[8]; 
    
    SPRectangle *clipping = mTexture.clipping;    
    for (int i=0; i<4; ++i)
    {
        texCoords[2*i]   = clipping.x + mTexCoords[2*i]   * clipping.width; 
        texCoords[2*i+1] = clipping.y + mTexCoords[2*i+1] * clipping.height;        
    }
    
    bindTexture(mTexture.textureID);
    
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glTexCoordPointer(2, GL_FLOAT, 0, texCoords);
    
    [super render];    
    
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
}

@end

@implementation SPTextField (Rendering)

- (void)render
{
    if (self.alpha == 0 || !self.isVisible) return;
    
    SPRectangle *clipping = mTexture.clipping;
    static float texCoords[8]; 
     
    texCoords[0] = clipping.x; 
    texCoords[1] = clipping.y;
    texCoords[2] = clipping.x + clipping.width; 
    texCoords[3] = clipping.y;
    texCoords[4] = clipping.x + clipping.width;
    texCoords[5] = clipping.y + clipping.height;
    texCoords[6] = clipping.x; 
    texCoords[7] = clipping.y + clipping.height;    
    
    bindTexture(mTexture.textureID);
    
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glTexCoordPointer(2, GL_FLOAT, 0, texCoords);
    
    [super render];  
    
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
}

@end
