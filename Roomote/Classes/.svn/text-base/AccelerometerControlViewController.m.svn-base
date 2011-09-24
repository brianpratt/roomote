//
//  AccelerometerControlViewController.m
//  Roomote
//
//  Created by Brian on 7/13/09.
//  Copyright 2009 Brian Pratt. All rights reserved.
//

#import "AccelerometerControlViewController.h"
#import "AccelerometerSimulation.h"
#import "constants.h"

// How many accelerometer updates between commands sent to the Roomba
// (so we aren't overwhelming the Roomba link)
// This is now a variable
//#define kCommandDelay				10

// Constant for the high/low-pass filter.
//#define kFilteringFactor 0.5
//#define kFilteringFactor 0.3
#define kFilteringFactor 0.25
//#define kFilteringFactor 0.1
//#define kFilteringFactor 0.06

typedef enum kAccelCommandEnum {
	invalid,
	forward,
	backward,
	forwardleft,
	forwardright,
	backwardleft,
	backwardright,
	spinleft,
	spinright,
	stop
} kAccelCommand;

#define DUPLICATE_COMMAND_PERIOD 10

// A class extension to declare private methods and variables
@interface AccelerometerControlViewController ()

- (unsigned) turnRadiusFromAccelerometerValue: (float) accelValue;
- (unsigned) velocityFromAccelerometerValue: (float) accelValue;
- (void) sendCommand: (kAccelCommand) command withVelocity: (int) velocity andRadius: (int) turnRadius;
- (void) goForward;
- (void) goBackward;
- (void) goForwardLeftWithRadius: (unsigned) turnRadius;
- (void) goForwardRightWithRadius: (unsigned) turnRadius;
- (void) goBackwardLeftWithRadius: (unsigned) turnRadius;
- (void) goBackwardRightWithRadius: (unsigned) turnRadius;
- (void) spinLeft;
- (void) spinRight;
- (void) goForwardWithVelocity: (unsigned) velocity;
- (void) goBackwardWithVelocity: (unsigned) velocity;
- (void) goForwardLeftWithVelocity: (unsigned) velocity andRadius: (unsigned) turnRadius;
- (void) goForwardRightWithVelocity: (unsigned) velocity andRadius: (unsigned) turnRadius;
- (void) goBackwardLeftWithVelocity: (unsigned) velocity andRadius: (unsigned) turnRadius;
- (void) goBackwardRightWithVelocity: (unsigned) velocity andRadius: (unsigned) turnRadius;
- (void) spinLeftWithVelocity: (unsigned) velocity;
- (void) spinRightWithVelocity: (unsigned) velocity;
- (void) stop;

unsigned maxVelocity = DEFAULT_VELOCITY;

@end


@implementation AccelerometerControlViewController

@synthesize roombaComm;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	accelerometerControlView = [[AccelerometerControlView alloc] initWithFrame: CGRectMake(0.0, 0.0, 320.0, 270.0)];
	[accelerometerControlView setDelegate: self];
	self.view = accelerometerControlView;
	
	
	// Set up accelerometer
	UIAccelerometer * acc = [UIAccelerometer sharedAccelerometer];
	acc.updateInterval = (1.0 / kAccelerometerFrequency);
	acc.delegate = self;
	hold = NO;
	
	// Set up command delay
	if ([[NSUserDefaults standardUserDefaults] objectForKey:kAccelerometerCommandUpdateDelay] == nil) {
		// First run. Must create a value.
		commandDelay = kDefaultAccelerometerCommandUpdateDelay;
		[[NSUserDefaults standardUserDefaults] setInteger:commandDelay forKey:kAccelerometerCommandUpdateDelay];
	}
	else
		commandDelay = [[NSUserDefaults standardUserDefaults] integerForKey: kAccelerometerCommandUpdateDelay];
	
	// Set up default thresholds and step sizes (TODO: set up from saved settings)
	m_thresholdX = 0.25;
	m_thresholdY = 0.15;
	m_thresholdZ = 0.25; // What could we use Z for?
	
	m_stepSizeX = 0.1;
	m_stepSizeY = 0.1;
	m_stepSizeZ = 0.1;
	
	m_stepSizeVelocity = [self velocityFromAccelerometerValue: m_stepSizeY];
	m_stepSizeRadius = MAX_TURN_RADUIS - [self turnRadiusFromAccelerometerValue: m_stepSizeX];
	
}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
 */

- (void) viewDidAppear:(BOOL)animated {
	// The View is about to appear
	
	// Updated the command delay variable (it might have been set in the FlipsideView)
	commandDelay = [[NSUserDefaults standardUserDefaults] integerForKey: kAccelerometerCommandUpdateDelay];
	
	// Re-enable the accelerometer updates
	[self hold: NO];
	UIAccelerometer * acc = [UIAccelerometer sharedAccelerometer];
	acc.updateInterval = (1.0 / kAccelerometerFrequency);
}

- (void) viewWillDisappear:(BOOL)animated {
	// The View is about to disappear
	
	// Stop the Roomba
	[self stop];
	
	// Disable the accelerometer updates
	[self hold: YES];
	UIAccelerometer * acc = [UIAccelerometer sharedAccelerometer];
	acc.updateInterval = 0.0;
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	UIAccelerometer * acc = [UIAccelerometer sharedAccelerometer];
	acc.updateInterval = 0.0;
	acc.delegate = nil;
	
	[accelerometerControlView release];
	
    [super dealloc];
}


#pragma mark ----- Helper Methods -----

- (unsigned) turnRadiusFromAccelerometerValue: (float) accelValue {
	// Max radius is 2000mm
	// Max accelerometer value (in the X direction) is about 1.0
	// Accel value of 0.0 = radius of 2000mm
	// Accel value of 1.0 = radius of 0mm
	accelValue = (accelValue > 1.0)?1.0:accelValue;
	return (1.0-accelValue)*MAX_TURN_RADUIS;
}

- (unsigned) velocityFromAccelerometerValue: (float) accelValue {
	// Max accelerometer value (in the Y direction) is about 1.0
	// Max velocity should be the current velocity slider value
	accelValue = (accelValue > 1.0)?1.0:accelValue;
	return accelValue*maxVelocity;
}


#pragma mark ----- Accelerometer Handling Methods -----

- (void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
	
	if (hold)
		// Accelerometer updates disabled
		return;
	
	////////////////////
	// Raw accelerometer values
	m_accX = acceleration.x;
	m_accY = acceleration.y;
	m_accZ = acceleration.z;
	
	////////////////////
	// Apply a basic high-pass filter to remove the gravity influence from the accelerometer values.
	// Keep the low-pass filter values as well.
	m_accX_lp = m_accX * kFilteringFactor + m_accX_lp * (1.0 - kFilteringFactor);
	m_accX_hp = m_accX - m_accX_lp;
	m_accY_lp = m_accY * kFilteringFactor + m_accY_lp * (1.0 - kFilteringFactor);
	m_accY_hp = m_accY - m_accY_lp;
	m_accZ_lp = m_accZ * kFilteringFactor + m_accZ_lp * (1.0 - kFilteringFactor);
	m_accZ_hp = m_accZ - m_accZ_lp;
	
	////////////////////
	// Use the accelerometer values to update the Roomba picture
	[accelerometerControlView updateRoombaViewWithX: m_accX_lp andY: -m_accY_lp];
	
	////////////////////
	// Use the accelerometer values to control the Roomba
	// Limit these updates
	static unsigned commandDelayCount = 0;
	unsigned turnRadius = [self turnRadiusFromAccelerometerValue: fabs(m_accX_lp)];
	unsigned velocity = [self velocityFromAccelerometerValue: fabs(m_accY_lp)];
	kAccelCommand command;
	if (++commandDelayCount >= commandDelay) {
		commandDelayCount = 0;
		if (m_accY_lp > m_thresholdY) {
			// Tilting forward
			if (m_accX_lp > m_thresholdX)
				// and tilting right
				//[self goForwardRightWithVelocity: velocity andRadius: turnRadius];
				command = forwardright;
			else if (m_accX_lp < -m_thresholdX)
				// and tilting left
				//[self goForwardLeftWithVelocity: velocity andRadius: turnRadius];
				command = forwardleft;
			else
				//[self goForwardWithVelocity: velocity];
				command = forward;
		}
		else if (m_accY_lp < -m_thresholdY) {
			// Tilting backward
			if (m_accX_lp > m_thresholdX)
				// and tilting right
				//[self goBackwardRightWithVelocity: velocity andRadius: turnRadius];
				command = backwardright;
			else if (m_accX_lp < -m_thresholdX)
				// and tilting left
				//[self goBackwardLeftWithVelocity: velocity andRadius: turnRadius];
				command = backwardleft;
			else
				//[self goBackwardWithVelocity: velocity];
				command = backward;
		}
		else if (m_accX_lp > m_thresholdX) {
			// Tilting right, but not forward or backward
			velocity = [self velocityFromAccelerometerValue: fabs(m_accX_lp)];
			//[self spinRightWithVelocity: velocity];
			command = spinright;
		}
		else if (m_accX_lp < -m_thresholdX) {
			// Tilting left, but not forward or backward
			velocity = [self velocityFromAccelerometerValue: fabs(m_accX_lp)];
			//[self spinLeftWithVelocity: velocity];
			command = spinleft;
		}
		else
			// No significant tilting at all (device is laying flat)
			//[self stop];
			command = stop;
		
		// Send command
		[self sendCommand: command withVelocity: velocity andRadius: turnRadius];
	}
	
}



#pragma mark ----- Movement Actions -----

- (void) sendCommand: (kAccelCommand) command withVelocity: (int) velocity andRadius: (int) turnRadius {
	// Check for duplicate command
	static kAccelCommand previousCommand = invalid;
	static unsigned previousCommandCount = 0;
	// The following must be signed because of possible negative numbers in bounds checks
	static int previousVelocity = 0;
	static int previousRadius = 0;
	//NSLog(@"velocity: %d < %d < %d", previousVelocity-m_stepSizeVelocity, velocity, previousVelocity+m_stepSizeVelocity);
	//NSLog(@"  radius: %d < %d < %d", previousRadius-m_stepSizeRadius, turnRadius, previousRadius+m_stepSizeRadius);
	//NSLog(@"%d %d %d %d", velocity > previousVelocity-m_stepSizeVelocity, velocity < previousVelocity+m_stepSizeVelocity, turnRadius > previousRadius-m_stepSizeRadius, turnRadius < previousRadius+m_stepSizeRadius);
	if (command == previousCommand && 
		(velocity > previousVelocity-m_stepSizeVelocity && velocity < previousVelocity+m_stepSizeVelocity) && 
		(turnRadius > previousRadius-m_stepSizeRadius && turnRadius < previousRadius+m_stepSizeRadius) ) {
		// Duplicate command
		previousCommandCount++;
		if (previousCommandCount < 2) {
			// Send duplicate commands twice, just in case a packet drops
			// Don't reset previousCommandCount
		}
		else if (previousCommandCount < DUPLICATE_COMMAND_PERIOD) {
			// Don't send the same command over and over
			//NSLog(@"sendCommand: Skip duplicate #%d", previousCommandCount);
			//NSLog(@"             Command %d, %d, %d", command, velocity, turnRadius);
			return;
		}
		else {
			// Send it every once in a while, though
			previousCommandCount = 0;
		}
	}
	else {
		// If the command is different than last time, reset the count
		previousCommandCount = 0;
		// Save command details
		previousCommand = command;
		previousVelocity = velocity;
		previousRadius = turnRadius;
	}

	//NSLog(@"sendCommand: Sending command %d, %d, %d", command, velocity, turnRadius);
	
	// Send the command
	switch (command) {
		case forward:
			// Stop any previous rotation
			[accelerometerControlView endRotation];
			[roombaComm goForwardWithVelocity: velocity];
			break;
		case backward:
			// Stop any previous rotation
			[accelerometerControlView endRotation];
			[roombaComm goBackwardWithVelocity: velocity];
			break;
		case forwardleft:
			// Stop any previous rotation
			[accelerometerControlView endRotation];
			[roombaComm goForwardLeftWithVelocity: velocity andRadius: turnRadius];
			break;
		case forwardright:
			// Stop any previous rotation
			[accelerometerControlView endRotation];
			[roombaComm goForwardRightWithVelocity: velocity andRadius: turnRadius];
			break;
		case backwardleft:
			// Stop any previous rotation
			[accelerometerControlView endRotation];
			[roombaComm goBackwardLeftWithVelocity: velocity andRadius: turnRadius];
			break;
		case backwardright:
			// Stop any previous rotation
			[accelerometerControlView endRotation];
			[roombaComm goBackwardRightWithVelocity: velocity andRadius: turnRadius];
			break;
		case spinleft:
			// Tell the Roomba picture to rotate
			[accelerometerControlView recenterAndRotateRoombaView: NO];
			[roombaComm spinLeftWithVelocity: velocity];
			break;
		case spinright:
			// Tell the Roomba picture to rotate
			[accelerometerControlView recenterAndRotateRoombaView: YES];
			[roombaComm spinRightWithVelocity: velocity];
			break;
		case stop:
			// Stop any previous rotation
			[accelerometerControlView endRotation];
			[roombaComm stop];
			break;
		default:
			// Stop any previous rotation
			[accelerometerControlView endRotation];
			[roombaComm stop];
			break;
	}
}

// No velocity arguments
- (void) goForward {
	
	[accelerometerControlView endRotation];
	
	[roombaComm goForward];
	
}

- (void) goBackward {
	
	[accelerometerControlView endRotation];
	
	[roombaComm goBackward];
	
}

- (void) goForwardLeftWithRadius: (unsigned) turnRadius {
	
	[accelerometerControlView endRotation];
	
	[roombaComm goForwardLeftWithRadius: turnRadius];
	
}

- (void) goForwardRightWithRadius: (unsigned) turnRadius {
	
	[accelerometerControlView endRotation];
	
	[roombaComm goForwardRightWithRadius: turnRadius];
	
}

- (void) goBackwardLeftWithRadius: (unsigned) turnRadius {
	
	[accelerometerControlView endRotation];
	
	[roombaComm goBackwardLeftWithRadius: turnRadius];
	
}

- (void) goBackwardRightWithRadius: (unsigned) turnRadius {
	
	[accelerometerControlView endRotation];
	
	[roombaComm goBackwardRightWithRadius: turnRadius];
	
}

- (void) spinLeft {
	
	[accelerometerControlView endRotation];
	
	// Tell the Roomba picture to rotate
	[accelerometerControlView recenterAndRotateRoombaView: NO];
	
	[roombaComm spinLeft];
	
}

- (void) spinRight {
	
	[accelerometerControlView endRotation];
	
	// Tell the Roomba picture to rotate
	[accelerometerControlView recenterAndRotateRoombaView: YES];
	
	[roombaComm spinRight];
	
}

// With velocity arguments
- (void) goForwardWithVelocity: (unsigned) velocity {
	
	[accelerometerControlView endRotation];
	
	[roombaComm goForwardWithVelocity: velocity];
	
}

- (void) goBackwardWithVelocity: (unsigned) velocity {
	
	[accelerometerControlView endRotation];
	
	[roombaComm goBackwardWithVelocity: velocity];
	
}

- (void) goForwardLeftWithVelocity: (unsigned) velocity andRadius: (unsigned) turnRadius {
	
	[accelerometerControlView endRotation];
	
	[roombaComm goForwardLeftWithVelocity: velocity andRadius: turnRadius];
	
}

- (void) goForwardRightWithVelocity: (unsigned) velocity andRadius: (unsigned) turnRadius {
	
	[accelerometerControlView endRotation];
	
	[roombaComm goForwardRightWithVelocity: velocity andRadius: turnRadius];
	
}

- (void) goBackwardLeftWithVelocity: (unsigned) velocity andRadius: (unsigned) turnRadius {
	
	[accelerometerControlView endRotation];
	
	[roombaComm goBackwardLeftWithVelocity: velocity andRadius: turnRadius];
	
}

- (void) goBackwardRightWithVelocity: (unsigned) velocity andRadius: (unsigned) turnRadius {
	
	[accelerometerControlView endRotation];
	
	[roombaComm goBackwardRightWithVelocity: velocity andRadius: turnRadius];
	
}

- (void) spinLeftWithVelocity: (unsigned) velocity {
	
	[accelerometerControlView endRotation];
	
	// Tell the Roomba picture to rotate
	[accelerometerControlView recenterAndRotateRoombaView: NO];
	
	[roombaComm spinLeftWithVelocity: velocity];
	
}

- (void) spinRightWithVelocity: (unsigned) velocity {
	
	[accelerometerControlView endRotation];
	
	// Tell the Roomba picture to rotate
	[accelerometerControlView recenterAndRotateRoombaView: YES];
	
	[roombaComm spinRightWithVelocity: velocity];
	
}

- (void) stop {
	
	[accelerometerControlView endRotation];
	
	[roombaComm stop];
	
}



#pragma mark ----- AccelerometerControlViewDelegate Methods -----

- (void) hold: (BOOL) holdOn {
	if (holdOn) {
		// Stop the Roomba
		[self stop];
		// Update the view
		m_accX = m_accY = m_accZ = 0.0;
		m_accX_lp = m_accY_lp = m_accZ_lp = 0.0;
		m_accX_hp = m_accY_hp = m_accZ_hp = 0.0;
		[accelerometerControlView updateRoombaViewWithX: 0.0 andY: 0.0];
		// Turn off accelerometer updates for now
		hold = YES;
	}
	else {
		hold = NO;
	}
}

- (void) setVelocity: (unsigned) velocity {
	// Save the velocity value (this is from the user) as the max velocity
	maxVelocity = velocity;
}


@end
