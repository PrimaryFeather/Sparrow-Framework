//
//  RenderTextureScene.h
//  Demo
//
//  Created by Daniel Sperl on 05.12.10.
//  Copyright 2011 Gamua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Scene.h"

@interface RenderTextureScene : Scene 
{     
    SPRenderTexture *mRenderTexture;
    SPImage *mBrush;
}

@end
