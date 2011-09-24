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


- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
    [window addSubview:[rootViewController view]];
    [window makeKeyAndVisible];
	
}


- (void)dealloc {
    [rootViewController release];
    [window release];
    [super dealloc];
}


@end
