//
//  UserDefaults.h
//  Roomote
//
//  Created by Brian on 1/20/10.
//  Copyright 2010 Brian Pratt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "constants.h"
#include "networking.h"

@interface UserDefaults : NSObject {

}

+ (BOOL) forceSynchronization;

// Custom Command Methods
+ (BOOL) customCommand: (NSUInteger) commandNumber asRawCustomCommand: (uint8_t*) rawCustomCommand;
+ (NSString*) customCommandAsString: (NSUInteger) commandNumber;
+ (void) setCustomCommand: (NSUInteger) commandNumber withString: (NSString*) commandString;

// Custom Command Name Methods
+ (NSString*) customCommandName: (NSUInteger) commandNumber;
+ (void) setCustomCommandName: (NSUInteger) commandNumber withString: (NSString*) customCommandName;


@end
