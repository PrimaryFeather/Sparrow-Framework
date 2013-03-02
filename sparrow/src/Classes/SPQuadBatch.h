//
//  SPQuadBatch.h
//  Sparrow
//
//  Created by Daniel Sperl on 01.03.13.
//  Copyright 2013 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPDisplayObject.h"
#import "SPVertexData.h"

@class SPImage;
@class SPQuad;
@class SPTexture;

/** ------------------------------------------------------------------------------------------------
 
 Optimizes rendering of a number of quads with an identical state.
 
 The majority of all rendered objects in Sparrow are quads. In fact, all the default
 leaf nodes of Starling are quads (the `SPImage` and `SPQuad` classes). The rendering of those
 quads can be accelerated by a big factor if all quads with an identical state are sent
 to the GPU in just one call. That's what the `SPQuadBatch` class can do.
 
 The `flatten` method of the `SPSprite` class uses this class internally to optimize its
 rendering performance. In most situations, it is recommended to stick with flattened
 sprites, because they are easier to use. Sometimes, however, it makes sense
 to use the QuadBatch class directly: e.g. you can add one quad multiple times to
 a quad batch, whereas you can only add it once to a sprite. Furthermore, this class
 does not dispatch `ADDED` or `ADDED_TO_STAGE` events when a quad
 is added, which makes it more lightweight.
 
 One QuadBatch object is bound to a specific render state. The first object you add to a
 batch will decide on the QuadBatch's state, that is: its texture, its settings for
 smoothing and blending, and if it's tinted (colored vertices and/or transparency).
 When you reset the batch, it will accept a new state on the next added quad.
 
------------------------------------------------------------------------------------------------- */
@interface SPQuadBatch : SPDisplayObject

/// Resets the batch. The vertex- and index-buffers keep their size, so that they can be reused.
- (void)reset;

/// Adds a quad without a texture.
- (void)addQuad:(SPQuad *)quad;

/// Adds a quad with a texture.
- (void)addQuad:(SPQuad *)quad texture:(SPTexture *)texture;

/// Adds a quad with a texture and a custom alpha value (ignoring the quad's original alpha).
- (void)addQuad:(SPQuad *)quad texture:(SPTexture *)texture alpha:(float)alpha;

/// Adds a quad to the batch. The first quad determines the state of the batch, i.e. the values
/// for texture and smoothing and blendmode. When you add additional quads,
/// make sure they share that state (e.g. with the 'isStateChange' method), or reset
/// the batch. Each vertex of the quad will be transformed by the matrix parameter.
- (void)addQuad:(SPQuad *)quad texture:(SPTexture *)texture alpha:(float)alpha matrix:(SPMatrix *)matrix;

/// Indicates if specific quads can be added to the batch without causing a state change.
/// A state change occurs if the quad uses a different base texture, has a different `smoothing`
/// or `repeat` setting, or if the batch is full (one batch can contain up to 8192 quads).
- (BOOL)isStateChangeWithQuad:(SPQuad *)quad texture:(SPTexture *)texture numQuads:(int)numQuads;

/// Renders the batch with custom settings for modelview-projection matrix and alpha.
/// This makes it possible to render batches that are not part of the display list.
- (void)renderWithAlpha:(float)alpha matrix:(SPMatrix *)matrix;

/// The number of quads that has been added to the batch.
@property (nonatomic, readonly) int numQuads;

@end
