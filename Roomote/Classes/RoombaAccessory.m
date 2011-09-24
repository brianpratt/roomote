//
//  RoombaAccessory.m
//  Roomote
//
//  Created by Brian Pratt on 6/11/09.
//  Copyright 2009 Brian Pratt. All rights reserved.
//

#import "RoombaAccessory.h"
#import "ExternalAccessory/EAAccessoryManager.h"


@implementation RoombaAccessory


- (void) connectToRoomba {
	// Get the shared accessory manager
	EAAccessoryManager* manager = [EAAccessoryManager sharedAccessoryManager];
	
	// Get the array of available accessories
	NSArray* accessories = [manager connectedAccessories];
	
	// Just print the list to the log for now
	for (int i=0; i < [accessories count]; i++) {
		EAAccessory* accessory = [accessories objectAtIndex: i];
		NSLog(@"Accessory %d: %@", i, [accessory name]);
	}
	
}

@end
