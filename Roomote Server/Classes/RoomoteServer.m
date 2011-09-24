//
//  RoomoteServer.m
//  Roomote Server
//
//  This is the main Roomote Server class. It's job is to talk with the Roomote
//  iPhone client and relay commands to the Roomba.
//  The TCP Server code is based on a sample project from Apple.
//  The Roomba communication is handled by Tod Kurt's roombalib.
//  This code would be much cleaner if it were broken up a bit into separate
//  classes for each function!
//
//  Created by Brian on 1/22/09.
//  Copyright 2009-2010 Brian Pratt. All rights reserved.
//
//  This software is free software; you can redistribute it and/or
//  modify it under the terms of the GNU General Public
//  License as published by the Free Software Foundation; either
//  version 3 of the License, or (at your option) any later version.
//
//  This software is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
//  Lesser General Public License for more details.
//
//  You should have received a copy of the GNU Lesser General
//  Public License along with this library; if not, write to the
//  Free Software Foundation, Inc., 59 Temple Place, Suite 330,
//  Boston, MA  02111-1307  USA
//

#import "RoomoteServer.h"

// imports required for socket initialization
#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>

#include "roombaaux.h"

// Number of times to fail a connection check before doing anything about it
#define MAX_FAILED_CONNECTION_CHECKS		3
// In seconds
#define CONNECTION_TIMER_UPDATE_INTERVAL	4.0



// A class extension to declare private methods and variables
@interface RoomoteServer ()

// Networking
- (void) setupServer;
- (void) stopServer;
- (void) openStreams;
- (void) shutdownStreams;
- (void) serverDidEnableBonjour:(TCPServer*)server withName:(NSString*)name;
- (void) server:(TCPServer*)server didNotEnableBonjour:(NSDictionary *)errorDict;
- (void) serverDidDisableBonjour:(TCPServer*)server;
- (void) didAcceptConnectionForServer:(TCPServer*)server inputStream:(NSInputStream *)istr outputStream:(NSOutputStream *)ostr;

// Roomba connection
- (void) connectToRoomba;
- (void) disconnectRoomba;
- (void) initRoombaConnectionCheckTimer;
- (void) disableRoombaConnectionCheckTimer;

// Roomba control functions
- (void)reset;
- (void)beep;
- (void)ledsOn;
- (void)ledsOff;
- (void)toggleLEDs;
- (void)toggleVacuum;
- (void)playSong:(uint8_t)songNum;
- (void)runDemo:(uint8_t)demoNum;
- (void)handleDriveCommand:(kDriveCommand)command;
- (void)handleAuxCommand:(kAuxCommand)command;
- (void)handleCustomCommand:(kCustomCommand)command;
- (void)handleDemoListRequest;
- (void)handleSongListRequest;
- (void)sendRoombaConnectionStatus: (uint8_t) status;

@end



@implementation RoomoteServer

@synthesize roombaAux;
@synthesize serverStatusTextShort;
@synthesize serverStatusTextLong;
@synthesize roombaPortMenu;
@synthesize serverStartStopButton;
@synthesize roombaConnectDisconnectButton;
@synthesize serverStartStopStatus;
@synthesize roombaConnectDisconnectStatus;
@synthesize roombaTestStatus;
@synthesize helpTextView;

static NSString* noPortSelected = @"-select port-";

BOOL needToSendDemoList = YES;
BOOL needToSendSongList = YES;
BOOL needToSendConnectionStatus = YES;

BOOL server_debug = NO;


- (id)init
{
    self = [super init];
	
	// Instantiate the RoombaAux object
	// This should be done by Interface Builder now
	//roombaAux = [[RoombaAux alloc] init];
	//[roombaAux setDelegate: self];
	
	// Set up GUI defaults
	roomba500Series = YES;
	rootoothFirefly = YES;
	
	// Set up random number generator
	srand(time(0));
	
	// Set up timer parameters
	connectionCheckTimerUpdateInterval = CONNECTION_TIMER_UPDATE_INTERVAL; // seconds
	
    return self;
}

- (void)dealloc
{
	// Disconnect if still connected
	if (roomba != NULL) {
        roomba_stop(roomba);
		roomba_free(roomba);
		roomba = NULL;
		NSLog(@"Disconnected from Roomba");
	}
	
	[roombaAux release];
	[serverStatusTextShort release];
	[serverStatusTextLong release];
	[roombaPortMenu release];
	[serverStartStopButton release];
	[roombaConnectDisconnectButton release];
	[serverStartStopStatus release];
	[roombaConnectDisconnectStatus release];
	[roombaTestStatus release];
	[helpTextView release];
	
	[self stopServer];
	
	[inStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
	[inStream release];
	
	[outStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
	[outStream release];
	
	[tcpServer release];
	
	
    [super dealloc];
}

// Initialization Code
- (void)awakeFromNib
{
	// Initialize array of serial ports
    NSMutableArray *ports = [NSMutableArray arrayWithCapacity:10];
    [ports addObject:noPortSelected];
    // Find all serial ports that start with /dev/tty.
    NSLog(@"Finding serial ports...\n");
    NSString *file;
    NSDirectoryEnumerator *dirEnum = 
		[[NSFileManager defaultManager] enumeratorAtPath:@"/dev"];
    while (file = [dirEnum nextObject]) {
        if( [file hasPrefix: @"tty."] ) {
            [ports addObject:file];
            NSLog(@"found file: %@\n",file);
        }
    }
	// Sort them
    NSArray *sortedPorts =
	[ports sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
	// Add this list of ports to the pull-down menu
	[roombaPortMenu addItemsWithTitles:sortedPorts];
	
	// Set up Help TextView
	NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
	NSString *helpFilePath = [thisBundle pathForResource:@"help" ofType:@"rtfd"];
	[self.helpTextView readRTFDFromFile: helpFilePath];

}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
	NSLog(@"Got applicationShouldTerminate. Shutting everything down...\n");

	// Disconnect if still connected
	if (roomba != NULL) {
        roomba_stop(roomba);
		roomba_free(roomba);
		NSLog(@"Disconnected from Roomba");
	}
	
	[self stopServer];
	
	[inStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
	[inStream release];
	
	[outStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
	[outStream release];
	
	[tcpServer release];
	
	return NSTerminateNow;
	
}

// Called when the last window (not panel) is closed
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
	//NSLog(@"Got applicationShouldTerminateAfterLastWindowClosed\n");
	// Once this returns, applicationShouldTerminate will be called
	return YES;
}




///////////////
// Networking


#pragma mark ____ NETWORKING - TCP Server ____


- (void) setupServer {
	
	NSLog(@"Starting up TCP server and Bonjour advertising");
	
	//uint16_t serverPortInt = [serverPort intValue];
	
	NSString *serviceName = [NSString stringWithFormat:@"Server on %@", 
							 [[NSProcessInfo processInfo] hostName]];
	//NSString *serviceName = [[NSProcessInfo processInfo] hostName];
	
	[tcpServer release];
	tcpServer = nil;
	
	[inStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[inStream release];
	inStream = nil;
	inReady = NO;
	
	[outStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[outStream release];
	outStream = nil;
	outReady = NO;
	
	tcpServer = [TCPServer new];
	[tcpServer setDelegate:self];
	NSError* error;
	if(tcpServer == nil || ![tcpServer start:&error]) {
		NSLog(@"Failed creating server: %@", error);
		//[self _showAlert:@"Failed creating server"];
		return;
	}
	
	//Start advertising to clients, passing nil for the name to tell Bonjour to pick use default name
	if(![tcpServer enableBonjourWithDomain:@"local" applicationProtocol:[TCPServer bonjourTypeFromIdentifier:kNetServiceIdentifier] name:serviceName]) {
		//[self _showAlert:@"Failed advertising server"];
		return;
	}
	
}

- (void) stopServer {
	
	// Close streams
	NSLog(@"Closing streams");
	[self shutdownStreams];
	
	// Stop server
	NSLog(@"Stopping TCP Server");
	[tcpServer stop];
	
    [serverStartStopButton setTitle:@"Start Server"];
    [serverStatusTextShort setStringValue:@"Server is off"];
    [serverStatusTextLong setStringValue:@"Click Start Server to turn on the server and allow a Roomote client to connect."];
	
	// Stop the status indicator
	[serverStartStopStatus stopAnimation:self];
	
}



#pragma mark ____ NETWORKING - Bonjour ____

- (void) serverDidEnableBonjour:(TCPServer*)server withName:(NSString*)string {
	NSLog(@"Bonjour advertising enabled");
	
    [serverStartStopButton setTitle:@"Stop Server"];
    [serverStatusTextShort setStringValue:@"Server is on"];
    [serverStatusTextLong setStringValue:@"Click Stop Server to turn off Server."];
	
	// Stop the status indicator
	[serverStartStopStatus stopAnimation:self];
}

- (void) server:(TCPServer*)server didNotEnableBonjour:(NSDictionary *)errorDict {
	NSLog(@"Bonjour advertising was not enabled");
	
    // Display some meaningful error message here, using the longerStatusText as the explanation.
    [serverStartStopButton setTitle:@"Start Server"];
    [serverStatusTextShort setStringValue:@"Server is off"];
    if([[errorDict objectForKey:NSNetServicesErrorCode] intValue] == NSNetServicesCollisionError) {
        [serverStatusTextLong setStringValue:@"A name collision occurred. A service is already running with that name someplace else."];
    } else {
        [serverStatusTextLong setStringValue:@"Some other unknown error occurred."];
    }
	
	// Stop the status indicator
	[serverStartStopStatus stopAnimation:self];
}

- (void) serverDidDisableBonjour:(TCPServer*)server {
	NSLog(@"Bonjour advertising disabled");
	
	// TODO: Find out if this should be called after a client connects?
	/*
    [serverStartStopButton setTitle:@"Start Server"];
    [serverStatusTextShort setStringValue:@"Server is off"];
    [serverStatusTextLong setStringValue:@"Click Start Server to turn on the server and allow a Roomote client to connect."];
	
	// Stop the status indicator
	[serverStartStopStatus stopAnimation:self];
	 */
}


#pragma mark ____ NETWORKING - Streams ____


- (void)openStreams {
	
    [inStream setDelegate:self];
    [outStream setDelegate:self];
	
    [inStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	
    [inStream open];
    [outStream open];
	
    NSLog(@"Connected to client");
}

- (void)shutdownStreams {
	
    [inStream close];
    [outStream close];
	
	inReady = NO;
	outReady = NO;
	
    [inStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	
    [inStream setDelegate:nil];
    [outStream setDelegate:nil];
	
    [inStream release];
    [outStream release];
	
    inStream = nil;
	outStream = nil;
	
    NSLog(@"Connection to client closed");
}

- (void) didAcceptConnectionForServer:(TCPServer*)server inputStream:(NSInputStream *)istr outputStream:(NSOutputStream *)ostr
{
	NSLog(@"TCP Server accepted connection");
	
	if (inStream || outStream || server != tcpServer)
		return;
	
	[tcpServer release];
	tcpServer = nil;
	
	inStream = istr;
	[inStream retain];
	outStream = ostr;
	[outStream retain];
	
	[self openStreams];
}

- (void) stream:(NSStream*)stream handleEvent:(NSStreamEvent)eventCode
{
	//NSLog(@"NSStreamEvent encountered");
	
	switch(eventCode) {
		case NSStreamEventOpenCompleted:
		{
			//NSLog(@"\tNSStreamEventOpenCompleted encountered");
			if (stream == inStream)
				inReady = YES;
			else
				outReady = YES;
			
			if (inReady && outReady) {
				[serverStatusTextLong setStringValue:@"Connected to Roomote client.\nClick Stop Server to turn off Server."];
				NSLog(@"Client connected successfully!\n");
				//NSLog(@"Forcing song and demo list send");
				//[self handleSongListRequest];
				//[self handleDemoListRequest];
			}
			break;
		}
		case NSStreamEventHasBytesAvailable:
		{
			//NSLog(@"\tNSStreamEventHasBytesAvailable encountered");
			if (stream == inStream) {
				uint8_t byte;
				unsigned int len = 0;
				len = [inStream read:&byte maxLength:sizeof(uint8_t)];
				if(!len) {
					if ([stream streamStatus] != NSStreamStatusAtEnd)
						NSLog(@"Failed reading data from Roomote client\n");
				} else {
					// Read the byte to determine the type of command received
					switch(byte) {
						case kNetMessageType_DriveCommand:
							if (server_debug) NSLog(@"Drive command received from Roomote client\n");
							
							union kDriveCommandUnion driveCommandUnion;
							len = [inStream read:driveCommandUnion.netMessage maxLength:sizeof(driveCommandUnion)];
							if(len != sizeof(driveCommandUnion)) {
								if ([stream streamStatus] != NSStreamStatusAtEnd)
									NSLog(@"Failed reading drive command data from Roomote client\n");
							}
							else {
								kDriveCommand command = driveCommandUnion.command;
								if (server_debug) NSLog(@"\tDrive Command: %u, %d, %d\n",command.type,command.velocity,command.radius);
								// Send command on to be executed
								[self handleDriveCommand:command];
							}
							break;
						case kNetMessageType_AuxCommand:
							if (server_debug) NSLog(@"Auxiliary command received from Roomote client\n");
							
							union kAuxCommandUnion auxCommandUnion;
							len = [inStream read:auxCommandUnion.netMessage maxLength:sizeof(auxCommandUnion)];
							if(len != sizeof(auxCommandUnion)) {
								if ([stream streamStatus] != NSStreamStatusAtEnd)
									NSLog(@"Failed reading auxiliary command data from Roomote client\n");
							}
							else {
								kAuxCommand command = auxCommandUnion.command;
								if (server_debug) NSLog(@"\tAuxiliary Command: %u, %u\n",command.type,command.argument);
								// Send command on to be executed
								[self handleAuxCommand:command];
							}
							break;
						case kNetMessageType_CustomCommand:
							if (server_debug) NSLog(@"Custom SCI command received from Roomote client\n");
							
							//union kCustomCommandUnion customCommandUnion;
							//len = [inStream read:customCommandUnion.netMessage maxLength:sizeof(customCommandUnion)];
							kCustomCommand command;
							len = [inStream read:command maxLength:sizeof(kCustomCommand)];
							if(len != sizeof(kCustomCommand)) {
								if ([stream streamStatus] != NSStreamStatusAtEnd)
									NSLog(@"Failed reading custom SCI command data from Roomote client\n");
							}
							else {
								if (server_debug) NSLog(@"\tCustom Command length: %u\n",command[0]);
								// Send command on to be executed
								[self handleCustomCommand:command];
							}
							break;
						case kNetMessageType_DemoListRequest:
							if (server_debug) NSLog(@"Demo List Request command received from Roomote client\n");
							[self handleDemoListRequest];
							break;
						case kNetMessageType_SongListRequest:
							if (server_debug) NSLog(@"Song List Request command received from Roomote client\n");
							[self handleSongListRequest];
							break;
						default:
							NSLog(@"Unknown command received from Roomote client:%d\n", byte);
					}
					
				}
			}
			break;
		}
		case NSStreamEventEndEncountered:
		{
			//NSLog(@"\tNSStreamEventEndEncountered encountered");
			
			[serverStatusTextLong setStringValue:@"Roomote client disconnected.\nClick Stop Server to turn off Server."];
			NSLog(@"Connection to Roomote client closed\n");
			
			// Close and release the stream
			[self shutdownStreams];
			
			// Start up the server again
			[self setupServer];
			
			// Reset state variables
			needToSendDemoList = YES;
			needToSendSongList = YES;
			needToSendConnectionStatus = YES;
			
			break;
		}
        case NSStreamEventHasSpaceAvailable:
			//NSLog(@"\tNSStreamEventHasSpaceAvailable encountered");
			/*
			if (inReady && outReady) {
				if (needToSendSongList == YES) {
					NSLog(@"Retrying Song List send");
					[self handleSongListRequest];
				} // Only send one at a time
				else if (needToSendDemoList == YES) {
					NSLog(@"Retrying Demo List send");
					[self handleDemoListRequest];
				} // Only send one at a time
				else if (needToSendConnectionStatus == YES) {
					NSLog(@"Retrying Connection Status send");
					[self sendConnectionStatus: ???];
				}
			}
			*/
            break;
        case NSStreamEventErrorOccurred:
			//NSLog(@"\tNSStreamEventErrorOccurred encountered");
            break;
        case NSStreamEventNone:
			//NSLog(@"\tNSStreamEventNone encountered");
            break;
        default:
            break;
	}
}


#pragma mark ____ ROOMBA CONNECTION HELPER METHODS ____


- (void) connectToRoomba {
	// Grab the selected port
	NSString* portname = [roombaPortMenu titleOfSelectedItem];
	if([portname isEqual:noPortSelected]) {
		// Let the user know that he should select a serial port
		NSRunAlertPanel([NSString stringWithFormat:
						 @"No Roomba Port Selected"], 
						[NSString stringWithFormat:
						 @"Please select a port with which to connect to Roomba"], @"OK",nil,nil);
		// Couldn't connect. Reset the connect button state and stop the status indicator.
		[roombaConnectDisconnectButton setTitle:@"Connect"];
		[roombaConnectDisconnectStatus stopAnimation:self];
		return;
	}
	NSString* portpath = [NSString stringWithFormat:@"/dev/%@",portname];
	const char* cportpath = [portpath UTF8String];
	
	// Try to connect to the selected port
	roomba = roomba_init(cportpath, roomba500Series, rootoothFirefly);
	if (roomba != NULL) {
		// Connection to Roomba successful
		
		// Make the Roomba beep to show that it's working. (The green light should also turn off)
		roomba_play_note(roomba, 64, 15);
		[roombaConnectDisconnectButton setTitle:@"Disconnect"];
		NSLog(@"Connected to Roomba\n");
		
		// Give the RoombaAux object a pointer to this roomba
		[roombaAux setRoomba:roomba];
		
		// Clear out the read buffer after connecting
		roomba_clear_read_buf(roomba);
		
		// Set up timer to periodically check roomba connection
		[self initRoombaConnectionCheckTimer];
	}
	else {
		// Connection to Roomba unsuccessfull
		NSRunAlertPanel([NSString stringWithFormat:
						 @"The roomba port '%s' could not be opened",cportpath], 
						[NSString stringWithFormat:
						 @"%s",strerror(errno)], @"OK",nil,nil);
		NSLog(@"Failed to connect to Roomba on %s\n", cportpath);
		
		// Couldn't connect. Reset the connect button state.
		[roombaConnectDisconnectButton setTitle:@"Connect"];
	}
	
}

- (void) checkRoombaConnection {
	static unsigned failed_connection_count = 0;
	
	// Check the connection to the Roomba
	if (roomba == NULL) {
		// I don't think this should happen, so I'd like to know if it does
		NSLog(@"WARNING: Checking the roomba connection with no roomba available");
		return;
	}
	int sensor_read_status = roomba_read_sensors(roomba);
	if (server_debug) roomba_print_sensors(roomba);
	int mode = roomba_read_mode(roomba);
	if (server_debug) NSLog(@"mode: %d",mode);
	if (sensor_read_status == 0 && (mode == SAFE_MODE || mode == FULL_MODE)) {
		// Successful sensor read. Connection is active and Roomba is not in Passive Mode.
		// Reset failed connection check count
		failed_connection_count = 0;
	}
	else {
		// Failed to read the Roomba's sensors or Roomba is in a mode that we cannot command.
		// For our purposes, the connection is dead (or Roomba is temporarily out of range).
		failed_connection_count++;
		
		// Could just be out of sync (unexpected bytes in the queue)
		// Clear the buffer
		roomba_clear_read_buf(roomba);
		
		if (failed_connection_count >= MAX_FAILED_CONNECTION_CHECKS) {
			// Assume connection is dead
			NSLog(@"Connection to Roomba lost");
			
			// Destroy connection on this end
			[self disconnectRoomba];
			
			// Notify user?
			//NSRunAlertPanel(@"Connection Lost", 
			//				@"Cannot communicate with Roomba", @"OK",nil,nil);
			
			// Notify Roomote
			[self sendRoombaConnectionStatus: ROOMBA_CONNECTION_INACTIVE];
			
			// Reset failed connection check count
			failed_connection_count = 0;
		}
	}
		
}

- (void) initRoombaConnectionCheckTimer {
	// Set up timer to periodically check roomba connection
	connectionCheckTimer = [NSTimer scheduledTimerWithTimeInterval:connectionCheckTimerUpdateInterval target:self selector:@selector(checkRoombaConnection) userInfo:nil repeats:YES];
}

- (void) disableRoombaConnectionCheckTimer {
	// Stop checking the connection
	[connectionCheckTimer invalidate];
	connectionCheckTimer = nil;
}

- (void) disconnectRoomba {
	if (roomba != NULL) {
		roomba_free(roomba);
		roomba = NULL;
	}
	NSLog(@"Disconnected from Roomba");
	[roombaConnectDisconnectButton setTitle:@"Connect"];
	
	// Stop checking the connection to the Roomba
	[self disableRoombaConnectionCheckTimer];
}



#pragma mark ____ ROOMBAAUX DELEGATE METHODS ____


- (void) demoDidFinish {
	// Restart the connection check timer
	if (![roombaAux songIsPlaying] && ![roombaAux demoIsRunning])
		[self initRoombaConnectionCheckTimer];
	// Notify Roomote
	[self sendRoombaConnectionStatus: ROOMBA_CONNECTION_DEMO_NOT_RUNNING];
}

- (void) songDidFinish {
	// Restart the connection check timer
	if (![roombaAux songIsPlaying] && ![roombaAux demoIsRunning])
		[self initRoombaConnectionCheckTimer];
	// Notify Roomote
	[self sendRoombaConnectionStatus: ROOMBA_CONNECTION_SONG_NOT_PLAYING];
}


///////////////
// GUI Actions

#pragma mark ____ GUI ACTIONS ____


- (IBAction)serverStartStop:(id)sender
{
	// Start up status indicator
	[serverStartStopStatus startAnimation:self];
    
	
	if([[sender title] isEqual:@"Start Server"]) {
		// Start up the server
		[self setupServer];
	}
	else {
		// Server was running, so try and stop it
		[self stopServer];
	}
    
}

- (IBAction)roombaConnectDisconnect:(id)sender
{
	// Start up status indicator
	[roombaConnectDisconnectStatus startAnimation:self];
	
	// Check state of the connect button
	if ([[sender title] isEqual:@"Connect"]) {
		// Attempt to connect to the Roomba
		[self connectToRoomba];
	} else {
		// User asked to shut down the connection
		[self disconnectRoomba];
	}
	
	// Stop the status indicator
	[roombaConnectDisconnectStatus stopAnimation:self];
}

- (IBAction)testRoombaConnection:(id)sender
{
	// Start up status indicator
	[roombaTestStatus startAnimation:self];
	
	int i;
	
	/*
	// DEBUG: Check mode status reads
	roomba_clear_read_buf(roomba);
	int mode = roomba_read_mode(roomba);
	NSLog(@"Starting mode: %d", mode);
	// Enter Full Mode
	roomba_full(roomba);
	roomba_delay(1000);
	mode = roomba_read_mode(roomba);
	NSLog(@"Full mode: %d", mode);
	// Enter Passive Mode
	roomba_start(roomba);
	roomba_delay(1000);
	mode = roomba_read_mode(roomba);
	NSLog(@"Passive mode: %d", mode);
	// Enter Safe Mode
	roomba_safe(roomba);
	roomba_delay(1000);
	mode = roomba_read_mode(roomba);
	NSLog(@"Safe mode: %d", mode);
	*/
	
    // Run a short demo
	if (roomba != NULL) {
		[self beep];
		roomba_delay(100);
		for(i=0;i<3;i++) {
			[self ledsOn];
			roomba_delay(250);
			[self ledsOff];
			roomba_delay(250);
		}
		roomba_spinleft(roomba);
		roomba_delay(1000);
        roomba_stop(roomba);
		roomba_spinright(roomba);
		roomba_delay(1000);
        roomba_stop(roomba);
		for(i=0;i<3;i++) {
			[self ledsOn];
			roomba_delay(250);
			[self ledsOff];
			roomba_delay(250);
		}
		[self beep];
		roomba_delay(100);
	}
	
	// Stop the status indicator
	[roombaTestStatus stopAnimation:self];
}

- (IBAction)toggleRoomba500Series:(id)sender {
	NSButton *button = sender;
	roomba500Series = ([button state] == NSOnState);
}

- (IBAction)toggleRootoothFirefly:(id)sender {
	NSButton *button = sender;
	rootoothFirefly = ([button state] == NSOnState);
}


///////////////////
// Roomba Control Functions

#pragma mark ____ ROOMBA CONTROL FUNCTIONS ____

// Play a random note
- (void)beep
{
    if(roomba!=NULL) {
        int note = (rand() % 36) + 48;
        roomba_play_note(roomba, note, 10);
    }
}

// Turn on all the LEDs
// Set the power LED to a random color
- (void)ledsOn
{
	int color = rand() % 256;
    if(roomba!=NULL)
		roomba_set_leds(roomba, 1,1,1,1,1,1, color,255);
}

// Turn off all the LEDs
- (void)ledsOff
{
    if(roomba!=NULL)
		roomba_set_leds(roomba, 0,0,0,0,0,0, 0,0);
}

// Toggle LEDs
- (void)toggleLEDs
{
	static BOOL ledState = NO;
	if (ledState == NO) {
		[self ledsOn];
		ledState = YES;
	}
	else {
		[self ledsOff];
		ledState = NO;
	}
}

// Toggle Vacuum
- (void)toggleVacuum
{
	static BOOL vacuumState = NO;
	
	if (roomba!=NULL) {
		if (vacuumState == NO) {
			roomba_vacuum(roomba, 1);
			vacuumState = YES;
		}
		else {
			roomba_vacuum(roomba, 0);
			vacuumState = NO;
		}
	}
}

// This command starts the default cleaning mode.
- (void)clean
{	
	if (roomba!=NULL)
		roomba_clean(roomba);
}

// This command starts the Max cleaning mode.
- (void)max
{	
	if (roomba!=NULL)
		roomba_max(roomba);
}

// This command starts the Spot cleaning mode.
- (void)spot
{	
	if (roomba!=NULL)
		roomba_spot(roomba);
}

// This command sends Roomba to the dock.
- (void)dock
{	
	if (roomba!=NULL)
		roomba_dock(roomba);
}

// Play one of the pre-set songs
- (void)playSong:(uint8_t)songNum
{
	// Disable connection checks while song is playing (to avoid missing notes due to excess commands)
	[self disableRoombaConnectionCheckTimer];
	
	// Play song
	[roombaAux playSong:songNum];
	
	// Notify Roomote
	[self sendRoombaConnectionStatus: ROOMBA_CONNECTION_SONG_PLAYING];
}

// Run one of the pre-set demos
- (void)runDemo:(uint8_t)demoNum
{
	// Disable connection checks while demo is running
	[self disableRoombaConnectionCheckTimer];
	
	// Run Demo
	[roombaAux runDemo:demoNum];
	
	// Notify Roomote
	[self sendRoombaConnectionStatus: ROOMBA_CONNECTION_DEMO_RUNNING];
}

// Reset the Roomba connection
- (void)reset
{
	/*
    if(roomba!=NULL) {
        roomba_stop(roomba);
        const char* portpath = roomba_get_portpath(roomba);
        roomba_free(roomba);
        roomba = roomba_init(portpath, roomba500Series, rootoothFirefly);
		
		// Clear out the read buffer after connecting
		roomba_clear_read_buf(roomba);
    }
	else {
		[self connectToRoomba];
	}
	*/
	[self disconnectRoomba];
	[self connectToRoomba];
}


// Handle a Drive Command
- (void)handleDriveCommand:(kDriveCommand)command {
	static BOOL firstAlertPanel = YES;
	
	// Check for a valid Roomba
	if (!roomba_valid(roomba)) {
		if (firstAlertPanel) {
			// Pop up a warning, but only once per session
			firstAlertPanel = NO;
			NSRunAlertPanel(@"Cannot execute command from client", 
							@"Connection to Roomba is not active", @"OK",nil,nil);
		}
		return;
	}
	
	// Get velocity
	uint16_t velocity;
	if (command.velocity == kDriveCommandUseDefaultVelocity)
		velocity = roomba_get_velocity(roomba);
	else
		velocity = command.velocity;
	
	// Get turn radius
	uint16_t turnRadius;
	if (command.radius == kDriveCommandUseDefaultTurnRadius)
		turnRadius = 500; // This seems like a nice default
	else
		turnRadius = command.radius;
	
	if (server_debug) NSLog(@"Drive Command with velocity: %d and turn radius: %d", velocity, turnRadius);

	// Send command to Roomba
	switch (command.type) {
		case kDriveCommandType_Forward:
			roomba_forward_at(roomba, velocity);
			break;
		case kDriveCommandType_Backward:
			roomba_backward_at(roomba, velocity);
			break;
		case kDriveCommandType_Stop:
			roomba_stop(roomba);
			break;
		case kDriveCommandType_ForwardLeft:
			roomba_drive(roomba, velocity, turnRadius);
			break;
		case kDriveCommandType_ForwardRight:
			roomba_drive(roomba, velocity, -turnRadius);
			break;
		case kDriveCommandType_BackwardLeft:
			roomba_drive(roomba, -velocity, turnRadius);
			break;
		case kDriveCommandType_BackwardRight:
			roomba_drive(roomba, -velocity, -turnRadius);
			break;
		case kDriveCommandType_SpinLeft:
			roomba_spinleft_at(roomba, velocity);
			break;
		case kDriveCommandType_SpinRight:
			roomba_spinright_at(roomba, velocity);
			break;
		case kDriveCommandType_SetVelocity:
			roomba_set_velocity(roomba, command.velocity);
			break;
		case kDriveCommandType_SetTurnRadius:
			// TODO: Decide whether to implement this or not. Not sure it's necessary...
			//roomba_set_turn_radius(roomba, command.radius);
			NSLog(@"Setting turn radius not yet supported.");
			break;
		default:
			NSLog(@"Unknown drive command received:%@",command.type);
			break;
	}

}

// Handle an Auxiliary Command
- (void)handleAuxCommand:(kAuxCommand)command {
	
	static BOOL firstAlertPanel = YES;
	
	// Check for a valid Roomba
	if (!roomba_valid(roomba) && command.type != kAuxCommandType_ReconnectRoomba) {
		if (firstAlertPanel) {
			// Pop up a warning, but only once per session
			firstAlertPanel = NO;
			NSRunAlertPanel(@"Cannot execute command from client", 
							@"Connection to Roomba is not active", @"OK",nil,nil);
		}
		return;
	}
	
	switch (command.type) {
		case kAuxCommandType_Beep:
			[self beep];
			break;
		case kAuxCommandType_ToggleLEDs:
			[self toggleLEDs];
			break;
		case kAuxCommandType_ToggleVacuum:
			[self toggleVacuum];
			break;
		case kAuxCommandType_Clean:
			[self clean];
			break;
		case kAuxCommandType_SpotClean:
			[self spot];
			break;
		case kAuxCommandType_MaxClean:
			[self max];
			break;
		case kAuxCommandType_Dock:
			[self dock];
			break;
		case kAuxCommandType_ReconnectRoomba:
			// TODO: Check for connection before calling disconnect?
			[self disconnectRoomba];
			// TODO: Insert a pause here?
			[self connectToRoomba];
			break;
		case kAuxCommandType_PlayASong:
			[self playSong:command.argument];
			break;
		case kAuxCommandType_RunDemo:
			[self runDemo:command.argument];
			break;
		default:
			break;
	}
	
}

// Handle a Custom Command
- (void)handleCustomCommand:(kCustomCommand)command {
	
	static BOOL firstAlertPanel = YES;
	
	// Check for a valid Roomba
	if (!roomba_valid(roomba)) {
		if (firstAlertPanel) {
			// Pop up a warning, but only once per session
			firstAlertPanel = NO;
			NSRunAlertPanel(@"Cannot execute command from client", 
							@"Connection to Roomba is not active", @"OK",nil,nil);
		}
		return;
	}
	
	// First byte is the length of the command that follows (starting at the second byte)
	int length = command[0];
	uint8_t* payload = &command[1];
	
	if (roomba!=NULL)
		roomba_send(roomba, payload, (length > MAX_CUSTOM_COMMAND_LENGTH)?MAX_CUSTOM_COMMAND_LENGTH:length);
	
	
}

// Handle a Demo List Request
- (void)handleDemoListRequest {
	DemoName* demoNameList = [roombaAux demoNameList];
	uint8_t numDemos = [roombaAux getNumDemos];
	
	// Build up command with header and data
	NSMutableData* netMessage = [[NSMutableData data] retain];
	uint8_t messageType = (uint8_t)kNetMessageType_DemoList;
	[netMessage appendBytes:&messageType length:sizeof(uint8_t)];
	[netMessage appendBytes:&numDemos length:sizeof(uint8_t)];
	[netMessage appendBytes:demoNameList length:sizeof(DemoName)*numDemos];
	
	// Send message to client
	if (outStream) {
		if ([outStream hasSpaceAvailable] == NO) {
			NSLog(@"Outstream was not available. Reqesting that the demo list be sent when space is available.\n");
			needToSendDemoList = YES;
		}
		else {
			if([outStream write:[netMessage mutableBytes] maxLength:[netMessage length]] != [netMessage length])
				NSLog(@"Failed sending demo list to client\n");
			else
				needToSendDemoList = NO;
		}
	}
	else
		NSLog(@"Failed sending demo list to client. Outstream was not available.\n");
}

// Handle a Song List Request
- (void)handleSongListRequest {
	SongName* songNameList = [roombaAux songNameList];
	uint8_t numSongs = [roombaAux getNumSongs];
	
	// Build up command with header and data
	NSMutableData* netMessage = [[NSMutableData data] retain];
	uint8_t messageType = (uint8_t)kNetMessageType_SongList;
	[netMessage appendBytes:&messageType length:sizeof(uint8_t)];
	[netMessage appendBytes:&numSongs length:sizeof(uint8_t)];
	[netMessage appendBytes:songNameList length:sizeof(SongName)*numSongs];
	
	// Send message to client
	if (outStream) {
		if ([outStream hasSpaceAvailable] == NO) {
			NSLog(@"Outstream was not available. Reqesting that the song list be sent when space is available.\n");
			needToSendSongList = YES;
		}
		else {
			if([outStream write:[netMessage mutableBytes] maxLength:[netMessage length]] != [netMessage length])
				NSLog(@"Failed sending song list to client\n");
			else
				needToSendSongList = NO;
		}
	}
	else
		NSLog(@"Failed sending song list to client. Outstream was not available.\n");
	
}

// Send connection status to Roomote
- (void)sendRoombaConnectionStatus: (uint8_t) status {
	
	// Build up command with header and data (just type byte and status byte)
	uint8_t netMessage[2];
	netMessage[0] = kNetMessageType_ConnectionStatus;
	netMessage[1] = status;
	
	// Send message to client
	if (outStream) {
		if ([outStream hasSpaceAvailable] == NO) {
			NSLog(@"Outstream was not available. Reqesting that the Roomba connection status be sent when space is available.\n");
			needToSendConnectionStatus = YES;
		}
		else {
			if([outStream write:netMessage maxLength:sizeof(netMessage)] != sizeof(netMessage))
				NSLog(@"Failed sending Roomba connection status to client\n");
			else
				needToSendConnectionStatus = NO;
		}
	}
	else
		NSLog(@"Failed sending Roomba connection status to client. Outstream was not available.\n");
	
}


@end
