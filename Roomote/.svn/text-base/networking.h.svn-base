/*
 *  networking.h
 *  Roomote Server
 *
 *  Created by Brian on 1/31/09.
 *  Copyright 2009 Brian Pratt. All rights reserved.
 *
 */


//CONSTANTS:

// The Bonjour application protocol, which must:
// 1) be no longer than 14 characters
// 2) contain only lower-case letters, digits, and hyphens
// 3) begin and end with lower-case letter or digit
// It should also be descriptive and human-readable
// See the following for more information:
// http://developer.apple.com/networking/bonjour/faq.html
#define kNetServiceIdentifier		@"roomote"


// MESSAGE TYPES
enum
{
	kNetMessageType_DriveCommand,			// data is a command to drive the Roomba
	kNetMessageType_AuxCommand,				// data is an auxiliary command for the Roomba (beep, LEDs, Vacuum, etc.)
	kNetMessageType_CustomCommand,			// data is a custom command for the Roomba (user-defined)
	kNetMessageType_DemoListRequest,		// command to request that a list of the demo actions be sent
	kNetMessageType_SongListRequest,		// command to request that a list of the songs be sent
	kNetMessageType_DemoList,				// the list of the songs that can be played
	kNetMessageType_SongList,				// the list of the demos that can be run
	kNetMessageType_ConnectionStatus,		// the current status of the connection between the server and the Roomba
};


// DRIVE COMMAND TYPES
#define kDriveCommandUseDefaultVelocity		0	// This velocity means to just use Roomba's current default velocity
#define kDriveCommandUseDefaultTurnRadius	0	// This radius means to just use Roomba's current default turn radius

typedef struct kDriveCommandStruct {
	uint8_t	type;
	uint16_t velocity;
	uint16_t radius;
} kDriveCommand;

union kDriveCommandUnion {
	uint8_t netMessage[5];
	kDriveCommand command;
};

enum
{
	kDriveCommandType_Forward,				// With optional velocity argument
	kDriveCommandType_Backward,				// With optional velocity argument
	kDriveCommandType_Stop,					// 
	kDriveCommandType_ForwardLeft,			// With optional velocity and turn radius arguments
	kDriveCommandType_ForwardRight,			// With optional velocity and turn radius arguments
	kDriveCommandType_BackwardLeft,			// With optional velocity and turn radius arguments
	kDriveCommandType_BackwardRight,		// With optional velocity and turn radius arguments
	kDriveCommandType_SpinLeft,				// With optional velocity argument
	kDriveCommandType_SpinRight,			// With optional velocity argument
	kDriveCommandType_SetVelocity,			// Set a new default velocity for the Roomba
	kDriveCommandType_SetTurnRadius,		// Set a new default turn radius for the Roomba
};


// AUXILIARY COMMAND TYPES
typedef struct kAuxCommandStruct {
	uint8_t	type;
	uint8_t argument;
} kAuxCommand;

union kAuxCommandUnion {
	uint8_t netMessage[2];
	kAuxCommand command;
};

enum
{
	kAuxCommandType_Beep,					// 
	kAuxCommandType_ToggleLEDs,				// 
	kAuxCommandType_ToggleVacuum,			// 
	kAuxCommandType_Clean,					// 
	kAuxCommandType_SpotClean,				// 
	kAuxCommandType_MaxClean,				// 
	kAuxCommandType_Dock,					// 
	kAuxCommandType_ReconnectRoomba,		// Attempt to restore the connection to the Roomba
	kAuxCommandType_PlayASong,				// With argument of the song number to play
	kAuxCommandType_RunDemo,				// With argument of the demo to run
};


// CUSTOM COMMAND
#define MAX_CUSTOM_COMMAND_LENGTH			25
#define MAX_CUSTOM_COMMAND_PACKET_LENGTH	MAX_CUSTOM_COMMAND_LENGTH+1

// First byte is the length of the command that follows (starting at the second byte)
typedef uint8_t kCustomCommand[MAX_CUSTOM_COMMAND_PACKET_LENGTH];


// SONG AND DEMO LISTS
#define MAX_SONG_NAME_LEN				25
#define MAX_DEMO_NAME_LEN				25

typedef struct SongNameStruct {
	char name[MAX_SONG_NAME_LEN];
} SongName;

typedef struct DemoNameStruct {
	char name[MAX_DEMO_NAME_LEN];
} DemoName;


// ROOMBA CONNECTION STATUS
#define ROOMBA_CONNECTION_ACTIVE			1
#define ROOMBA_CONNECTION_INACTIVE			2
#define ROOMBA_CONNECTION_SONG_PLAYING		3
#define ROOMBA_CONNECTION_SONG_NOT_PLAYING	4
#define ROOMBA_CONNECTION_DEMO_RUNNING		5
#define ROOMBA_CONNECTION_DEMO_NOT_RUNNING	6

