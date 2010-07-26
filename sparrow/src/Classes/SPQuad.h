//
//  SPQuad.h
//  Sparrow
//
//  Created by Daniel Sperl on 15.03.09.
//  Copyright 2009 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>
#import "SPDisplayObject.h"

@interface SPQuad : SPDisplayObject 
{
  @private
    float mVertexCoords[8];
    uint mVertexColors[4];
}

@property (nonatomic, assign) uint color;

- (id)initWithWidth:(float)width height:(float)height; 
- (void)setColor:(uint)color ofVertex:(int)vertexID;
- (uint)colorOfVertex:(int)vertexID;

+ (SPQuad*)quadWithWidth:(float)width height:(float)height;

@end
