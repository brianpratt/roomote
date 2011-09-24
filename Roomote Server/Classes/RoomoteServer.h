//
//  RoomoteServer.h
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


#import <Cocoa/Cocoa.h>
#import "roombalib.h"
#import "RoombaAux.h"
#import "TCPServer.h"
#import "networking.h"


@interface RoomoteServer : NSObject <TCPServerDelegate, RoombaAuxDelegate> {
    Roomba*         roomba;
	
	IBOutlet RoombaAux*				roombaAux;
	
    IBOutlet NSTextField*			serverStatusTextShort;
    IBOutlet NSTextField*			serverStatusTextLong;
    IBOutlet NSPopUpButton*			roombaPortMenu;
	IBOutlet NSButton*				serverStartStopButton;
	IBOutlet NSButton*				roombaConnectDisconnectButton;
	IBOutlet NSProgressIndicator*	serverStartStopStatus;
	IBOutlet NSProgressIndicator*	roombaConnectDisconnectStatus;
	IBOutlet NSProgressIndicator*	roombaTestStatus;
    IBOutlet NSTextView*			helpTextView;
	
	// Check Roomba connection timer
    NSTimer *connectionCheckTimer;
    NSTimeInterval connectionCheckTimerUpdateInterval;
	
	TCPServer*			tcpServer;
	NSData*				clientAddress;
	NSInputStream*		inStream;
	NSOutputStream*		outStream;
	BOOL				inReady;
	BOOL				outReady;
	
	BOOL				roomba500Series;
	BOOL				rootoothFirefly;
}

// IB Outlets
@property (nonatomic, retain, readonly) IBOutlet RoombaAux*				roombaAux;
@property (nonatomic, retain, readonly) IBOutlet NSTextField*			serverStatusTextShort;
@property (nonatomic, retain, readonly) IBOutlet NSTextField*			serverStatusTextLong;
@property (nonatomic, retain, readonly) IBOutlet NSPopUpButton*			roombaPortMenu;
@property (nonatomic, retain, readonly) IBOutlet NSButton*				serverStartStopButton;
@property (nonatomic, retain, readonly) IBOutlet NSButton*				roombaConnectDisconnectButton;
@property (nonatomic, retain, readonly) IBOutlet NSProgressIndicator*	serverStartStopStatus;
@property (nonatomic, retain, readonly) IBOutlet NSProgressIndicator*	roombaConnectDisconnectStatus;
@property (nonatomic, retain, readonly) IBOutlet NSProgressIndicator*	roombaTestStatus;
@property (nonatomic, retain, readonly) IBOutlet NSTextView*			helpTextView;

- (void)awakeFromNib;

// GUI Actions
- (IBAction)serverStartStop:(id)sender;
- (IBAction)roombaConnectDisconnect:(id)sender;
- (IBAction)testRoombaConnection:(id)sender;
- (IBAction)toggleRoomba500Series:(id)sender;
- (IBAction)toggleRootoothFirefly:(id)sender;

@end
