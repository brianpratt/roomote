//
//  main.m
//  Roomote
//
//  Created by Brian on 1/22/09.
//  Copyright Brian Pratt 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, @"RoomoteAppDelegate");
    [pool release];
    return retVal;
}
