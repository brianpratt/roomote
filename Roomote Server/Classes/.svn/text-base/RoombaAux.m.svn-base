//
//  RoombaAux.m
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

#import "RoombaAux.h"
#import "RTTTLSong.h"


// A class extension to declare private methods and variables
@interface RoombaAux ()

- (void) aTaskDidTerminate:(NSNotification *)notification;
- (void) loadDefaultSongList;
- (BOOL) loadCoreDataSongList;

@end


////////
// Songs

// RTTTL-formatted songs:
NSString *mario = @"smb:d=4,o=5,b=100:16e6,16e6,32p,8e6,16c6,8e6,8g6,8p,8g,8p,8c6,16p,8g,16p,8e,16p,8a,8b,16a#,8a,16g.,16e6,16g6,8a6,16f6,8g6,8e6,16c6,16d6,8b,16p,8c6,16p,8g,16p,8e,16p,8a,8b,16a#,8a,16g.,16e6,16g6,8a6,16f6,8g6,8e6,16c6,16d6,8b,8p,16g6,16f#6,16f6,16d#6,16p,16e6,16p,16g#,16a,16c6,16p,16a,16c6,16d6,8p,16g6,16f#6,16f6,16d#6,16p,16e6,16p,16c7,16p,16c7,16c7,p,16g6,16f#6,16f6,16d#6,16p,16e6,16p,16g#,16a,16c6,16p,16a,16c6,16d6,8p,16d#6,8p,16d6,8p,16c6";
NSString *mario_death = @"smbdeath:d=4,o=5,b=90:32c6,32c6,32c6,8p,16b,16f6,16p,16f6,16f6.,16e6.,16d6,16c6,16p,16e,16p,16c";
NSString *tetris = @"korobyeyniki:d=4,o=5,b=160:e6,8b,8c6,8d6,16e6,16d6,8c6,8b,a,8a,8c6,e6,8d6,8c6,b,8b,8c6,d6,e6,c6,a,2a,8p,d6,8f6,a6,8g6,8f6,e6,8e6,8c6,e6,8d6,8c6,b,8b,8c6,d6,e6,c6,a";
NSString *pink_panther = @"PinkPanther:d=4,o=5,b=160:8d#,8e,2p,8f#,8g,2p,8d#,8e,16p,8f#,8g,16p,8c6,8b,16p,8d#,8e,16p,8b,2a#,2p,16a,16g,16e,16d,2e";
NSString *itchy_scratchy = @"Itchy:d=4,o=5,b=160:8c6,8a,p,8c6,8a6,p,8c6,8a,8c6,8a,8c6,8a6,p,8p,8c6,8d6,8e6,8p,8e6,8f6,8g6,p,8d6,8c6,d6,8f6,a#6,a6,2c7";
NSString *indiana = @"Indiana:d=4,o=5,b=250:e,8p,8f,8g,8p,1c6,8p.,d,8p,8e,1f,p.,g,8p,8a,8b,8p,1f6,p,a,8p,8b,2c6,2d6,2e6,e,8p,8f,8g,8p,1c6,p,d6,8p,8e6,1f.6,g,8p,8g,e.6,8p,d6,8p,8g,e.6,8p,d6,8p,8g,f.6,8p,e6,8p,8d6,2c6";

// Do this at run time now
//#define NUM_SONGS	6
//SongName songNameList[NUM_SONGS] = {{"Mario"}, {"Mario Death"}, {"Tetris"}, {"Pink Panther"}, {"Itchy and Scratchy"}, {"Indiana Jones"}};


////////
// Demos

//NSString *tribble = @"roombacomm.Tribble"; // Args: <roombacomm.jar path> <roombaport>
NSString *bumpturn = @"roombacomm.BumpTurn"; // Args: <roombacomm.jar path> <roombaport>
NSString *sprial = @"roombacomm.Spiral"; // Args: <roombacomm.jar path> <roombaport>
NSString *squares = @"roombacomm.LogoA"; // Args: <roombacomm.jar path> <roombaport>
NSString *waggle = @"roombacomm.Waggle"; // Args: <roombacomm.jar path> <roombaport> <velocity> <radius> <waittime(ms)>

#define	NUM_DEMOS	4
DemoName demoNameList[NUM_DEMOS] = {{"Bump Turn"}, {"Spiral"}, {"Squares"}, {"Waggle"}};



@implementation RoombaAux

@synthesize songList;
@synthesize	demoList;
@synthesize songTask;
@synthesize	demoTask;
@synthesize	songTable;


- (id)init
{
    self = [super init];
	
	// Set up SongList Arrays
	BOOL loaded = [self loadCoreDataSongList];
	// Load the default song list if we can't load core data
	if (!loaded) {
		[self loadDefaultSongList];
	}
	
	// Set up DemoList Array
	self.demoList = [NSArray arrayWithObjects:bumpturn, sprial, squares, waggle, nil];
	
	// Set up tasks
	self.songTask = nil;
	self.demoTask = nil;
	
	// Register for NSTaskDidTerminateNotification
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(aTaskDidTerminate:) name:NSTaskDidTerminateNotification object:nil];

	return self;
}

- (void)awakeFromNib
{
	// user interface preparation code
	
	// create a sort descriptor for the song table
	NSSortDescriptor *nameSort = [[NSSortDescriptor alloc]initWithKey:@"name" ascending:YES];
	// Put the sort descriptor into an array
	NSArray *nameDescriptors = [NSArray arrayWithObject:nameSort];
	// Now set the sort descriptor
	[songTable setSortDescriptors:nameDescriptors];
}
	
- (void)dealloc
{
	self.songList = nil;
	self.demoList = nil;
	
	free(songNameList);
	
	if (demoTask != nil && [demoTask isRunning])
		[demoTask terminate];
	self.demoTask = nil;
	if (songTask != nil && [songTask isRunning])
		[songTask terminate];
	self.songTask = nil;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
    [managedObjectContext release];
    [persistentStoreCoordinator release];
    [managedObjectModel release];
	
	self.songTable = nil;
	
	[super dealloc];
}

- (void) setRoomba:(Roomba*)newRoomba {
	roomba = newRoomba;
}

- (void) setDelegate:(id)newDelegate {
	delegate = newDelegate;
}

- (DemoName*) demoNameList {
	return demoNameList;
}

- (SongName*) songNameList {
	return songNameList;
}

- (uint8_t) getNumDemos {
	return NUM_DEMOS;
}

- (uint8_t) getNumSongs {
	//return NUM_SONGS;
	return numSongs;
}

- (void) runDemo:(uint8_t)demoNum {
	
	// Check if a demo is already running. If so, just stop it and return.
	// TODO: This may not be the most intuitive way of handling this...
	if (demoTask != nil && [demoTask isRunning]) {
		//NSLog(@"Demo already running. Terminating the currently-running demo and doing nothing else.");
		[demoTask terminate];
		
		// Send Roomba the stop command to cut off whatever the demo was doing
        roomba_stop(roomba);
		
		return;
	}
	//NSLog(@"Time to start up a new demo!");

	// Get the Demo launch String
	NSString* demo = [[self demoList] objectAtIndex:demoNum];
	
	// Run the java program to play this song
	NSString *roombaPortPath = [NSString stringWithCString:roomba_get_portpath(roomba) encoding:NSASCIIStringEncoding];
	
	// Set the correct Roomba protocol type
	NSString *roombaProtocol = roomba->is500Series ? @"OI" : @"SCI";
    
    // We construct a path to the JARs that are inside the application package
    NSString *pathToRoombaCommJAR=[NSString stringWithFormat:@"%@%@",[[NSBundle mainBundle] resourcePath],@"/roombacomm.jar"];
    NSString *pathToRXTXcommJAR=[NSString stringWithFormat:@"%@%@",[[NSBundle mainBundle] resourcePath],@"/RXTXcomm.jar"];
	NSString *classpath=[NSString stringWithFormat:@"%@:%@",pathToRoombaCommJAR,pathToRXTXcommJAR];
	NSString *libraryPathArg=[NSString stringWithFormat:@"-Djava.library.path=%@",[[NSBundle mainBundle] resourcePath]];
	
    // If roombacomm.jar doesn't exist inside the application package, then we have a problem; let the user know
    if (![[NSFileManager defaultManager] fileExistsAtPath:pathToRoombaCommJAR])
    {
        NSRunAlertPanel(@"Error",@"roombacomm.jar does not exist inside the Resource folder of the application package.",@"OK",nil,nil);
		return;
    }
	
    // Ok, allocate and initialize a new NSTask
    //NSTask* demoTask=[[NSTask alloc] init];
    self.demoTask=[[NSTask alloc] init];
    
    // Tell the NSTask what the path is to the binary it should launch
    [demoTask setLaunchPath:@"/Library/Java/Home/bin/java"];
	
    // The arguments that we pass to java (in the form of an array)
	if ([demo isEqualToString:waggle])
		[demoTask setArguments:[NSArray arrayWithObjects:libraryPathArg,@"-cp", classpath, demo, roombaPortPath, roombaProtocol, [NSString stringWithFormat:@"%d",roomba->velocity], [NSString stringWithFormat:@"%d",350], [NSString stringWithFormat:@"%d",1000], nil]];
	else
		[demoTask setArguments:[NSArray arrayWithObjects:libraryPathArg,@"-cp", classpath, demo, roombaPortPath, roombaProtocol, nil]];
    
    // Launch the process asynchronously
	NSLog(@"Running demo: %s",demoNameList[demoNum].name);
    [demoTask launch];
	
}

- (void) playSong:(uint8_t)songNum {
	
	// Check if a song is already playing. If so, just stop it and return.
	// TODO: This may not be the most intuitive way of handling this...
	if (songTask != nil && [songTask isRunning]) {
		//NSLog(@"Song already playing. Terminating the currently-running demo and doing nothing else.");
		[songTask terminate];
		
		return;
	}
	//NSLog(@"Time to start up a new demo!");
	
	// Get the RTTTL String
	//NSLog(@"songList: %@",[self songList]);
	NSString* song = [[self songList] objectAtIndex:songNum];
	
	// Run the java program to play this song
	//NSLog(@"Roomba port path: %s", roomba_get_portpath(roomba));
	NSString *roombaPortPath = [NSString stringWithCString:roomba_get_portpath(roomba) encoding:NSASCIIStringEncoding];
	
	// Set the correct Roomba protocol type
	NSString *roombaProtocol = roomba->is500Series ? @"OI" : @"SCI";
    
    // We construct a path to the JARs that are inside the application package
    NSString *pathToRoombaCommJAR=[NSString stringWithFormat:@"%@%@",[[NSBundle mainBundle] resourcePath],@"/roombacomm.jar"];
    NSString *pathToRXTXcommJAR=[NSString stringWithFormat:@"%@%@",[[NSBundle mainBundle] resourcePath],@"/RXTXcomm.jar"];
	NSString *classpath=[NSString stringWithFormat:@"%@:%@",pathToRoombaCommJAR,pathToRXTXcommJAR];
	NSString *libraryPathArg=[NSString stringWithFormat:@"-Djava.library.path=%@",[[NSBundle mainBundle] resourcePath]];
	//NSLog(@"Looking for roombacomm.jar here: %@",pathToJAR);
	
    // If roombacomm.jar doesn't exist inside the application package, then we have a problem; let the user know
    if (![[NSFileManager defaultManager] fileExistsAtPath:pathToRoombaCommJAR])
    {
        NSRunAlertPanel(@"Error",@"roombacomm.jar does not exist inside the Resource folder of the application package.",@"OK",nil,nil);
		return;
    }
	
    // Ok, allocate and initialize a new NSTask
    //NSTask* myTask=[[NSTask alloc] init];
    self.songTask=[[NSTask alloc] init];
    
    // Tell the NSTask what the path is to the binary it should launch
    [songTask setLaunchPath:@"/Library/Java/Home/bin/java"];
    
    // The arguments that we pass to java (in the form of an array)
	NSArray* myArgs = [NSArray arrayWithObjects:libraryPathArg,@"-cp", classpath, @"roombacomm.RTTTLPlay", roombaPortPath, roombaProtocol, song, nil];
	//NSLog(@"myArgs: %@", myArgs);
    [songTask setArguments:myArgs];
    
    // Launch the process asynchronously
	NSLog(@"Playing song: %s",songNameList[songNum].name);
    [songTask launch];
	
}

- (void) aTaskDidTerminate:(NSNotification *)notification {
	NSTask *theTask = [notification object];
	
	//int status = [theTask terminationStatus];
	
	if (theTask == self.songTask) {
		self.songTask = nil;
		[delegate songDidFinish];
	}
	else if (theTask == self.demoTask) {
		self.demoTask = nil;
		[delegate demoDidFinish];
	}
	else {
		NSLog(@"Received unknown task termination notification: %@ %@", [theTask launchPath], [theTask arguments]);
	}

}

- (BOOL) songIsPlaying {
	if (self.songTask == nil)
		return NO;
	else
		return [self.songTask isRunning];
}

- (BOOL) demoIsRunning {
	if (self.demoTask == nil)
		return NO;
	else
		return [self.demoTask isRunning];
}



#pragma mark ---------- Song Loading Helper Methods ----------


- (IBAction) restoreDefaultSongList:(id)sender {
	// Pop-up a diaglog box asking if the user really wants to do this
	NSString *question = @"Empty the current song list and restore the default list?";
	NSString *info = @"Restoring the default song list will delete any songs you have defined or changed.";
	NSString *restoreButton = @"Restore Defaults";
	NSString *cancelButton = @"Cancel";
	
	NSAlert *alert = [NSAlert alertWithMessageText:question defaultButton:restoreButton alternateButton:cancelButton otherButton:nil informativeTextWithFormat:info];
	NSInteger answer = [alert runModal];
	
	if (answer == NSAlertAlternateReturn) return;
	
	[self loadDefaultSongList];
}

- (void) loadDefaultSongList {
	// Set up SongList Array
	self.songList = [NSArray arrayWithObjects:indiana, itchy_scratchy, mario, mario_death, pink_panther, tetris, nil];
	numSongs = 6;
	// Initialize song name list
	songNameList = malloc(sizeof(SongName)*numSongs);
	strcpy(songNameList[0].name, "Indiana Jones");
	strcpy(songNameList[1].name, "Itchy and Scratchy");
	strcpy(songNameList[2].name, "Mario");
	strcpy(songNameList[3].name, "Mario Death");
	strcpy(songNameList[4].name, "Pink Panther");
	strcpy(songNameList[5].name, "Tetris");
	
	//
	// Load these songs into the Core Data list
	//
	// Clear out the old Core Data list
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"RTTTLSong"  
											  inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	NSError *error;
	NSArray *songs = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	[fetchRequest release];
    for (RTTTLSong *aSong in songs) {
		[self.managedObjectContext deleteObject:aSong];
    }
	// Load these new songs
	for (int i=0; i < numSongs; i++) {
		// Step 1: Create Object
		RTTTLSong* newSong = (RTTTLSong *)[NSEntityDescription 
										   insertNewObjectForEntityForName:@"RTTTLSong" 
										   inManagedObjectContext:self.managedObjectContext];
		// Step 2: Set Properties
		[newSong setName: [NSString stringWithCString:songNameList[i].name encoding:NSASCIIStringEncoding]];
		[newSong setSong: [songList objectAtIndex:i]];
	}
	// Step 3: Save Object
	//[self saveSongsAction: self];
}

- (BOOL) loadCoreDataSongList {
	//
	// Load the SongList arrays from the Core Data store
	//
	// Create a FetchRequest to grab all of the song data
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"RTTTLSong"  
											  inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	// Sort the array (based on the song name)
	NSSortDescriptor *nameSort = [[NSSortDescriptor alloc]initWithKey:@"name" ascending:YES];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:nameSort]];

	NSError *error;
	NSArray *songArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	int songCount = [songArray count];
	[fetchRequest release];
	
	// Initialize new song lists
	NSMutableArray* newSongList = [NSMutableArray arrayWithCapacity: songCount];
	numSongs = songCount;
	free(songNameList);
	songNameList = malloc(sizeof(SongName)*numSongs);
	for (int i=0; i < songCount; i++) {
		RTTTLSong* rttlSong = [songArray objectAtIndex: i];
		NSString* songName = rttlSong.name;
		NSString* rttl = rttlSong.song;
		
		[newSongList addObject: rttl];
		strcpy(songNameList[i].name, [songName cStringUsingEncoding:NSASCIIStringEncoding]);
	}
	
	// Replace the current list
	self.songList = newSongList;
	
	if (songCount > 0)
		return YES;
	else
		return NO;

}


#pragma mark ---------- CoreData Stuff ----------

/**
 Returns the support directory for the application, used to store the Core Data
 store file.  This code uses a directory named "RoomoteServer" for
 the content, either in the NSApplicationSupportDirectory location or (if the
 former cannot be found), the system's temporary directory.
 */

- (NSString *)applicationSupportDirectory {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"RoomoteServer"];
}


/**
 Creates, retains, and returns the managed object model for the application 
 by merging all of the models found in the application bundle.
 */

- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel) return managedObjectModel;
	
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.  This 
 implementation will create and return a coordinator, having added the 
 store for the application to it.  (The directory for the store is created, 
 if necessary.)
 */

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {
	
    if (persistentStoreCoordinator) return persistentStoreCoordinator;
	
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSAssert(NO, @"Managed object model is nil");
        NSLog(@"%@:%s No model to generate a store from", [self class], _cmd);
        return nil;
    }
	
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *applicationSupportDirectory = [self applicationSupportDirectory];
    NSError *error = nil;
    
    if ( ![fileManager fileExistsAtPath:applicationSupportDirectory isDirectory:NULL] ) {
		if (![fileManager createDirectoryAtPath:applicationSupportDirectory withIntermediateDirectories:NO attributes:nil error:&error]) {
            NSAssert(NO, ([NSString stringWithFormat:@"Failed to create App Support directory %@ : %@", applicationSupportDirectory,error]));
            NSLog(@"Error creating application support directory at %@ : %@",applicationSupportDirectory,error);
            return nil;
		}
    }
    
    NSURL *url = [NSURL fileURLWithPath: [applicationSupportDirectory stringByAppendingPathComponent: @"songdata"]];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: mom];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSXMLStoreType 
												  configuration:nil 
															URL:url 
														options:nil 
														  error:&error]){
        [[NSApplication sharedApplication] presentError:error];
        [persistentStoreCoordinator release], persistentStoreCoordinator = nil;
        return nil;
    }    
	
    return persistentStoreCoordinator;
}

/**
 Returns the managed object context for the application (which is already
 bound to the persistent store coordinator for the application.) 
 */

- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext) return managedObjectContext;
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator: coordinator];
	
    return managedObjectContext;
}

/**
 Returns the NSUndoManager for the application.  In this case, the manager
 returned is that of the managed object context for the application.
 */

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[self managedObjectContext] undoManager];
}

/**
 Performs the save action for the application, which is to send the save:
 message to the application's managed object context.  Any encountered errors
 are presented to the user.
 */

- (IBAction) saveSongsAction:(id)sender {
	
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%s unable to commit editing before saving", [self class], _cmd);
    }
	
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
	
	//
	// In additon, overwrite the song list arrays, if not coming from an internal call
	//
	if (sender != self)
		[self loadCoreDataSongList];

}


/**
 Implementation of the applicationShouldTerminate: method, used here to
 handle the saving of changes in the application managed object context
 before the application terminates.
 */
// TODO: Call this when the Songs window is closed by the user
- (IBAction) closeSongsWindowAction:(id)sender {
	
    if (!managedObjectContext) return;
	
    if (![managedObjectContext commitEditing]) {
        NSLog(@"%@:%s unable to commit editing to terminate", [self class], _cmd);
        return;
    }
	
    if (![managedObjectContext hasChanges]) return;
	
    NSError *error = nil;
    if (![managedObjectContext save:&error]) {
		
        // This error handling simply presents error information in a panel with an 
        // "Ok" button, which does not include any attempt at error recovery (meaning, 
        // attempting to fix the error.)  As a result, this implementation will 
        // present the information to the user and then follow up with a panel asking 
        // if the user wishes to "Quit Anyway", without saving the changes.
		
        // Typically, this process should be altered to include application-specific 
        // recovery steps.  
		
        BOOL result = [sender presentError:error];
        if (result) return;
		
        NSString *question = NSLocalizedString(@"Could not save changes while quitting.  Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];
		
        NSInteger answer = [alert runModal];
        [alert release];
        alert = nil;
        
        if (answer == NSAlertAlternateReturn) return;
		
    }
	
}


/**
 Implementation of the applicationShouldTerminate: method, used here to
 handle the saving of changes in the application managed object context
 before the application terminates.
 */

/*
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
	
    if (!managedObjectContext) return NSTerminateNow;
	
    if (![managedObjectContext commitEditing]) {
        NSLog(@"%@:%s unable to commit editing to terminate", [self class], _cmd);
        return NSTerminateCancel;
    }
	
    if (![managedObjectContext hasChanges]) return NSTerminateNow;
	
    NSError *error = nil;
    if (![managedObjectContext save:&error]) {
		
        // This error handling simply presents error information in a panel with an 
        // "Ok" button, which does not include any attempt at error recovery (meaning, 
        // attempting to fix the error.)  As a result, this implementation will 
        // present the information to the user and then follow up with a panel asking 
        // if the user wishes to "Quit Anyway", without saving the changes.
		
        // Typically, this process should be altered to include application-specific 
        // recovery steps.  
		
        BOOL result = [sender presentError:error];
        if (result) return NSTerminateCancel;
		
        NSString *question = NSLocalizedString(@"Could not save changes while quitting.  Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];
		
        NSInteger answer = [alert runModal];
        [alert release];
        alert = nil;
        
        if (answer == NSAlertAlternateReturn) return NSTerminateCancel;
		
    }
	
    return NSTerminateNow;
}
*/

@end
