//
//  ViewController.h
//  ViewControllerTest
//

#import <UIKit/UIKit.h>

#import "GameController.h"

@interface ViewController : UIViewController

@property (nonatomic, readonly) SPView *sparrowView;
@property (nonatomic, readonly) UIView *overlayView;
@property (nonatomic, readonly) GameController *gameController;

@end
