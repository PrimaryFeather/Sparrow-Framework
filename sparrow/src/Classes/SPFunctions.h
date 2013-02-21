//
//  SPFunctions.h
//  Sparrow
//
//  Created by Daniel Sperl on 19.02.13.
//
//

#ifndef Sparrow_SPFunctions_h
#define Sparrow_SPFunctions_h

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import <math.h>

#import "SPMacros.h"

/// Creates a GLKVector4 object from an RGB color and an alpha value.
static __inline__ GLKVector4 GLKVector4MakeWithColor(uint color, float alpha)
{
    GLKVector4 v = {
        SP_COLOR_PART_RED(color)   / 255.0f,
        SP_COLOR_PART_GREEN(color) / 255.0f,
        SP_COLOR_PART_BLUE(color)  / 255.0f,
        alpha
    };
    return v;
}

/// Creates a GLKVector4 object from an ARGB color.
static __inline__ GLKVector4 GLKVector4MakeWithColorARGB(uint color)
{
    GLKVector4 v = {
        SP_COLOR_PART_RED(color)   / 255.0f,
        SP_COLOR_PART_GREEN(color) / 255.0f,
        SP_COLOR_PART_BLUE(color)  / 255.0f,
        SP_COLOR_PART_ALPHA(color) / 255.0f
    };
    return v;
}

/// Creates an RGB color from a GLKVector4 object (the alpha value of the vector is ignored).
static __inline__ uint GLKVector4ToSPColor(GLKVector4 vector)
{
    return SP_COLOR((int)(vector.r * 255.0f), (int)(vector.g * 255.0f),
                    (int)(vector.b * 255.0f));
}

/// Creates an ARGB color from a GLKVector4 object.
static __inline__ uint GLKVector4ToSPColorARGB(GLKVector4 vector)
{
    return SP_COLOR_ARGB((int)(vector.a * 255.0f), (int)(vector.r * 255.0f),
                         (int)(vector.g * 255.0f), (int)(vector.b * 255.0f));
}

#endif
