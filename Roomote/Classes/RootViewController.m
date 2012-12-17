//
//  RootViewController.m
//  Roomote
//
//  Created by Brian on 1/22/09.
//  Copyright Brian Pratt 2009. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "RootViewController.h"
#import "MainViewController.h"
#import "FlipsideViewController.h"
#import "constants.h"


// A class extension to declare private methods and variables
@interface RootViewController ()

- (void) handleDemoListMessage:(DemoName*)demoNameList count:(uint8_t)numDemos;
- (void) handleSongListMessage:(SongName*)songNameList count:(uint8_t)numSongs;
- (void) handleRoombaConnectionStatus:(uint8_t) status;

@end


@implementation RootViewController

@synthesize infoButton;
@synthesize	roombaComm;
@synthesize mainViewController;
@synthesize flipsideViewController;
@synthesize bonjourBrowser;
@synthesize noTouchBackground;

@synthesize outStream;


#pragma mark ____ ALERT VIEW METHODS ____

- (void) showNetworkingAlert:(NSString*)title
{
	UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:@"Check your networking configuration." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alertView show];
	[alertView release];
}

// If we display an error or an alert that the remote disconnected, handle dismissal and return to setup
- (void) alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if ([alertView.title isEqualToString:@"Connection to Roomba Lost"]) {
		if (buttonIndex == 1) {
			// User wishes to attempt to reconnect to the Roomba
			// Send a message to the server to that effect
			[roombaComm reconnectRoomba];
		}
	}
	else if ([alertView.message isEqualToString:@"Check your networking configuration."]) {
		[self setupNetworking];
	}
}


#pragma mark ____ ACCESSOR METHODS ____

- (NSInputStream*)inStream {
	return inStream;
}

- (NSOutputStream*)outStream {
	return outStream;
}


#pragma mark ____ VIEW LOADING AND UNLOADING ____

- (void)viewDidLoad {
    
    [super viewDidLoad];
	
	// Set up RoombaComm object
	RoombaComm *newRoombaComm = [[RoombaComm alloc] init];
	self.roombaComm = newRoombaComm;
	[newRoombaComm release];
	[self.roombaComm setDelegate:self];
	
	// Set up MainView
    MainViewController *viewController = nil;
    if ([[UIScreen mainScreen] bounds].size.height == 568 && [[UIScreen mainScreen] scale] == 2.0)
        viewController = [[MainViewController alloc] initWithNibName:@"MainView-568h" bundle:nil];
    else
        viewController = [[MainViewController alloc] initWithNibName:@"MainView" bundle:nil];
    self.mainViewController = viewController;
    [viewController release];
	self.mainViewController.roombaComm = self.roombaComm;
	
	// Increase the size of Info Button's frame to make it easier to touch
	//infoButton.bounds = CGRectMake(0.0, 0.0, 25.0, 25.0);
	//infoButton.bounds = CGRectMake(0.0, 0.0, 50.0, 50.0);
	//infoButton.frame = CGRectMake(250.0, 400.0, 50.0, 50.0);
	//infoButton.center = CGPointMake(275.0, 425.0);
    
    [self.view insertSubview:mainViewController.view belowSubview:infoButton];
	
	// Load the FlipsideView so we have access to the elements there
	[self loadFlipsideViewController];
	
	// Switch to the flipsideView right away
	[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(toggleView) userInfo:nil repeats:NO];
	// Pop-up the Bonjour Browser right away to select a server
	// TODO: Do this at [flipsideView viewDidLoad] any time no server connection is available
	//[NSTimer scheduledTimerWithTimeInterval:1.75 target:self selector:@selector(setupNetworking) userInfo:nil repeats:NO];
}


- (void)loadFlipsideViewController {
    
    FlipsideViewController *viewController = nil;
    if ([[UIScreen mainScreen] bounds].size.height == 568 && [[UIScreen mainScreen] scale] == 2.0)
        viewController = [[FlipsideViewController alloc] initWithNibName:@"FlipsideView-568h" bundle:nil];
    else
        viewController = [[FlipsideViewController alloc] initWithNibName:@"FlipsideView" bundle:nil];
    self.flipsideViewController = viewController;
    [viewController release];
	
	// Set this as the delegate
	[self.flipsideViewController setDelegate:self];
	[self.flipsideViewController setRoombaComm:self.roombaComm];
}


- (IBAction)toggleView {    
    /*
     This method is called when the info or Done button is pressed.
     It flips the displayed view from the main view to the flipside view and vice-versa.
     */
    if (flipsideViewController == nil) {
        [self loadFlipsideViewController];
    }
    
    UIView *mainView = mainViewController.view;
    UIView *flipsideView = flipsideViewController.view;
	
	static float animationDuration = 1.0;
    
    if ([mainView superview] != nil) {
		// Flip from MainView to FlipsideView
		// Set up flip animation
		[UIView beginAnimations:@"showFlipsideView" context:NULL];
		[UIView setAnimationDuration:animationDuration];
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:YES];
		[UIView setAnimationDelegate: self];
		[UIView setAnimationDidStopSelector: @selector(animationStopped:finished:context:)];
		
        [flipsideViewController viewWillAppear:YES];
        [mainViewController viewWillDisappear:YES];
        [mainView removeFromSuperview];
        [infoButton removeFromSuperview];
        [self.view addSubview:flipsideView];
        //[mainViewController viewDidDisappear:YES];
        //[flipsideViewController viewDidAppear:YES];
    } else {
		// Flip from FlipsideView to MainView
		// Set up flip animation
		[UIView beginAnimations:@"showMainView" context:NULL];
		[UIView setAnimationDuration:animationDuration];
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:YES];
		[UIView setAnimationDelegate: self];
		[UIView setAnimationDidStopSelector: @selector(animationStopped:finished:context:)];
		
        [mainViewController viewWillAppear:YES];
        [flipsideViewController viewWillDisappear:YES];
        [flipsideView removeFromSuperview];
        [self.view addSubview:mainView];
        [self.view insertSubview:infoButton aboveSubview:mainViewController.view];
        //[flipsideViewController viewDidDisappear:YES];
        //[mainViewController viewDidAppear:YES];
    }
    [UIView commitAnimations];
}

- (void) animationStopped: (NSString *)animationID finished: (BOOL) finished context: (void *) context {
	// Animation callback to let the respective ViewControllers know when the animation has finished.
	if (animationID == @"showFlipsideView") {
        [mainViewController viewDidDisappear:YES];
        [flipsideViewController viewDidAppear:YES];
		
		// Need to connect to a server, if not connected currently
		// To not annoy the user, only do this once
		static BOOL firstTime = YES;
		if (firstTime && ![self networkingReady]) {
			firstTime = NO;
			[self setupNetworking];
		}
	}
	else if (animationID == @"showMainView") {
        [flipsideViewController viewDidDisappear:YES];
		[mainViewController viewDidAppear:YES];
	}
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [infoButton release];
    [mainViewController release];
    [flipsideViewController release];
	
	[inStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
	[inStream release];
	
	[outStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
	[outStream release];
	
    [super dealloc];
}



#pragma mark ____ NETWORKING ____

// Make sure to let the user know what name is being used for Bonjour advertisement.
// This way, other players can browse for and connect to this game.
// Note that this may be called while the alert is already being displayed, as
// Bonjour may detect a name conflict and rename dynamically.
- (void) presentBonjourBrowser:(NSString*)name {
	if (!bonjourBrowser) {
		//bonjourBrowser = [[BonjourBrowser alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] type:kServiceType];
		//bonjourBrowser = [[BonjourBrowser alloc] initWithFrame:CGRectMake(0.0, kScreenHeightNoStatus-kPickerViewHeight-kNavigationBarHeight, 320.0, 260.0) type:kServiceType];
		// Initialize the Picker off the screen
		bonjourBrowser = [[BonjourBrowser alloc] initWithFrame:CGRectMake(0.0, kScreenHeight, 320.0, 260.0) type:kServiceType];
		[bonjourBrowser setDelegate:self];
	}
	
	if (!bonjourBrowser.superview) {
		
		// Create a background to prevent any other touching while the picker is up
		if (!noTouchBackground) {
			noTouchBackground = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, kScreenHeight)];
			noTouchBackground.backgroundColor = [UIColor blackColor];
			noTouchBackground.opaque = NO;
			noTouchBackground.alpha = 0.0;
		}
		[self.view addSubview:noTouchBackground];
		
		
		[self.view addSubview:bonjourBrowser];
		
		// Slide it in for a nice effect
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.5];
		bonjourBrowser.frame = CGRectMake(0.0, kScreenHeightNoStatus-kPickerViewHeight-kNavigationBarHeight, 320.0, 260.0);
		// Fade in the no-touch background
		noTouchBackground.alpha = 0.5;
		[UIView commitAnimations];
		 
	}
}

- (void) destroyBonjourBrowser {
	//[bonjourBrowser removeFromSuperview];
	
	// Do a nice transition
	
	// Slide the picker off the screen
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	bonjourBrowser.frame = CGRectMake(0.0, kScreenHeight, 320.0, 260.0);
	// Fade out the no-touch background
	noTouchBackground.alpha = 0.0;
	
	// Completely remove it from the superview after the animation
	[NSTimer scheduledTimerWithTimeInterval:0.5 target:self.bonjourBrowser selector:@selector(removeFromSuperview) userInfo:nil repeats:NO];
	[NSTimer scheduledTimerWithTimeInterval:0.5 target:self.noTouchBackground selector:@selector(removeFromSuperview) userInfo:nil repeats:NO];
	
	[UIView commitAnimations];
	
	[bonjourBrowser autorelease];
	bonjourBrowser = nil;
	[noTouchBackground autorelease];
	noTouchBackground = nil;
}

- (void) selectServer {
	// FlipsideView will call this when the server selection button is pushed
	[self setupNetworking];
}

// Send a single byte
- (void) send:(const uint8_t)message
{
	if (outStream && [outStream hasSpaceAvailable])
		if([outStream write:(const uint8_t *)&message maxLength:sizeof(const uint8_t)] == -1)
			[self showNetworkingAlert:@"Failed sending data to peer"];
}

- (void) openStreams
{
	[inStream retain];
	[outStream retain];
	
	inStream.delegate = self;
	outStream.delegate = self;
	
	[inStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[outStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	
	[inStream open];
	[outStream open];
}

- (void) closeStreams
{
	inReady = NO;
	outReady = NO;
	
    [inStream close];
    [outStream close];
	
    [inStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	
    [inStream setDelegate:nil];
    [outStream setDelegate:nil];
	
    [inStream release];
    [outStream release];
	
    inStream = nil;
    outStream = nil;
}

- (void) setupNetworking {
	/*
	 [inStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	 [inStream release];
	 inStream = nil;
	 inReady = NO;
	 
	 [outStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	 [outStream release];
	 outStream = nil;
	 outReady = NO;
	 */
	
	// Close any old connection
	[self closeStreams];
	
	// Present new connection options to the user
	[self presentBonjourBrowser:nil];
}

- (BOOL) networkingReady {
	// TODO: Do some kind of check to make sure there is a working connection
	// Right now, this just checks that it was working at some point
	if (inReady && outReady)
		return YES;
	else
		return NO;
}


- (void) bonjourBrowser:(BonjourBrowser*)browser didResolveInstance:(NSNetService*)netService
{
	//[self showAlert:@"didResolveInstance"];
	
	if (!netService) {
		//[self showAlert:@"call setupNetworking"];
		//[self setupNetworking];
		// User cancelled operation (or couldn't connect?)
		[self destroyBonjourBrowser];
		return;
	}
    
    if (inStream && outStream) {
		//[self showAlert:@"call closeStreams"];
        [self closeStreams];
    }
	
	if (![netService getInputStream:&inStream outputStream:&outStream]) {
		[self showNetworkingAlert:@"Failed to connect to server"];
		return;
	}
	
	// Update Flipside GUI with name of server
	[flipsideViewController setSelectServerButtonTitle:[netService name]];
	
	//[self showAlert:@"call openStreams"];
	[self openStreams];
	
	//[self showAlert:@"didResolveInstance done"];
}


- (void) handleSongListMessage:(SongName*)songNameList count:(uint8_t)numSongs {
	// songNames has been malloc'd
	NSLog(@"Got song list message with %u songs in it.",numSongs);
	//for (int i=0; i < numSongs; i++) {
	//	NSLog(@"\t%s",songNameList[i].name);
	//}
	
	[flipsideViewController setSongNameList:songNameList count:numSongs];
	
}

- (void) handleDemoListMessage:(DemoName*)demoNameList count:(uint8_t)numDemos {
	// demoNames has been malloc'd
	NSLog(@"Got demo list message with %u demos in it.",numDemos);
	//for (int i=0; i < numDemos; i++) {
	//	NSLog([NSString stringWithFormat:@"\t%s",demoNameList[i].name]);
	//}
	
	[flipsideViewController setDemoNameList:demoNameList count:numDemos];
}

- (void) handleRoombaConnectionStatus: (uint8_t) status {
	switch (status) {
		case ROOMBA_CONNECTION_INACTIVE:
			NSLog(@"Connection between Roomba and Server was lost.");
			// Notify user and offer to attempt to re-connect
			UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Connection to Roomba Lost" message:@"The connection between the Roomote Server and the Roomba was lost. Attempt to reconnect?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Reconnect",nil];
			[alertView show];
			[alertView release];
			break;
		case ROOMBA_CONNECTION_DEMO_RUNNING:
			NSLog(@"Roomba demo running.");
			// Show demo running notification?
			[mainViewController demoRunning: YES];
			break;
		case ROOMBA_CONNECTION_DEMO_NOT_RUNNING:
			NSLog(@"Roomba demo ended.");
			// Dismiss demo running notification?
			[mainViewController demoRunning: NO];
			break;
		case ROOMBA_CONNECTION_SONG_PLAYING:
			NSLog(@"Roomba song playing.");
			// Show song playing notification?
			[mainViewController songPlaying: YES];
			break;
		case ROOMBA_CONNECTION_SONG_NOT_PLAYING:
			NSLog(@"Roomba song ended.");
			// Dismiss song playing notification?
			[mainViewController songPlaying: NO];
			break;
		default:
			break;
	}
}

- (void) stream:(NSStream*)stream handleEvent:(NSStreamEvent)eventCode
{
	//NSLog(@"NSStreamEvent encountered");
	
	UIAlertView* alertView;
	switch(eventCode) {
		case NSStreamEventOpenCompleted:
		{
			//NSLog(@"\tNSStreamEventOpenCompleted encountered");
			[self destroyBonjourBrowser];
			
			if (stream == inStream)
				inReady = YES;
			else
				outReady = YES;
			
			if (inReady && outReady) {
				// Connection is up and running
				// Request song and demo lists
				NSLog(@"Connection Successful\n");
				// Alert user
				alertView = [[UIAlertView alloc] initWithTitle:@"Connection Successful!" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Continue", nil];
				[alertView show];
				[alertView release];
				// TODO: Figure out why these don't get to the server:
				//NSLog(@"Sending requests for song list and demo list\n");
				//[roombaComm sendSongListRequestCommand];
				//[roombaComm sendDemoListRequestCommand];
			}
			
			break;
		}
		case NSStreamEventHasBytesAvailable:
		{
			//NSLog(@"\tNSStreamEventHasBytesAvailable encountered");
			if (stream == inStream) {
				uint8_t byte;
				uint8_t numDemos;
				uint8_t numSongs;
				uint8_t status;
				unsigned int len = 0;
				len = [inStream read:&byte maxLength:sizeof(uint8_t)];
				if(!len) {
					if ([stream streamStatus] != NSStreamStatusAtEnd) {
						//[self showAlert:@"Failed reading data from Roomote server"];
						NSLog(@"Failed reading data from Roomote server\n");
					}
				} else {
					// Read the byte to determine the type of message received
					switch(byte) {
						case kNetMessageType_DemoList:
							// the list of the demos that can be run
							//NSLog(@"Receiving Demo List...\n");
							
							// Get size of data to read
							len = [inStream read:&numDemos maxLength:sizeof(uint8_t)];
							if(!len) {
								if ([stream streamStatus] != NSStreamStatusAtEnd) {
									NSLog(@"Failed reading demo list size from Roomote server\n");
								}
							} else {
								NSMutableData* data = [[NSMutableData data] retain];
								// Grab all the bytes waiting for us
								uint8_t buf[1024];
								int bytesLeftToRead = numDemos*sizeof(DemoName);
								while ([inStream hasBytesAvailable]) {
									int bytesToRead = (bytesLeftToRead > 1024)?1024:bytesLeftToRead;
									len = [(NSInputStream *)stream read:buf maxLength:bytesToRead];
									if(len) {
										[data appendBytes:(const void *)buf length:len];
										//[bytesRead setIntValue:[bytesRead intValue]+len];
										bytesLeftToRead -= len;
									} else {
										NSLog(@"Couldn't read any DemoList data!");
									}
								}
								// Convert data to an array of DemoName structs
								DemoName* demoNames = malloc(sizeof(DemoName)*numDemos);
								memcpy(demoNames, [data mutableBytes], sizeof(DemoName)*numDemos);
								
								//NSLog(@"Demo List received from Roomote server\n");
								[self handleDemoListMessage:demoNames count:numDemos];
							}
							break;
						case kNetMessageType_SongList:
							// the list of the songs that can be played
							//NSLog(@"Receiving Song List...\n");
							
							// Get size of data to read
							len = [inStream read:&numSongs maxLength:sizeof(uint8_t)];
							if(!len) {
								if ([stream streamStatus] != NSStreamStatusAtEnd) {
									NSLog(@"Failed reading song list size from Roomote server\n");
								}
							} else {
								NSMutableData* data = [[NSMutableData data] retain];
								// Grab all the bytes waiting for us
								uint8_t buf[1024];
								int bytesLeftToRead = numSongs*sizeof(SongName);
								while ([inStream hasBytesAvailable]) {
									int bytesToRead = (bytesLeftToRead > 1024)?1024:bytesLeftToRead;
									len = [(NSInputStream *)stream read:buf maxLength:bytesToRead];
									if(len) {
										[data appendBytes:(const void *)buf length:len];
										//[bytesRead setIntValue:[bytesRead intValue]+len];
										bytesLeftToRead -= len;
									} else {
										NSLog(@"Couldn't read any SongList data!");
									}
								}
								// Convert data to an array of DemoName structs
								SongName* songNames = malloc(sizeof(SongName)*numSongs);
								memcpy(songNames, [data mutableBytes], sizeof(SongName)*numSongs);
								
								//NSLog(@"Song List received from Roomote server\n");
								[self handleSongListMessage:songNames count:numSongs];
							}
							break;
						case kNetMessageType_ConnectionStatus:
							// the current status of the connection between the server and the Roomba
							//NSLog(@"Receiving Roomba connection status...\n");
							
							// Get the connection status byte
							len = [inStream read:&status maxLength:sizeof(uint8_t)];
							if(!len) {
								if ([stream streamStatus] != NSStreamStatusAtEnd) {
									NSLog(@"Failed reading Roomba connection status from Roomote server\n");
								}
							} else {
								//NSLog(@"Roomba connection staus received from Roomote server\n");
								[self handleRoombaConnectionStatus:status];
							}
							break;
						default:
							NSLog(@"Unknown command received from Roomote client:%d\n",byte);
					}
				}
			}
			break;
		}
		case NSStreamEventEndEncountered:
		{
			//NSLog(@"\tNSStreamEventEndEncountered encountered");
			[self showNetworkingAlert:@"Connection to server lost"];
            [self closeStreams];
			
			break;
		}
        case NSStreamEventHasSpaceAvailable:
			//NSLog(@"\tNSStreamEventHasSpaceAvailable encountered");
            break;
        case NSStreamEventErrorOccurred:
			//NSLog(@"\tNSStreamEventErrorOccurred encountered");
            break;
        case NSStreamEventNone:
			//NSLog(@"\tNSStreamEventNone encountered");
            break;
        default:
			//NSLog(@"\tUnknown event encountered");
            break;
	}
}


@end
