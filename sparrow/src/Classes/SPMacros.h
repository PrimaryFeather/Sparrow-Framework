//
//  SPMacros.h
//  Sparrow
//
//  Created by Daniel Sperl on 15.03.09.
//  Copyright 2009 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>
#import <math.h>

// constants

#define PI       3.14159265359f
#define PI_HALF  1.57079632679f
#define TWO_PI   6.28318530718f

#define SP_FLOAT_EPSILON 0.0001f

#define SP_WHITE 0xFFFFFF
#define SP_BLACK 0x000000

#define SP_NOT_FOUND -1
#define SP_MAX_DISPLAY_TREE_DEPTH 16

// exceptions

#define SP_EXC_ABSTRACT_CLASS       @"AbstractClass"
#define SP_EXC_ABSTRACT_METHOD      @"AbstractMethod"
#define SP_EXC_NOT_RELATED          @"NotRelated"
#define SP_EXC_INDEX_OUT_OF_BOUNDS  @"IndexOutOfBounds"
#define SP_EXC_INVALID_OPERATION    @"InvalidOperation"
#define SP_EXC_FILE_NOT_FOUND       @"FileNotFound"
#define SP_EXC_FILE_INVALID         @"FileInvalid"

// macros

#define SP_CREATE_POOL(pool)        NSAutoreleasePool *(pool) = [[NSAutoreleasePool alloc] init];
#define SP_RELEASE_POOL(pool)       [(pool) release];

#define SP_R2D(rad)                 ((rad) / PI * 180.0f)
#define SP_D2R(deg)                 ((deg) / 180.0f * PI)

#define SP_COLOR_PART_ALPHA(color)  (((color) >> 24) & 0xff)
#define SP_COLOR_PART_RED(color)    (((color) >> 16) & 0xff)
#define SP_COLOR_PART_GREEN(color)  (((color) >>  8) & 0xff)
#define SP_COLOR_PART_BLUE(color)   ( (color)        & 0xff)

#define SP_COLOR(r, g, b)			(((r) << 16) | ((g) << 8) | (b))

#define SP_IS_FLOAT_EQUAL(f1, f2)   (fabsf((f1)-(f2)) < SP_FLOAT_EPSILON)


