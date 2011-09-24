//
//  UserDefaults.m
//  Roomote
//
//  Created by Brian on 1/20/10.
//  Copyright 2010 Brian Pratt. All rights reserved.
//

#import "UserDefaults.h"


@implementation UserDefaults

// Class variables
// Keep track of changes for the current session (these values don't persist)


+ (BOOL) forceSynchronization {
	// Return the results of attempting to write preferences to system
	return [[NSUserDefaults standardUserDefaults] synchronize];	
}



#pragma mark ----- Custom Command Methods ------

+ (NSArray*) initCustomCommandsArray {
	NSMutableArray* customCommandsArray = [NSMutableArray arrayWithCapacity: kMaxCustomCommands];
	for (int i=0; i < kMaxCustomCommands; i++) {
		[customCommandsArray addObject: [NSArray array]];
	}
	
	return customCommandsArray;
}

+ (void) setCustomCommandsArray: (NSArray*) newCustomCommandsArray {
	[[NSUserDefaults standardUserDefaults] setObject: newCustomCommandsArray forKey: kCustomCommandKey];
}

+ (NSArray*) customCommandsArray {
	// If data exists...
	if ([[NSUserDefaults standardUserDefaults] arrayForKey: kCustomCommandKey])
		return [[NSUserDefaults standardUserDefaults] arrayForKey: kCustomCommandKey];
	else {
		NSArray* customCommandsArray = [self initCustomCommandsArray];
		[self setCustomCommandsArray: customCommandsArray];
		return customCommandsArray;
	}
}

+ (NSArray*) customCommand: (NSUInteger) commandNumber {
	NSArray *customCommands = [self customCommandsArray];
	
	if (commandNumber > [customCommands count])
		return nil;
	
	return [customCommands objectAtIndex: commandNumber-1];
}

// Helper method for converting a custom command string to an object array
+ (NSArray*) customCommandArrayFromString: (NSString*) commandString {
	NSMutableArray* customCommandArray = [NSMutableArray array];
	
	// Parse the elements of the string and store them as NSNumbers
	NSScanner* scanner = [NSScanner scannerWithString: commandString];
	[scanner setCharactersToBeSkipped: [NSCharacterSet punctuationCharacterSet]];
	while (![scanner isAtEnd]) {
		int commandByte;
		BOOL success = [scanner scanInteger: &commandByte];
		if (success)
			[customCommandArray addObject: [NSNumber numberWithInt: commandByte]];
		else {
			NSLog(@"Could not parse command string: %@", commandString);
		}

	}
	
	//NSArray* numbers = [commandString componentsSeparatedByString: @","];
	// TODO: Convert to NSNumbers (and check for valid numbers?)
	
	return customCommandArray;
}

+ (void) setCustomCommand: (NSUInteger) commandNumber withString: (NSString*) commandString {
	NSArray *customCommands = [self customCommandsArray];
	NSMutableArray *customCommandsArray = [NSMutableArray arrayWithArray: customCommands];
	
	if (commandNumber > [customCommands count])
		return; // What to do here?
	
	NSArray* customCommand = [self customCommandArrayFromString: commandString];
	
	[customCommandsArray replaceObjectAtIndex: commandNumber-1 withObject: customCommand];
	
	[self setCustomCommandsArray: customCommandsArray];
}

// Helper method for converting a custom command from an object array to a simple C array
+ (void) convertNSArray: (NSArray*) nsarray toRawCustomCommand: (uint8_t*) rawCustomCommand {
	int count = [nsarray count];
	// The first byte should indicate the number of bytes to follow
	rawCustomCommand[0] = count;
	for (int i=0; i < count; i++) {
		// Each element is assumed to be a NSNumber
		rawCustomCommand[i+1] = [[nsarray objectAtIndex: i] unsignedIntValue];
	}
	// Fill the rest of the command with zeros
	for (int i=count+1; i < MAX_CUSTOM_COMMAND_PACKET_LENGTH; i++) {
		rawCustomCommand[i] = 0;
	}
}

+ (BOOL) customCommand: (NSUInteger) commandNumber asRawCustomCommand: (uint8_t*) rawCustomCommand {
	// Get the saved command (based on the button tag)
	NSArray *customCommand = [self customCommand: commandNumber];
	
	// Make sure this command is defined
	if (customCommand == nil)
		return NO;
	
	// Convert the Obj-C to a simple C array
	[self convertNSArray: customCommand toRawCustomCommand: rawCustomCommand];
	
	return YES;
}

// Helper method for converting a custom command from an object array to a comma-separated string
+ (NSString*) stringFromNSArray: (NSArray*) nsarray {
	int count = [nsarray count];
	if (count < 1)
		return nil;
	NSString* nsstring = [[nsarray objectAtIndex: 0] stringValue];
	for (int i=1; i < count; i++) {
		// Each element is assumed to be a NSNumber
		nsstring = [NSString stringWithFormat: @"%@,%@", nsstring, [[nsarray objectAtIndex: i] stringValue]];
	}
	
	return nsstring;
}

+ (NSString*) customCommandAsString: (NSUInteger) commandNumber {
	// Get the saved command (based on the button tag)
	NSArray *customCommand = [self customCommand: commandNumber];
	
	if (customCommand == nil)
		return nil;
	
	return [self stringFromNSArray: customCommand];
}



#pragma mark ----- Custom Command Name Methods ------

+ (NSArray*) initCustomCommandNamesArray {
	NSMutableArray* customCommandNamesArray = [NSMutableArray arrayWithCapacity: kMaxCustomCommands];
	for (int i=0; i < kMaxCustomCommands; i++) {
		[customCommandNamesArray addObject: [NSString string]];
	}
	
	return customCommandNamesArray;
}

+ (void) setCustomCommandNamesArray: (NSArray*) newCustomCommandNamesArray {
	[[NSUserDefaults standardUserDefaults] setObject: newCustomCommandNamesArray forKey: kCustomCommandNamesKey];
}

+ (NSArray*) customCommandNamesArray {
	// If data exists...
	if ([[NSUserDefaults standardUserDefaults] arrayForKey: kCustomCommandNamesKey])
		return [[NSUserDefaults standardUserDefaults] arrayForKey: kCustomCommandNamesKey];
	else {
		NSArray* customCommandNamesArray = [self initCustomCommandNamesArray];
		[self setCustomCommandNamesArray: customCommandNamesArray];
		return customCommandNamesArray;
	}
}

+ (NSString*) customCommandName: (NSUInteger) commandNumber {
	NSArray *customCommandNames = [self customCommandNamesArray];
	
	if (commandNumber > [customCommandNames count])
		return nil;
	
	NSString* customCommandName = [customCommandNames objectAtIndex: commandNumber-1];
	if ([customCommandName length] == 0)
		return nil;
	else
		return customCommandName;
}

+ (void) setCustomCommandName: (NSUInteger) commandNumber withString: (NSString*) customCommandName {
	NSArray *customCommandNames = [self customCommandNamesArray];
	NSMutableArray *customCommandNamesArray = [NSMutableArray arrayWithArray: customCommandNames];
	
	if (commandNumber > [customCommandNames count])
		return; // What to do here?
	
	[customCommandNamesArray replaceObjectAtIndex: commandNumber-1 withObject: customCommandName];
	
	[self setCustomCommandNamesArray: customCommandNamesArray];
}


@end
