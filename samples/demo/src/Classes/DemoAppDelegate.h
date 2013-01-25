//
//  DemoAppDelegate.h
//  Demo
//
//  Created by Daniel Sperl on 25.07.09.
//  Copyright 2011 Gamua. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Sparrow.h"

@interface DemoAppDelegate : NSObject <UIApplicationDelegate> 
{
    UIWindow *mWindow;
    SPView *mSparrowView;
}

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet SPView *sparrowView;

@end

