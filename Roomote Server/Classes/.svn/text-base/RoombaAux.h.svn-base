//
//  RoombaAux.h
//  Roomote Server
//
//  The purpose of this class is to use the external Java RoombaComm libraries
//  to run Demos and play Songs on the Roomba.
//  It uses a Core Data to let the user customize the songs that are available.
//  RoombaComm is available here: http://hackingroomba.com/code/roombacomm/
//  and here: http://www.dprg.org/projects/2009-07a/
//
//  Created by Brian on 2/3/09.
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
#import <AppKit/NSWindow.h>
#import "roombalib.h"
#include "networking.h"

@class RoombaAux;


@protocol RoombaAuxDelegate

@required
- (void) demoDidFinish;
- (void) songDidFinish;

@end


@interface RoombaAux : NSObject {
	
    Roomba*		roomba;
	
	id<RoombaAuxDelegate>	delegate;
	
	// Core Data
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
	
	IBOutlet NSTableView *songTable;

@private
    NSArray*	demoList;
    NSArray*	songList;
	
	SongName*	songNameList;
	unsigned	numSongs;
	
    NSTask*		demoTask;
    NSTask*		songTask;

}

@property (nonatomic, retain) NSArray *songList;
@property (nonatomic, retain) NSArray *demoList;
@property (nonatomic, retain) NSTask *songTask;
@property (nonatomic, retain) NSTask *demoTask;

// Core Data
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) IBOutlet NSTableView *songTable;


- (IBAction) saveSongsAction:(id)sender;
- (IBAction) closeSongsWindowAction:(id)sender;
- (IBAction) restoreDefaultSongList:(id)sender;


- (DemoName*) demoNameList;
- (SongName*) songNameList;
- (uint8_t) getNumDemos;
- (uint8_t) getNumSongs;

- (void) setRoomba:(Roomba*)newRoomba;
- (void) setDelegate:(id)newDelegate;

- (void) runDemo:(uint8_t)demoNum;
- (void) playSong:(uint8_t)songNum;

- (BOOL) songIsPlaying;
- (BOOL) demoIsRunning;


@end
