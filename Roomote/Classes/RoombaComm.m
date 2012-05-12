//
//  RoombaComm.m
//  Roomote
//
//  Created by Brian on 2/5/09.
//  Copyright 2009 Brian Pratt. All rights reserved.
//

#import "RoombaComm.h"

#define DEBUG NO

@implementation RoombaComm


// State Variables
unsigned int currentVelocity;
unsigned int currentTurnRadius;


// Accessor Methods
- (void)setDelegate:(id)newDelegate {
	delegate = newDelegate;
}

- (void)setSong:(unsigned)songNum {
	selectedSong = songNum;
}

- (void)setDemo:(unsigned)demoNum {
	selectedDemo = demoNum;
}



#pragma mark ----- Networking -----

- (void) showAlert:(NSString*)title
{
	UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:@"Check your networking configuration." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alertView show];
	[alertView release];
}

- (void)sendDriveCommand:(kDriveCommand)command {
	
	if (DEBUG) NSLog(@"Drive command: Type: %x, Velocity: %x, Turn Radius: %x\n", command.type, command.velocity, command.radius);
	
	union kDriveCommandUnion commandUnion;
	commandUnion.command = command;
	
	// Build up command with header and data
	uint8_t netMessage[1 + sizeof(union kDriveCommandUnion)];
	netMessage[0] = kNetMessageType_DriveCommand;
	memcpy(&netMessage[1], commandUnion.netMessage, sizeof(union kDriveCommandUnion));
	
	/*
	NSLog(@"sizeof(kNetMessageType_DriveCommand): %d\n",sizeof(kNetMessageType_DriveCommand));
	NSLog(@"sizeof(union kDriveCommandUnion): %d\n",sizeof(union kDriveCommandUnion));
	NSLog(@"sizeof(netMessage): %d\n",sizeof(netMessage));
	printf("netMessage: 0x");
	for (int i=0; i < sizeof(netMessage); i++) {
		printf("%0x ", netMessage[i]);
	}
	printf("\n");
	*/
	
	// Send message to server
	if ([delegate outStream] && [[delegate outStream] hasSpaceAvailable])
		if([[delegate outStream] write:netMessage maxLength:sizeof(netMessage)] != sizeof(netMessage))
			[self showAlert:@"Failed sending drive command to server"];
	
}

- (void)sendAuxCommand:(kAuxCommand)command {
	
	union kAuxCommandUnion commandUnion;
	commandUnion.command = command;
	
	// Build up command with header and data
	uint8_t netMessage[1 + sizeof(union kAuxCommandUnion)];
	netMessage[0] = kNetMessageType_AuxCommand;
	memcpy(&netMessage[1], commandUnion.netMessage, sizeof(union kAuxCommandUnion));
	
	// Send message to server
	if ([delegate outStream] && [[delegate outStream] hasSpaceAvailable])
		if([[delegate outStream] write:netMessage maxLength:sizeof(netMessage)] != sizeof(netMessage))
			[self showAlert:@"Failed sending auxiliary command to server"];
	
}

- (void)sendCustomCommand:(kCustomCommand)command {
		
	// Build up command with header and data
	uint8_t netMessage[1 + sizeof(kCustomCommand)];
	netMessage[0] = kNetMessageType_CustomCommand;
	memcpy(&netMessage[1], command, sizeof(kCustomCommand));
	
	/*
	// DEBUG: Print command
	NSLog(@"sizeof(kNetMessageType_CustomCommand): %d\n",sizeof(kNetMessageType_CustomCommand));
	NSLog(@"sizeof(kCustomCommand): %d\n",sizeof(kCustomCommand));
	NSLog(@"sizeof(netMessage): %d\n",sizeof(netMessage));
	printf("netMessage: 0x");
	for (int i=0; i < sizeof(netMessage); i++) {
		printf("%0x ", netMessage[i]);
	}
	printf("\n");
	*/
	
	// Send message to server
	if ([delegate outStream] && [[delegate outStream] hasSpaceAvailable])
		if([[delegate outStream] write:netMessage maxLength:sizeof(netMessage)] != sizeof(netMessage))
			[self showAlert:@"Failed sending custom command to server"];
	
}

- (void)sendDemoListRequestCommand {
	
	uint8_t netMessage = kNetMessageType_DemoListRequest;
	
	// Send message to server
	if ([delegate outStream] && [[delegate outStream] hasSpaceAvailable])
		if([[delegate outStream] write:&netMessage maxLength:sizeof(netMessage)] != sizeof(netMessage))
			[self showAlert:@"Failed sending demo list request command to server"];
	
	NSLog(@"Sent demo list request command");
}

- (void)sendSongListRequestCommand {
	
	uint8_t netMessage = kNetMessageType_SongListRequest;
	
	// Send message to server
	if ([delegate outStream] && [[delegate outStream] hasSpaceAvailable])
		if([[delegate outStream] write:&netMessage maxLength:sizeof(netMessage)] != sizeof(netMessage))
			[self showAlert:@"Failed sending song list request command to server"];
	
	NSLog(@"Sent song list request command");
}


#pragma mark ----- Helper Methods -----

- (void)setVelocity:(unsigned int)velocity {
	// Set the Roomba velocity
	currentVelocity = velocity;
	
	// Send to server
	kDriveCommand command;
	command.type = kDriveCommandType_SetVelocity;
	command.velocity = (uint16_t)currentVelocity;
	command.radius = kDriveCommandUseDefaultTurnRadius;
	
	[self sendDriveCommand:command];
	
}

- (void)setTurnRadius:(unsigned int)turnRadius {
	// Set the Roomba turn radius
	currentTurnRadius = turnRadius;
	
	// Send to server
	kDriveCommand command;
	command.type = kDriveCommandType_SetTurnRadius;
	command.velocity = kDriveCommandUseDefaultVelocity;
	command.radius = (uint16_t)currentTurnRadius;
	
	[self sendDriveCommand:command];
	
}


#pragma mark ----- Movement Actions -----

// Go Forward
- (void)goForwardWithVelocity: (unsigned) velocity {
	
	if (DEBUG) NSLog(@"Drive command: Go Forward with velocity: %d\n", velocity);
	
	kDriveCommand command;
	command.type = kDriveCommandType_Forward;
	command.velocity = velocity;
	command.radius = kDriveCommandUseDefaultTurnRadius;
	
	[self sendDriveCommand:command];
	
}

- (void)goForward {
	
	[self goForwardWithVelocity: kDriveCommandUseDefaultVelocity];
	
}

// Go Backward
- (void)goBackwardWithVelocity: (unsigned) velocity {
	
	if (DEBUG) NSLog(@"Drive command: Go Backward with velocity: %d\n", velocity);
	
	kDriveCommand command;
	command.type = kDriveCommandType_Backward;
	command.velocity = velocity;
	command.radius = kDriveCommandUseDefaultTurnRadius;
	
	[self sendDriveCommand:command];
	
}

- (void)goBackward {
	
	[self goBackwardWithVelocity: kDriveCommandUseDefaultVelocity];
	
}

// Go Forward Left
- (void)goForwardLeftWithVelocity: (unsigned) velocity andRadius: (unsigned) turnRadius {
	
	if (DEBUG) NSLog(@"Drive command: Go Forward Left with Velocity: %d and Turn Radius: %d\n", velocity, turnRadius);
	
	kDriveCommand command;
	command.type = kDriveCommandType_ForwardLeft;
	command.velocity = velocity;
	command.radius = turnRadius;
	
	[self sendDriveCommand:command];
	
}

- (void)goForwardLeftWithRadius: (unsigned) turnRadius {
	
	[self goForwardLeftWithVelocity: kDriveCommandUseDefaultVelocity andRadius: turnRadius];
	
}

- (void)goForwardLeft {
	
	[self goForwardLeftWithRadius: kDriveCommandUseDefaultTurnRadius];
	
}

// Go Forward Right
- (void)goForwardRightWithVelocity: (unsigned) velocity andRadius: (unsigned) turnRadius {
	
	if (DEBUG) NSLog(@"Drive command: Go Forward Right with Velocity: %d and Turn Radius: %d\n", velocity, turnRadius);
	
	kDriveCommand command;
	command.type = kDriveCommandType_ForwardRight;
	command.velocity = velocity;
	command.radius = turnRadius;
	
	[self sendDriveCommand:command];
	
}

- (void)goForwardRightWithRadius: (unsigned) turnRadius {
	
	[self goForwardRightWithVelocity: kDriveCommandUseDefaultVelocity andRadius: turnRadius];
	
}

- (void)goForwardRight {
	
	[self goForwardRightWithRadius: kDriveCommandUseDefaultTurnRadius];
	
}

// Go Backward Left
- (void)goBackwardLeftWithVelocity: (unsigned) velocity andRadius: (unsigned) turnRadius {
	
	if (DEBUG) NSLog(@"Drive command: Go Backward Left with Velocity: %d and Turn Radius: %d\n", velocity, turnRadius);
	
	kDriveCommand command;
	command.type = kDriveCommandType_BackwardLeft;
	command.velocity = velocity;
	command.radius = turnRadius;
	
	[self sendDriveCommand:command];
	
}

- (void)goBackwardLeftWithRadius: (unsigned) turnRadius {
	
	[self goBackwardLeftWithVelocity: kDriveCommandUseDefaultVelocity andRadius: turnRadius];
	
}

- (void)goBackwardLeft {
	
	[self goBackwardLeftWithRadius: kDriveCommandUseDefaultTurnRadius];
	
}

// Go Backward Right
- (void)goBackwardRightWithVelocity: (unsigned) velocity andRadius: (unsigned) turnRadius {
	
	if (DEBUG) NSLog(@"Drive command: Go Backward Right with Velocity: %d and Turn Radius: %d\n", velocity, turnRadius);
	
	kDriveCommand command;
	command.type = kDriveCommandType_BackwardRight;
	command.velocity = velocity;
	command.radius = turnRadius;
	
	[self sendDriveCommand:command];
	
}

- (void)goBackwardRightWithRadius: (unsigned) turnRadius {
	
	[self goBackwardRightWithVelocity: kDriveCommandUseDefaultVelocity andRadius: turnRadius];
	
}

- (void)goBackwardRight {
	
	[self goForwardRightWithRadius: kDriveCommandUseDefaultTurnRadius];
	
}

// Spin Left
- (void)spinLeftWithVelocity: (unsigned) velocity {
	
	if (DEBUG) NSLog(@"Drive command: Spin Left\n");
	
	kDriveCommand command;
	command.type = kDriveCommandType_SpinLeft;
	command.velocity = velocity;
	command.radius = kDriveCommandUseDefaultTurnRadius;
	
	[self sendDriveCommand:command];
	
}

- (void)spinLeft {
	
	[self spinLeftWithVelocity: kDriveCommandUseDefaultVelocity];
	
}

// Spin Right
- (void)spinRightWithVelocity: (unsigned) velocity {
	
	if (DEBUG) NSLog(@"Drive command: Spin Right with velocity: %d\n", velocity);
	
	kDriveCommand command;
	command.type = kDriveCommandType_SpinRight;
	command.velocity = velocity;
	command.radius = kDriveCommandUseDefaultTurnRadius;
	
	[self sendDriveCommand:command];
	
}

- (void)spinRight {
	
	[self spinRightWithVelocity: kDriveCommandUseDefaultVelocity];
	
}

// Stop
- (void)stop {
	
	if (DEBUG) NSLog(@"Drive command: Stop\n");
	
	kDriveCommand command;
	command.type = kDriveCommandType_Stop;
	command.velocity = kDriveCommandUseDefaultVelocity;
	command.radius = kDriveCommandUseDefaultTurnRadius;
	
	[self sendDriveCommand:command];
	
}


#pragma mark ----- Other Actions -----

- (void)beep {
	
	kAuxCommand command;
	command.type = kAuxCommandType_Beep;
	command.argument = 0;
	
	[self sendAuxCommand:command];
	
}

- (void)toggleLEDs {
	
	kAuxCommand command;
	command.type = kAuxCommandType_ToggleLEDs;
	command.argument = 0;
	
	[self sendAuxCommand:command];
	
}

- (void)toggleVacuum {
	
	kAuxCommand command;
	command.type = kAuxCommandType_ToggleVacuum;
	command.argument = 0;
	
	[self sendAuxCommand:command];
	
}

- (void)clean {
	
	kAuxCommand command;
	command.type = kAuxCommandType_Clean;
	command.argument = 0;
	
	[self sendAuxCommand:command];
	
}

- (void)spot {
	
	kAuxCommand command;
	command.type = kAuxCommandType_SpotClean;
	command.argument = 0;
	
	[self sendAuxCommand:command];
	
}

- (void)max {
	
	kAuxCommand command;
	command.type = kAuxCommandType_MaxClean;
	command.argument = 0;
	
	[self sendAuxCommand:command];
	
}

- (void)dock {
	
	kAuxCommand command;
	command.type = kAuxCommandType_Dock;
	command.argument = 0;
	
	[self sendAuxCommand:command];
	
}

- (void)reconnectRoomba {
	
	kAuxCommand command;
	command.type = kAuxCommandType_ReconnectRoomba;
	command.argument = 0;
	
	[self sendAuxCommand:command];
	
}

- (void)runDemo {
	
	kAuxCommand command;
	command.type = kAuxCommandType_RunDemo;
	command.argument = selectedDemo;
	
	[self sendAuxCommand:command];
	
}

- (void)playSong {
	
	kAuxCommand command;
	command.type = kAuxCommandType_PlayASong;
	command.argument = selectedSong;
	
	[self sendAuxCommand:command];
	
}


@end
