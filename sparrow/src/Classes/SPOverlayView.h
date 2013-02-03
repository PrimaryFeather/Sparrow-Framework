//
//  SPOverlayView.h
//  Sparrow
//
//  Created by Daniel Sperl on 26.01.13.
//  Copyright 2013 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <UIKit/UIKit.h>

/** ------------------------------------------------------------------------------------------------

 This class makes a UIView work just like a sprite in Sparrow:
 it will react only on touches of child objects, and won't block touches on 
 empty areas any longer. That makes it perfect for an overlay view, on which
 we can then add all kinds of UIKit elements: textfields, iAd banners, etc.
 
------------------------------------------------------------------------------------------------- */
 
@interface SPOverlayView : UIView

@end
