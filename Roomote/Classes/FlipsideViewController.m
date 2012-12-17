//
//  FlipsideViewController.m
//  Roomote
//
//  Created by Brian on 1/22/09.
//  Copyright Brian Pratt 2009. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "FlipsideViewController.h"
#import "constants.h"


@implementation FlipsideViewController


@synthesize serverConnectActivityView;
@synthesize songPickerController;
@synthesize demoPickerController;
@synthesize pickerNavigationBar;
@synthesize songPickerView;
@synthesize demoPickerView;
@synthesize selectServerButton;
@synthesize selectDemoButton;
@synthesize selectSongButton;
@synthesize controlTypeSelector;
@synthesize accelUpdateIntervalLabel;
@synthesize accelUpdateIntervalSelector;
@synthesize noTouchBackground;
@synthesize versionLabel;
@synthesize tutorialView;
@synthesize tutorialWebView;


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];
	
	// Set version number to display
	versionLabel.text = [NSString stringWithFormat:@"Roomote Version %@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
	
	// Set up SongPickerController
    SongPickerController *aSongPickerController = [[SongPickerController alloc] init];
	[aSongPickerController setDelegate:self];
	self.songPickerController = aSongPickerController;
    [aSongPickerController release];
	
	// Set up the SongPickerView
	UIPickerView *aSongPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0, kScreenHeightNoStatus-kPickerViewHeight, 320.0, kPickerViewHeight)];
	aSongPickerView.showsSelectionIndicator = YES;
	aSongPickerView.delegate = songPickerController;
	aSongPickerView.dataSource = songPickerController;
	self.songPickerView = aSongPickerView;
	[aSongPickerView release];
	
	// Set up DemoPickerController
    DemoPickerController *aDemoPickerController = [[DemoPickerController alloc] init];
	[aDemoPickerController setDelegate:self];
	self.demoPickerController = aDemoPickerController;
    [aDemoPickerController release];
	
	// Set up the DemoPickerView
	UIPickerView *aDemoPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0, kScreenHeightNoStatus-kPickerViewHeight, 320.0, kPickerViewHeight)];
	aDemoPickerView.showsSelectionIndicator = YES;
	aDemoPickerView.delegate = demoPickerController;
	aDemoPickerView.dataSource = demoPickerController;
	self.demoPickerView = aDemoPickerView;
	[aDemoPickerView release];
    
    // Set up the Picker navigation bar
    UINavigationBar *aNavigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0.0, kScreenHeightNoStatus-kPickerViewHeight-kNavigationBarHeight, 320.0, kNavigationBarHeight)];
    aNavigationBar.barStyle = UIBarStyleBlackOpaque;
    self.pickerNavigationBar = aNavigationBar;
    [aNavigationBar release];
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(removeAllPickerViews)];
    UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:@"Make your selection:"];
    navigationItem.rightBarButtonItem = buttonItem;
    [pickerNavigationBar pushNavigationItem:navigationItem animated:NO];
    [navigationItem release];
    [buttonItem release];
	
	// Set up the Tutorial View
	NSString *tutorialPage = [[NSBundle mainBundle] pathForResource:@"tutorial" ofType: @"html"];
	// Create a URL object.
	NSURL *url = [NSURL fileURLWithPath: tutorialPage isDirectory: NO];
	// URL Requst Object
	NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
	// Load in the WebView
	[self.tutorialWebView loadRequest:requestObj];
}


/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void) viewWillAppear:(BOOL)animated {
	
	// Load control type from saved settings (make the UI element reflect the selection)
	unsigned controTypeIndex = [[NSUserDefaults standardUserDefaults] integerForKey:kControlType];
	controlTypeSelector.selectedSegmentIndex = controTypeIndex;
	
	// Load accel update interval from saved settings (make the UI element reflect the selection)
	if ([[NSUserDefaults standardUserDefaults] objectForKey:kAccelerometerCommandUpdateDelayIndex] == nil) {
		// First run. Must create a value.
		accelUpdateIntervalSelector.selectedSegmentIndex = kDefaultAccelerometerCommandUpdateDelayIndex;
		[[NSUserDefaults standardUserDefaults] setInteger:kDefaultAccelerometerCommandUpdateDelayIndex forKey:kAccelerometerCommandUpdateDelayIndex];
	}
	else {
		accelUpdateIntervalSelector.selectedSegmentIndex = [[NSUserDefaults standardUserDefaults] integerForKey:kAccelerometerCommandUpdateDelayIndex];
	}
	
	// Update view
	if (controlTypeSelector.selectedSegmentIndex == kControlTypeAccelerometer) {
		// Show the slider that controls the accel command update control
		self.accelUpdateIntervalLabel.hidden = NO;
		self.accelUpdateIntervalSelector.hidden = NO;
		self.accelUpdateIntervalLabel.alpha = 1.0;
		self.accelUpdateIntervalSelector.alpha = 1.0;
	}
	else {
		// Hide the slider that controls the accel command update control
		self.accelUpdateIntervalLabel.hidden = YES;
		self.accelUpdateIntervalSelector.hidden = YES;
		self.accelUpdateIntervalLabel.alpha = 0.0;
		self.accelUpdateIntervalSelector.alpha = 0.0;
	}
}


- (void) viewDidAppear:(BOOL)animated {
	
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	
	[serverConnectActivityView release];
	
	[songPickerView release];
	[demoPickerView release];
	
	[songPickerController release];
	[demoPickerController release];
	
	[pickerNavigationBar release];
	[noTouchBackground release];
	
	[selectServerButton release];
	[selectDemoButton release];
	[selectSongButton release];
	[controlTypeSelector release];
	[accelUpdateIntervalLabel release];
	[accelUpdateIntervalSelector release];
	
	[versionLabel release];
	[tutorialView release];
	[tutorialWebView release];
	
	[super dealloc];
}



#pragma mark ----- Accessor Methods -----

- (void) setDelegate:(id)newDelegate {
	delegate = newDelegate;
}

- (void) setRoombaComm:(RoombaComm*)newRoombaComm {
	roombaComm = newRoombaComm;
}



#pragma mark ----- Delegate Methods -----

- (void) setSongNum:(unsigned)songNum {
	// Update choice text
	[self setSelectSongButtonTitle:[songPickerController songName:songNum]];
	
	// Pass along to the RoombaComm object
	[roombaComm setSong:songNum];
}

- (void) setSongNameList:(SongName*)songNameList count:(uint8_t)numSongs {
	// songNames has been malloc'd
	// It will be freed in dealloc()
	[songPickerController setSongNameList:songNameList count:numSongs];
}

- (void) setDemoNum:(unsigned)demoNum {
	// Update choice text
	[self setSelectDemoButtonTitle:[demoPickerController demoName:demoNum]];
	
	// Pass along to the RoombaComm object
	[roombaComm setDemo:demoNum];
}

- (void) setDemoNameList:(DemoName*)demoNameList count:(uint8_t)numDemos {
	// demoNames has been malloc'd
	// It will be freed in dealloc()
	[demoPickerController setDemoNameList:demoNameList count:numDemos];
}

- (void) reloadSongPickerView {
	
	// Reload song list
	//NSLog(@"FVC: Reloading song list...");
	[songPickerView reloadAllComponents];
	
}

- (void) reloadDemoPickerView {
	
	// Reload song list
	//NSLog(@"FVC: Reloading demo list...");
	[demoPickerView reloadAllComponents];
	
}



#pragma mark ----- Interface Builder Actions -----

- (IBAction) toggleView:(id)sender {
	[delegate toggleView];
}

- (IBAction) selectServer:(id)sender {
	// Just pass this on to the RootViewController, who handles the BonjourBrowser
	[delegate selectServer];
}

- (IBAction) connectToServer:(id)sender {
	
	// Get Switch reference
	UISwitch* ConnectToServerSwitch = (UISwitch *)sender;
	BOOL isOn = ConnectToServerSwitch.on;
	
	// Start up the activity indicator
	// TODO: Figure out why this only starts spinning after the function exits
	[serverConnectActivityView startAnimating];
	
	if (isOn == YES) {
		// Switch is on now. Attempt to connect to the specified Roomote Server
		
		sleep(2);
		// Connect failed. Move the switch back to "off"
		[ConnectToServerSwitch setOn:NO animated:YES];
	}
	else {
		// Switch was turned off. Disconnect from the server.
		sleep(1);
		
	}
	
	// Stop the activity indicator
	[serverConnectActivityView stopAnimating];
}

- (IBAction) selectDemo:(id)sender {
	
	// Send out request for updated demo list to server
	NSLog(@"Sending request for demo list\n");
	[roombaComm sendDemoListRequestCommand];
	
	// Customize navigation bar
    UINavigationItem *navigationItem = [pickerNavigationBar popNavigationItemAnimated:NO];
	navigationItem.title = @"Select Demo:";
    [pickerNavigationBar pushNavigationItem:navigationItem animated:NO];
	
	// Pop-up the DemoPickerView
	if (!self.demoPickerView.superview) {
		
		// Create a background to prevent any other touching while the picker is up
		if (!noTouchBackground) {
			//noTouchBackground = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
			noTouchBackground = [[UIView alloc] initWithFrame: CGRectMake(0.0, 0.0, 320.0, kScreenHeightNoStatus)];
			noTouchBackground.backgroundColor = [UIColor blackColor];
			noTouchBackground.opaque = NO;
			noTouchBackground.alpha = 0.0;
		}
		[self.view addSubview:noTouchBackground];
		
		
		[self.view addSubview:demoPickerView];
        [self.view addSubview:pickerNavigationBar];
		
		// Move these subviews off the screen
		pickerNavigationBar.frame = CGRectMake(0.0, kScreenHeightNoStatus, 320.0, kNavigationBarHeight);
		demoPickerView.frame = CGRectMake(0.0, kScreenHeightNoStatus+kNavigationBarHeight, 320.0, kPickerViewHeight);
		
		// Slide them in for a nice effect
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.5];
		demoPickerView.frame = CGRectMake(0.0, kScreenHeightNoStatus-kPickerViewHeight, 320.0, kPickerViewHeight);
		pickerNavigationBar.frame = CGRectMake(0.0, kScreenHeightNoStatus-kPickerViewHeight-kNavigationBarHeight, 320.0, kNavigationBarHeight);
		// Fade in the no-touch background
		noTouchBackground.alpha = 0.5;
		[UIView commitAnimations];
	}
}

- (IBAction) selectSong:(id)sender {
	
	// Send out request for updated song list to server
	NSLog(@"Sending request for song list\n");
	[roombaComm sendSongListRequestCommand];
	
	// Customize navigation bar
    UINavigationItem *navigationItem = [pickerNavigationBar popNavigationItemAnimated:NO];
	navigationItem.title = @"Select Song:";
    [pickerNavigationBar pushNavigationItem:navigationItem animated:NO];
	
	// Pop-up the SongPickerView
	if (!self.songPickerView.superview) {
		
		// Create a background to prevent any other touching while the picker is up
		if (!noTouchBackground) {
			//noTouchBackground = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
			noTouchBackground = [[UIView alloc] initWithFrame: CGRectMake(0.0, 0.0, 320.0, kScreenHeightNoStatus)];
			noTouchBackground.backgroundColor = [UIColor blackColor];
			noTouchBackground.opaque = NO;
			noTouchBackground.alpha = 0.0;
		}
		[self.view addSubview:noTouchBackground];
		
		
		[self.view addSubview:songPickerView];
        [self.view addSubview:pickerNavigationBar];
		
		// Move these subviews off the screen
		pickerNavigationBar.frame = CGRectMake(0.0, kScreenHeightNoStatus, 320.0, kNavigationBarHeight);
		songPickerView.frame = CGRectMake(0.0, kScreenHeightNoStatus+kNavigationBarHeight, 320.0, kPickerViewHeight);
		
		// Slide them in for a nice effect
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.5];
		songPickerView.frame = CGRectMake(0.0, kScreenHeightNoStatus-kPickerViewHeight, 320.0, kPickerViewHeight);
		pickerNavigationBar.frame = CGRectMake(0.0, kScreenHeightNoStatus-kPickerViewHeight-kNavigationBarHeight, 320.0, kNavigationBarHeight);
		// Fade in the no-touch background
		noTouchBackground.alpha = 0.5;
		[UIView commitAnimations];
		
	}
}

- (IBAction) selectControlType:(id)sender {
	// Apply the setting (save to the UserDefaults)
	[[NSUserDefaults standardUserDefaults] setInteger:controlTypeSelector.selectedSegmentIndex forKey:kControlType];
	
	// Update view
	if (controlTypeSelector.selectedSegmentIndex == kControlTypeAccelerometer) {
		// Show the slider that controls the accel command update control
		[UIView beginAnimations:@"showAccelControls" context:NULL];
		[UIView setAnimationDuration: 0.1];
		self.accelUpdateIntervalLabel.hidden = NO;
		self.accelUpdateIntervalSelector.hidden = NO;
		self.accelUpdateIntervalLabel.alpha = 1.0;
		self.accelUpdateIntervalSelector.alpha = 1.0;
		[UIView commitAnimations];
	}
	else {
		// Hide the slider that controls the accel command update control
		[UIView beginAnimations:@"hideAccelControls" context:NULL];
		[UIView setAnimationDelegate: self];
		[UIView setAnimationDidStopSelector: @selector(animationStopped:finished:context:)];
		[UIView setAnimationDuration: 0.1];
		self.accelUpdateIntervalLabel.alpha = 0.0;
		self.accelUpdateIntervalSelector.alpha = 0.0;
		[UIView commitAnimations];
	}

}

- (void) animationStopped: (NSString *)animationID finished: (BOOL) finished context: (void *) context {
	if ([animationID isEqualToString: @"AccelControls"]) {
		// Once the view has faded, hide the view from the user to make sure it doesn't grab the user touches.
		self.accelUpdateIntervalLabel.hidden = YES;
		self.accelUpdateIntervalSelector.hidden = YES;
	}
}

- (IBAction) selectAccelUpdateInterval:(id)sender {
	// Set command update delay based on user selection
	unsigned commandUpdateDelay = kDefaultAccelerometerCommandUpdateDelay;
	unsigned accelCommandUpdateDelayIndex = accelUpdateIntervalSelector.selectedSegmentIndex;
	switch (accelCommandUpdateDelayIndex) {
		case 0:
			// 1 updates/sec
			commandUpdateDelay = 30;
			break;
		case 1:
			// 2 updates/sec
			commandUpdateDelay = 15;
			break;
		case 2:
			// 5 updates/sec
			commandUpdateDelay = 6;
			break;
		case 3:
			// 10 updates/sec
			commandUpdateDelay = 3;
			break;
		case 4:
			// 15 updates/sec
			commandUpdateDelay = 2;
			break;
		case 5:
			// 30 updates/sec
			commandUpdateDelay = 1;
			break;
		default:
			// 2 updates/sec
			commandUpdateDelay = kDefaultAccelerometerCommandUpdateDelay;
			break;
	}
	[[NSUserDefaults standardUserDefaults] setInteger:accelCommandUpdateDelayIndex forKey:kAccelerometerCommandUpdateDelayIndex];
	[[NSUserDefaults standardUserDefaults] setInteger:commandUpdateDelay forKey:kAccelerometerCommandUpdateDelay];

}

- (IBAction) displayTutorial:(id)sender {
	
	// Slide in the TutorialView
	[self.view addSubview: tutorialView];
	tutorialView.frame = CGRectMake(0.0, kScreenHeightNoStatus, 320.0, kScreenHeightNoStatus);
	
    [UIView beginAnimations:nil context:NULL];
	
	// Slide into view
    [UIView setAnimationDuration:0.5];
	tutorialView.frame = CGRectMake(0.0, 0.0, 320.0, kScreenHeightNoStatus);
	
	[UIView commitAnimations];
}

- (IBAction) hideTutorial:(id)sender {
	// User is done with the TutorialView. Slide it off-screen.
	
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
	
	// Slide out of view
	tutorialView.frame = CGRectMake(0.0, kScreenHeightNoStatus, 320.0, kScreenHeightNoStatus);
	
	// Remove the view after it has left the screen
	[NSTimer scheduledTimerWithTimeInterval:0.6 target:tutorialView selector:@selector(removeFromSuperview) userInfo:nil repeats:NO];
	
	[UIView commitAnimations];
}



#pragma mark ----- Helper Methods -----

- (void) removeAllPickerViews {
	
	// Do a nice transition for this
	
	// Move these subviews off the screen
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	
	// For each SubView, schedule the view to be removed from the superview a little after the animation has finished
	
	// Remove the navigation bar
	if (self.pickerNavigationBar.superview) {
		self.pickerNavigationBar.frame = CGRectMake(0.0, kScreenHeightNoStatus, 320.0, kNavigationBarHeight);
		[NSTimer scheduledTimerWithTimeInterval:0.5 target:self.pickerNavigationBar selector:@selector(removeFromSuperview) userInfo:nil repeats:NO];
	}
	
	// Remove the SongPicker and DemoPicker View
	if (self.songPickerView.superview) {
		self.songPickerView.frame = CGRectMake(0.0, kScreenHeightNoStatus, 320.0, kPickerViewHeight);
		[NSTimer scheduledTimerWithTimeInterval:0.5 target:self.songPickerView selector:@selector(removeFromSuperview) userInfo:nil repeats:NO];
	}
	if (self.demoPickerView.superview) {
		self.demoPickerView.frame = CGRectMake(0.0, kScreenHeightNoStatus+kNavigationBarHeight, 320.0, kPickerViewHeight);
		[NSTimer scheduledTimerWithTimeInterval:0.5 target:self.demoPickerView selector:@selector(removeFromSuperview) userInfo:nil repeats:NO];
	}
	
	// Fade out and remove the no-touch background
	if (self.noTouchBackground.superview) {
		[NSTimer scheduledTimerWithTimeInterval:0.5 target:self.noTouchBackground selector:@selector(removeFromSuperview) userInfo:nil repeats:NO];
		noTouchBackground.alpha = 0.0;
	}
	
	[UIView commitAnimations];
	
}

- (void) setSelectServerButtonTitle:(NSString*)newServerText {

	[selectServerButton setTitle:newServerText forState:UIControlStateNormal];
	
}

- (void) setSelectDemoButtonTitle:(NSString*)newDemoText {
	
	[selectDemoButton setTitle:newDemoText forState:UIControlStateNormal];
	
}

- (void) setSelectSongButtonTitle:(NSString*)newSongText {
	
	[selectSongButton setTitle:newSongText forState:UIControlStateNormal];
	
}


@end
