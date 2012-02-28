//
//  ViewController.h
//  ViewControllerTest
//

#import <UIKit/UIKit.h>

#import "GameController.h"

@interface ViewController : UIViewController
{
  @private
    SPView *mSparrowView;
}

- (id)initWithSparrowView:(SPView *)sparrowView;

@end
