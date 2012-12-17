//
//  RoomoteAppDelegate.m
//  Roomote
//
//  Created by Brian on 1/22/09.
//  Copyright Brian Pratt 2009. All rights reserved.
//

#import "RoomoteAppDelegate.h"
#import "RootViewController.h"

@implementation RoomoteAppDelegate


@synthesize window;
@synthesize rootViewController;

// Global variables describing screen dimensions
float kScreenHeight = 480.0;
float kScreenHeightNoStatus = 460.0;
float kPickerViewHeight = 216.0;
float kNavigationBarHeight = 44.0;
float kControlViewHeight = 270.0;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
	// Behind the Status bar
	window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    // Set up global variables for different screen dimensions
    if ([[UIScreen mainScreen] bounds].size.height == 568 && [[UIScreen mainScreen] scale] == 2.0) {
        // 4-inch Retina display values. Override defaults.
        kScreenHeight = 568.0;
        kScreenHeightNoStatus = 548.0;
        kControlViewHeight = 320.0;
        // Launch RootViewController
        rootViewController = [[RootViewController alloc] initWithNibName: @"RootViewController-568h" bundle: [NSBundle mainBundle]];
    }
    else
        // Launch standard RootViewController
        rootViewController = [[RootViewController alloc] initWithNibName: @"RootViewController" bundle: [NSBundle mainBundle]];
    
    // Shift frame down 20px to avoid status bar
    CGRect frame = rootViewController.view.frame;
    frame.origin.y = 20.0;
    rootViewController.view.frame = frame;
    
    [window addSubview:[rootViewController view]];
    [window makeKeyAndVisible];
	
}


- (void)dealloc {
    [rootViewController release];
    [window release];
    [super dealloc];
}


@end
