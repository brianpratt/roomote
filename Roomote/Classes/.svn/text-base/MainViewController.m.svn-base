//
//  MainViewController.m
//  Roomote
//
//  Created by Brian on 1/22/09.
//  Copyright Brian Pratt 2009. All rights reserved.
//

#import "MainViewController.h"
#import "MainView.h"
#import "ButtonControlViewController.h";
#import "SwipeControlViewController.h";
#import "AccelerometerControlViewController.h";
#import "UserDefaults.h"


// A class extension to declare private methods and variables
@interface MainViewController ()

unsigned velocity = DEFAULT_VELOCITY;

@end



@implementation MainViewController

@synthesize roombaComm;
@synthesize velocityLabel;
@synthesize velocitySlider;
@synthesize controlView;
@synthesize controlViewController;
@synthesize scrollView;
@synthesize customCommandEditViewController;
@synthesize demoButton;
@synthesize singButton;
@synthesize customButton1;
@synthesize customButton2;
@synthesize customButton3;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		
		// Load control type from saved settings
		// (will be set to zero if there is no saved setting)
		currentControlType = -1; // Since this will not match, setControlType will be sure to load a ControlView
		[self setControlType: [[NSUserDefaults standardUserDefaults] integerForKey:kControlType]];
    }
    return self;
}


- (void) loadCustomCommandNames {
	// Load custom button names from flash memory
	NSString* customCommandName1 = [UserDefaults customCommandName: 1];
	if (customCommandName1 != nil)
		[self.customButton1 setTitle: customCommandName1 forState: UIControlStateNormal];
	NSString* customCommandName2 = [UserDefaults customCommandName: 2];
	if (customCommandName2 != nil)
		[self.customButton2 setTitle: customCommandName2 forState: UIControlStateNormal];
	NSString* customCommandName3 = [UserDefaults customCommandName: 3];
	if (customCommandName3 != nil)
		[self.customButton3 setTitle: customCommandName3 forState: UIControlStateNormal];

}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	//scrollView.frame = CGRectMake(0, 262, 320, 92);	// Height = two buttons tall
	//scrollView.frame = CGRectMake(0, 262, 320, 107);	// Height = max height (shows a little of third row
	scrollView.contentSize = CGSizeMake(320, 288); // Assumes three custom buttons in addition to three rows of other buttons
	
	// Load custom button names from flash memory
	[self loadCustomCommandNames];
	
}


- (void) viewWillAppear:(BOOL)animated {
	// The MainView is about to apper
	// Change the control type, if necessary
	[self setControlType: [[NSUserDefaults standardUserDefaults] integerForKey:kControlType]];
	
	// Notify the control view
	[self.controlViewController viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
	// The MainView has fully appeared
	
	// Let the user know that this is a scrolling view
	[scrollView flashScrollIndicators];
	
	// Notify the control view
	[self.controlViewController viewDidAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated {
	// The MainView is about to disappear
	
	// Notify the control view
	[self.controlViewController viewWillDisappear:animated];
}

- (void) viewDidDisappear:(BOOL)animated {
	// The MainView has fully disappeared
	
	// Notify the control view
	[self.controlViewController viewDidDisappear:animated];
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
	[customCommandEditViewController release];
	[roombaComm release];
	[velocityLabel release];
	[velocitySlider release];
	[controlView release];
	[scrollView release];
	[controlViewController release];
	[customButton1 release];
	[customButton2 release];
	[customButton3 release];
	
    [super dealloc];
}


- (void) setRoombaComm:(RoombaComm*)newRoombaComm {
	roombaComm = newRoombaComm;
	self.controlViewController.roombaComm = self.roombaComm;
}


- (void) showAlert:(NSString*)title
{
	UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:@"Check your networking configuration." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alertView show];
	[alertView release];
}


#pragma mark ----- Interface Builder Actions -----

- (IBAction) beep:(id)sender {
	
	[roombaComm beep];
	
}

- (IBAction) toggleLEDs:(id)sender {
	
	[roombaComm toggleLEDs];
	
}

- (IBAction) test:(id)sender {
	
	[roombaComm beep];
	[roombaComm toggleLEDs];
	
}

- (IBAction) toggleVacuum:(id)sender {
	
	[roombaComm toggleVacuum];
	
}

- (IBAction) clean:(id)sender {
	
	[roombaComm clean];
	
}

- (IBAction) spot:(id)sender {
	
	[roombaComm spot];
	
}

- (IBAction) max:(id)sender {
	
	[roombaComm max];
	
}

- (IBAction) dock:(id)sender {
	
	[roombaComm dock];
	
}

- (IBAction) stop:(id)sender {
	
	[roombaComm stop];
	
}

- (IBAction) reconnectRoomba:(id)sender {
	
	[roombaComm reconnectRoomba];
	
}

- (IBAction) playSong:(id)sender {
	
	[roombaComm playSong];
	
}

- (IBAction) runDemo:(id)sender {
	
	[roombaComm runDemo];
	
}

// Run a custom command (previously specified by the user)
- (IBAction) customCommand:(id)sender {
	
	// Get the saved command (based on the button tag)
	// Convert the Obj-C to a simple C array
	kCustomCommand command;
	BOOL status = [UserDefaults customCommand: [sender tag] asRawCustomCommand: command];
	
	if (status == NO) {
		// TODO: Pop up error message?
		return;
	}
	
	// Send the command off to the server
	[roombaComm sendCustomCommand: command];
	
}

// Pop up dialog to edit the given custom SCI command
- (IBAction) editCustomCommand:(id)sender {
	
	// Stop Roomba and lock controls
	[self stop: self];
	[self.controlViewController hold: YES];
	
	// Slide in CustomCommandEditor, passing the index of the button pushed
	CustomCommandEditViewController* viewController = [[CustomCommandEditViewController alloc] initWithNibName:@"CustomCommandEditView" bundle:nil commandNumber:[sender tag]];
	[viewController setDelegate: self];
	self.customCommandEditViewController = viewController;
	[self.view addSubview: viewController.view];
	viewController.view.frame = CGRectMake(0.0, 460.0, 320.0, 460.0);
	
    [UIView beginAnimations:nil context:NULL];
	
	// Slide into view
    [UIView setAnimationDuration:0.5];
	viewController.view.frame = CGRectMake(0.0, 0.0, 320.0, 460.0);
	
	[UIView commitAnimations];
	
}

- (IBAction) velocitySliderAction:(id)sender {
	// Grab the value of the slider
	UISlider* slider = (UISlider *)sender;
	CGFloat val = [slider value];
	unsigned int uval = (unsigned int)val;
	
	// Save this velocity value
	velocity = uval;
	
	// Set the Roomba velocity
	[roombaComm setVelocity: velocity];
	
	// Notify the ControlViewController of the velocity slider change
	[self.controlViewController setVelocity: velocity];
	
}



#pragma mark ----- CustomCommandEditViewControllerDelegate Methods -----


- (void) setCustomCommandName: (NSUInteger) commandNumber toString: (NSString*) commandName {
	switch (commandNumber) {
		case 1:
			if ([commandName length] == 0)
				 [self.customButton1 setTitle: @"Custom 1" forState: UIControlStateNormal];
			else
				 [self.customButton1 setTitle: commandName forState: UIControlStateNormal];
			break;
		case 2:
			if ([commandName length] == 0)
				[self.customButton1 setTitle: @"Custom 2" forState: UIControlStateNormal];
			else
				[self.customButton2 setTitle: commandName forState: UIControlStateNormal];
			break;
		case 3:
			if ([commandName length] == 0)
				[self.customButton1 setTitle: @"Custom 3" forState: UIControlStateNormal];
			else
				[self.customButton3 setTitle: commandName forState: UIControlStateNormal];
			break;
		default:
			break;
	}
}

- (void) destroyCustomCommandEditViewController {
	// This will release the view controller
	self.customCommandEditViewController = nil;
}

- (void) doneEditingCustomCommand {
	// User is done with the CustomCommandEditViewController. Slide it off-screen and remove it from memory
	
	// Load custom button names from flash memory in case they changed.
	//[self loadCustomCommandNames];
	
	// Remove from superview
	UIView *customCommandEditView = self.customCommandEditViewController.view;
	
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
	
	// Slide out of view
	customCommandEditView.frame = CGRectMake(0.0, 460.0, 320.0, 460.0);
	// Remove the views after they have left the screen
	
	[NSTimer scheduledTimerWithTimeInterval:0.6 target:customCommandEditView selector:@selector(removeFromSuperview) userInfo:nil repeats:NO];
	[NSTimer scheduledTimerWithTimeInterval:0.6 target:self selector:@selector(destroyCustomCommandEditViewController) userInfo:nil repeats:NO];
	
	[UIView commitAnimations];
}


#pragma mark ----- Other -----

- (void) setControlType: (unsigned) controlType {
	
	UIViewController<ControlViewController> *viewController = nil;
	
	// Only change the ControlView if the requested controlType is different than the current one
	if (controlType == currentControlType)
		return;
	
	/*
	// Remove the old view
	[self.controlView removeFromSuperview];
	self.controlViewController = nil;
	self.controlView = nil;
	*/
	
	currentControlType = controlType;
	
	// Select the control view type
	switch (controlType) {
		case kControlTypeButton:
			viewController = [[ButtonControlViewController alloc] initWithNibName:@"ButtonControlView" bundle:nil];
			self.velocityLabel.text = @"Velocity (mm/s)";
			break;
		case kControlTypeSwipe:
			viewController = [[SwipeControlViewController alloc] init];
			self.velocityLabel.text = @"Velocity (mm/s)";
			break;
		case kControlTypeAccelerometer:
			viewController = [[AccelerometerControlViewController alloc] init];
			self.velocityLabel.text = @"Maximum Velocity (mm/s)";
			break;
		default:
			viewController = [[ButtonControlViewController alloc] initWithNibName:@"ButtonControlView" bundle:nil];
			self.velocityLabel.text = @"Velocity (mm/s)";
			break;
	}
	
	// Finish setup
	[viewController setVelocity: velocity];
	viewController.roombaComm = self.roombaComm;
	self.controlViewController = viewController;
	self.controlView = viewController.view;
	[viewController release];
	//[self.view addSubview: self.controlView]; // Add on top
	[self.view insertSubview: self.controlView belowSubview: self.scrollView]; // Add below scroll view
}



#pragma mark ----- Notifications -----

- (void) songPlaying:(BOOL)isPlaying {
	if (isPlaying)
		self.singButton.highlighted = YES;
	else
		self.singButton.highlighted = NO;
}

- (void) demoRunning:(BOOL)isRunning {
	if (isRunning)
		self.demoButton.highlighted = YES;
	else
		self.demoButton.highlighted = NO;
}

@end
