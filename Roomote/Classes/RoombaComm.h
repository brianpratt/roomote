//
//  RoombaComm.h
//  Roomote
//
//  Created by Brian on 2/5/09.
//  Copyright 2009 Brian Pratt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "networking.h"

@class RoombaComm;

@protocol RoombaCommDelegate <NSObject>
@required
- (NSInputStream*) inStream;
- (NSOutputStream*) outStream;
@end

@interface RoombaComm : NSObject {
	
	id<RoombaCommDelegate>		delegate;
	unsigned					selectedDemo;
	unsigned					selectedSong;

}

// Accessor Methods
- (void)setDelegate:(id)newDelegate;
- (void)setSong:(unsigned)songNum;
- (void)setDemo:(unsigned)demoNum;

// Helper Functions
- (void)setVelocity:(unsigned int)velocity;
- (void)setTurnRadius:(unsigned int)turnRadius;

// Networking
- (void)sendDriveCommand:(kDriveCommand)command;
- (void)sendAuxCommand:(kAuxCommand)command;
- (void)sendCustomCommand:(kCustomCommand)command;
- (void)sendDemoListRequestCommand;
- (void)sendSongListRequestCommand;

// Movement Commands
- (void)goForwardWithVelocity: (unsigned) velocity;
- (void)goForward;
- (void)goBackwardWithVelocity: (unsigned) velocity;
- (void)goBackward;
- (void)goForwardLeftWithVelocity: (unsigned) velocity andRadius: (unsigned) turnRadius;
- (void)goForwardLeftWithRadius: (unsigned) turnRadius;
- (void)goForwardLeft;
- (void)goForwardRightWithVelocity: (unsigned) velocity andRadius: (unsigned) turnRadius;
- (void)goForwardRightWithRadius: (unsigned) turnRadius;
- (void)goForwardRight;
- (void)goBackwardLeftWithVelocity: (unsigned) velocity andRadius: (unsigned) turnRadius;
- (void)goBackwardLeftWithRadius: (unsigned) turnRadius;
- (void)goBackwardLeft;
- (void)goBackwardRightWithVelocity: (unsigned) velocity andRadius: (unsigned) turnRadius;
- (void)goBackwardRightWithRadius: (unsigned) turnRadius;
- (void)goBackwardRight;
- (void)spinLeftWithVelocity: (unsigned) velocity;
- (void)spinLeft;
- (void)spinRightWithVelocity: (unsigned) velocity;
- (void)spinRight;
- (void)stop;

// Other Commands
- (void)beep;
- (void)toggleLEDs;
- (void)toggleVacuum;
- (void)clean;
- (void)spot;
- (void)max;
- (void)dock;
- (void)reconnectRoomba;
- (void)runDemo;
- (void)playSong;


@end
