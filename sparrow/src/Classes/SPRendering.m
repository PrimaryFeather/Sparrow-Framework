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

@implementation SPStage (Rendering)

- (void)render
{    
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); 

    glDisable(GL_CULL_FACE);
    glDisable(GL_LIGHTING);
    glDisable(GL_DEPTH_TEST);
    
    glEnable(GL_TEXTURE_2D);
    glEnable(GL_BLEND);
    
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();    
    glOrthof(-self.width/2.0f, self.width/2.0f, -self.height/2.0f, self.height/2.0f, -1.0f, 1.0f);        
    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();    
    glScalef(1.0f, -1.0f, 1.0f);
    glTranslatef(-self.width/2.0f, -self.height/2.0f, 0.0f);
    
    [super render];
    
    glDisable(GL_BLEND);
    glDisable(GL_TEXTURE_2D);
    
    GLenum error = glGetError();
    if (error != 0) NSLog(@"Warning: There was an OpenGL error: #%d", error);
}

@end

@implementation SPDisplayObjectContainer (Rendering)

- (void)render
{    
    if (self.alpha == 0 || !self.isVisible) return;
    
    for (int i=0; i<self.numChildren; ++i)
    {
        SPDisplayObject* child = [self childAtIndex:i];
        
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
    
    GLfloat vertices[] = { 0, 0, mWidth, 0, mWidth, mHeight, 0, mHeight };   
    
    GLubyte colors[16];    
    GLubyte alpha = (GLubyte) (self.alpha * 255);
    int pos = 0;
    for (int i=0; i<4; ++i) 
    {
        uint color = [self colorOfVertex:i];        
        colors[pos++] = SP_COLOR_PART_RED(color);
        colors[pos++] = SP_COLOR_PART_GREEN(color);
        colors[pos++] = SP_COLOR_PART_BLUE(color);
        colors[pos++] = alpha;
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

- (void)render
{
    if (self.alpha == 0 || !self.isVisible) return;

    SPRectangle *clipping = mTexture.clipping;
    float texCoords[] = 
    { 
        clipping.x + mTexCoords[0] * clipping.width, 
        clipping.y + mTexCoords[1] * clipping.height,
        clipping.x + mTexCoords[2] * clipping.width, 
        clipping.y + mTexCoords[3] * clipping.height,
        clipping.x + mTexCoords[4] * clipping.width, 
        clipping.y + mTexCoords[5] * clipping.height,
        clipping.x + mTexCoords[6] * clipping.width, 
        clipping.y + mTexCoords[7] * clipping.height 
    };
    
    glBindTexture(GL_TEXTURE_2D, mTexture.textureID);
    
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glTexCoordPointer(2, GL_FLOAT, 0, texCoords);
    
    [super render];    
    
    glBindTexture(GL_TEXTURE_2D, 0);
    
    // todo: minimize calls to glBindTexture
}

@end

@implementation SPTextField (Rendering)

- (void)render
{
    if (self.alpha == 0 || !self.isVisible) return;
    
    SPRectangle *clipping = mTexture.clipping;
    float texCoords[] = 
    { 
        clipping.x, 
        clipping.y,
        clipping.x + clipping.width, 
        clipping.y,
        clipping.x + clipping.width, 
        clipping.y + clipping.height,
        clipping.x, 
        clipping.y + clipping.height 
    };
    
    glBindTexture(GL_TEXTURE_2D, mTexture.textureID);
    
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glTexCoordPointer(2, GL_FLOAT, 0, texCoords);
    
    [super render];    
    
    glBindTexture(GL_TEXTURE_2D, 0);
}

@end

