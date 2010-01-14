//
//  AppScaffoldAppDelegate.h
//  AppScaffold
//
//  Created by Daniel Sperl on 14.01.10.
//  Copyright Incognitek 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Sparrow.h" 

@interface ApplicationDelegate : NSObject <UIApplicationDelegate> 
{
    UIWindow *window;
    SPView *sparrowView;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet SPView *sparrowView;

@end
