//
//  SPOverlayView.h
//  AppScaffold
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
