//
//  SPBitmapFont.h
//  Sparrow
//
//  Created by Daniel Sperl on 12.10.09.
//  Copyright 2009 Incognitek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPTextField.h"
#import "SPMacros.h"

@class SPTexture;
@class SPDisplayObject;

@interface SPBitmapFont : NSObject 
{
  @private
    SPTexture *mFontTexture;
    NSMutableDictionary *mChars;
    NSString *mName;
    float mSize;
    float mLineHeight;
}

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) float size;
@property (nonatomic, assign)   float lineHeight;

- (id)initWithContentsOfFile:(NSString *)path texture:(SPTexture *)texture;
- (id)initWithContentsOfFile:(NSString *)path;

- (SPDisplayObject *)createDisplayObjectWithWidth:(float)width height:(float)height
                                             text:(NSString *)text fontSize:(float)size color:(uint)color 
                                           hAlign:(SPHAlign)hAlign vAlign:(SPVAlign)vAlign
                                           border:(BOOL)border;

@end
