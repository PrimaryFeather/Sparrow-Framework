//
//  TouchSheet.h
//  Sparrow
//
//  Created by Daniel Sperl on 08.05.09.
//  Copyright 2011 Gamua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sparrow.h"

@interface TouchSheet : SPSprite 
{
  @private
    SPQuad *mQuad;
}

- (id)initWithQuad:(SPQuad*)quad; // designated initializer

@end
