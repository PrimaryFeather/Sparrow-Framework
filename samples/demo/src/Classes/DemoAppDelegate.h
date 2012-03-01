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

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet SPView *sparrowView;

@end

