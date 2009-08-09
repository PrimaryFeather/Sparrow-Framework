//
//  SPImage.h
//  Sparrow
//
//  Created by Daniel Sperl on 19.06.09.
//  Copyright 2009 Incognitek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPQuad.h"

@class SPTexture;
@class SPPoint;

@interface SPImage : SPQuad 
{
  @private
    SPTexture *mTexture;
    float mTexCoords[8];
}

@property (nonatomic, retain) SPTexture *texture;

// designated initializer
- (id)initWithTexture:(SPTexture*)texture;
- (id)initWithContentsOfFile:(NSString*)path;

- (void)setTexCoords:(SPPoint*)coords ofVertex:(int)vertexID;
- (SPPoint*)texCoordsOfVertex:(int)vertexID;

+ (SPImage*)imageWithTexture:(SPTexture*)texture;
+ (SPImage*)imageWithContentsOfFile:(NSString*)path;

@end
