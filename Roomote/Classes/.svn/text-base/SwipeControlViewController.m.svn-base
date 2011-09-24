//
//  SwipeControlViewController.m
//  Roomote
//
//  Created by Brian on 7/13/09.
//  Copyright 2009 Brian Pratt. All rights reserved.
//

#import "SwipeControlViewController.h"
#import "SwipeControlView.h"
#import "constants.h"

// A class extension to declare private methods and variables
@interface SwipeControlViewController ()

- (void) goForward;
- (void) goBackward;
- (void) goForwardLeft: (unsigned) turnRadius;
- (void) goForwardRight: (unsigned) turnRadius;
- (void) goBackwardLeft: (unsigned) turnRadius;
- (void) goBackwardRight: (unsigned) turnRadius;
- (void) spinLeft;
- (void) spinRight;
- (void) stop;

@end

enum quadrant {
	QUAD1,
	QUAD2,
	QUAD3,
	QUAD4,
	NOQUAD
};

typedef struct touch_keeper_struct {
	id touch;
	int quadrant;
} touch_keeper;


@implementation SwipeControlViewController

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
	swipeControlView = [[SwipeControlView alloc] initWithFrame: CGRectMake(0.0, 0.0, 320.0, 270.0)];
	self.view = swipeControlView;
	[swipeControlView release];
	
	// Set up default thresholds and step sizes (TODO: set up from saved settings)
	m_thresholdX = 25;
	m_thresholdY = 25;
	m_thresholdZ = 10;
	
	m_stepSizeX = 10;
	m_stepSizeY = 10;
	m_stepSizeZ = 10;
}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

- (void) viewWillDisappear:(BOOL)animated {
	// The View is about to disappear
	
	// Stop the Roomba
	[self stop];
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
    [super dealloc];
}



#pragma mark ----- Helper Methods -----

- (void)resetZoomDistance {
	initialDistance = -1;
}


- (CGFloat)distanceBetweenTwoPoints:(CGPoint)fromPoint toPoint:(CGPoint)toPoint {
    float x = toPoint.x - fromPoint.x;
    float y = toPoint.y - fromPoint.y;
    
    return sqrt(x * x + y * y);
}

- (int)detectQuadrant: (UITouch *) touch {
	CGPoint point;
	point = [touch locationInView:self.view];
	int pointX = point.x;
	int pointY = point.y;
	int centerX = self.view.center.x;
	int centerY = self.view.center.y;
	if (pointX >= centerX && pointY < centerY)
		return QUAD1;
	else if (pointX < centerX && pointY < centerY)
		return QUAD2;
	else if (pointX < centerX && pointY >= centerY)
		return QUAD3;
	else if (pointX >= centerX && pointY >= centerY)
		return QUAD4;
	else
		return NOQUAD;

}

touch_keeper touchKeeper[4]; //touch, quadrant
bool circle_detected = NO;

- (void)resetCircleDetect {
	touchKeeper[0].quadrant = -1;
	touchKeeper[1].quadrant = -1;
	touchKeeper[2].quadrant = -1;
	touchKeeper[3].quadrant = -1;
	circle_detected = NO;
}

- (void)detectCircle: (UITouch *) touch {
	static int touchIndex = 0;
	static int previousQuadrant = -1;
	
	int quadrant = [self detectQuadrant: touch];
	
	// Ignore multiple touches in same quadrant
	if (quadrant == previousQuadrant)
		return;
	
	touchKeeper[touchIndex].touch =  touch;
	touchKeeper[touchIndex].quadrant = quadrant;
	//NSLog(@"Detected touch in quadrant %d", touchKeeper[touchIndex].quadrant);
	if (touchKeeper[0].quadrant != -1 &&
		touchKeeper[1].quadrant != -1 &&
		touchKeeper[2].quadrant != -1 &&
		touchKeeper[3].quadrant != -1)
	{
		if ((touchKeeper[3].quadrant == (touchKeeper[2].quadrant+1)%4) &&
			(touchKeeper[3].quadrant == (touchKeeper[1].quadrant+2)%4) &&
			(touchKeeper[3].quadrant == (touchKeeper[0].quadrant+3)%4)) {
			[self spinLeft];
			//NSLog(@"\t%d, %d, %d, %d", touchKeeper[0].quadrant, touchKeeper[1].quadrant, touchKeeper[2].quadrant, touchKeeper[3].quadrant);
			//NSLog(@"\t%d, %d, %d, %d", touchKeeper[3].quadrant, (touchKeeper[2].quadrant+1)%4, (touchKeeper[1].quadrant+2)%4, (touchKeeper[0].quadrant+3)%4);
			circle_detected = YES;
			touchIndex=0;
			previousQuadrant = -1;
		}
		else if ((touchKeeper[0].quadrant == (touchKeeper[1].quadrant+1)%4) &&
				 (touchKeeper[0].quadrant == (touchKeeper[2].quadrant+2)%4) &&
				 (touchKeeper[0].quadrant == (touchKeeper[3].quadrant+3)%4)) {
			[self spinRight];
			//NSLog(@"\t%d, %d, %d, %d", touchKeeper[0].quadrant, touchKeeper[1].quadrant, touchKeeper[2].quadrant, touchKeeper[3].quadrant);
			circle_detected = YES;
			touchIndex=0;
			previousQuadrant = -1;
		}
	}
	else {
		touchIndex = (touchIndex+1)%4;
		previousQuadrant = quadrant;
	}
}

- (unsigned) turnRadiusFromSwipeDistance: (float) distance {
	// Max radius is 2000mm
	// Max swipe distance (horizontal) is 320.0
	// Swipe distance of 0.0 = radius of 2000mm
	// Swipe distance of 320.0 = radius of 0mm
	distance = (distance > 320.0)?320.0:distance;
	return ((320.0-distance)/320.0)*MAX_TURN_RADUIS;
}


#pragma mark ----- Touch Handling Methods -----

// Swipe to move and pinch to zoom
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
	// To keep track of the speed of a swipe
	if (timeStamp != nil)
		[timeStamp release];
	timeStamp = [NSDate date];
	[timeStamp retain];
    
	NSSet *allTouches = [event allTouches];
	
	// Just in case touchesEnded never got called before new touches began
	if (touchesBeganButNotEnded)
		[self resetZoomDistance];
	else
		touchesBeganButNotEnded = YES;
	
    
    switch ([allTouches count]) {
        case 1: {
			//NSLog(@"One finger began");
			// Get the first touch.
			UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
			CGPoint pos = [touch locationInView: self.view];
			initialXPosition = pos.x;
			initialYPosition = pos.y;
			
			/*
			switch([touch tapCount])
			{
				case 1: // Single tap
					//NSLog(@"\tSingle tap");
					[self stop];
					break;
				case 2: // Double tap.
					NSLog(@"\tDouble tap");
					[self stop];
					break;
			}
			*/
			
			// Reset zoom distance just in case
			[self resetZoomDistance];
			
			// Reset circle detection just in case
			[self resetCircleDetect];
			
        } break;
        case 2: {
			//NSLog(@"Two fingers began");
            // Get two touches
            UITouch *touch1 = [[allTouches allObjects] objectAtIndex:0];
            UITouch *touch2 = [[allTouches allObjects] objectAtIndex:1];
            
			
			// And calculate our initial distance between them
			initialDistance = [self distanceBetweenTwoPoints:[touch1 locationInView: self.view]
													 toPoint:[touch2 locationInView: self.view]];
			
        } break;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    NSSet *allTouches = [event allTouches];
    
    switch ([allTouches count])
    {
        case 1: { // Move
			//NSLog(@"One finger moved");
            //CGPoint actualPosition = [[[allTouches allObjects] objectAtIndex:0] locationInView: self.view];
			
			// Don't calculate distance moved until the touches have ended
			
			// Reset zoom distance just in case
			[self resetZoomDistance];
			
			// Detect circular motion
			if (circle_detected == NO)
				[self detectCircle: [[allTouches allObjects] objectAtIndex:0]];
			
        } break;
        case 2: { // Zoom
			//NSLog(@"Two fingers moved");
            UITouch *touch1 = [[allTouches allObjects] objectAtIndex:0];
            UITouch *touch2 = [[allTouches allObjects] objectAtIndex:1];
            
            // Calculate the distance between the two fingers.
            CGFloat finalDistance = [self distanceBetweenTwoPoints:[touch1 locationInView: self.view]
                                                           toPoint:[touch2 locationInView: self.view]];
			
			if (initialDistance == -1)
				movedZ = 0;
			else
				movedZ = initialDistance - finalDistance;
			
			//NSLog(@"\tinitialDistance= %f", initialDistance);
			//NSLog(@"\tfinalDistance= %f", finalDistance);
			//NSLog(@"\tmovedZ= %f", movedZ);
			
            initialDistance = finalDistance;
			
        } break;
    }
	
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSSet *allTouches = [event allTouches];
	
	
	if ([allTouches count] == 1) {
		
		// Check for circle detection
		if (circle_detected) {
			[self resetCircleDetect];
		}
		else {
			// Get the first touch.
			UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
			
			// Check for tap
			switch([touch tapCount])
			{
				case 1: // Single tap
					//NSLog(@"\tSingle tap");
					[self stop];
					break;
				case 2: // Double tap.
					//NSLog(@"\tDouble tap");
					[self stop];
					break;
			}
			
			// Check for swipe
			CGPoint actualPosition = [touch locationInView: self.view];
			
			movedX = actualPosition.x - initialXPosition;
			movedY = initialYPosition - actualPosition.y;
			
			unsigned turnRadius = [self turnRadiusFromSwipeDistance: fabs(movedX)];
			
			NSLog(@"movedX=%f, movedY=%f", movedX, movedY);
			
			////////////////////
			// Use the swipe distance values to control the Roomba
			if (movedY > m_thresholdY) {
				// Swipe forward
				if (movedX > m_thresholdX)
					// and right
					[self goForwardRight: turnRadius];
				else if (movedX < -m_thresholdX)
					// and  left
					[self goForwardLeft: turnRadius];
				else
					[self goForward];
			}
			else if (movedY < -m_thresholdY) {
				// Swipe backward
				if (movedX > m_thresholdX)
					// and right
					[self goBackwardRight: turnRadius];
				else if (movedX < -m_thresholdX)
					// and left
					[self goBackwardLeft: turnRadius];
				else
					[self goBackward];
			}
			else if (movedX > m_thresholdX) {
				// Swipe right, but not forward or backward
				[self spinRight];
			}
			else if (movedX < -m_thresholdX) {
				// Swipe left, but not forward or backward
				[self spinLeft];
			}
			else
				// No significant swipe at all (a tap?)
				[self stop];
		}
	}
	
	
	// Update the current state of touches
	touchesBeganButNotEnded = NO;
	[self resetZoomDistance];
	
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	touchesBeganButNotEnded = NO;
	[self resetZoomDistance];
}



#pragma mark ----- Movement Actions -----

// TODO: Set the speed of the Roomba based on speed/length of the swipe?

- (void) goForward {
	
	// Update the Roomba picture
	[swipeControlView endRotation];
	[swipeControlView updateRoombaViewWithX: 0.0 andY: -1.0];
	
	[roombaComm goForward];
	
}

- (void) goBackward {
	
	// Update the Roomba picture
	[swipeControlView endRotation];
	[swipeControlView updateRoombaViewWithX: 0.0 andY: 1.0];
	
	[roombaComm goBackward];
	
}

- (void) goForwardLeft: (unsigned) turnRadius {
	
	// Update the Roomba picture
	[swipeControlView endRotation];
	[swipeControlView updateRoombaViewWithX: -0.707 andY: -0.707];
	
	[roombaComm goForwardLeftWithRadius: turnRadius];
	
}

- (void) goForwardRight: (unsigned) turnRadius {
	
	// Update the Roomba picture
	[swipeControlView endRotation];
	[swipeControlView updateRoombaViewWithX: 0.707 andY: -0.707];
	
	[roombaComm goForwardRightWithRadius: turnRadius];
	
}

- (void) goBackwardLeft: (unsigned) turnRadius {
	
	// Update the Roomba picture
	[swipeControlView endRotation];
	[swipeControlView updateRoombaViewWithX: -0.707 andY: 0.707];
	
	[roombaComm goBackwardLeftWithRadius: turnRadius];
	
}

- (void) goBackwardRight: (unsigned) turnRadius {
	
	// Update the Roomba picture
	[swipeControlView endRotation];
	[swipeControlView updateRoombaViewWithX: 0.707 andY: 0.707];
	
	[roombaComm goBackwardRightWithRadius: turnRadius];
	
}

- (void) spinLeft {
	
	// Update the Roomba picture
	[swipeControlView endRotation];
	//[swipeControlView updateRoombaViewWithX: -1.0 andY: 0.0];
	[swipeControlView recenterAndRotateRoombaView: NO];
	
	[roombaComm spinLeft];
	
}

- (void) spinRight {
	
	// Update the Roomba picture
	[swipeControlView endRotation];
	//[swipeControlView updateRoombaViewWithX: 1.0 andY: 0.0];
	[swipeControlView recenterAndRotateRoombaView: YES];
	
	[roombaComm spinRight];
	
}

- (void) stop {
	
	// Update the Roomba picture
	[swipeControlView endRotation];
	[swipeControlView updateRoombaViewWithX: 0.0 andY: 0.0];
	
	[roombaComm stop];
	
}


#pragma mark ----- Common ControlViewController Methods -----

- (void) hold: (BOOL) holdOn {
	// Do nothing. Could prevent swipes, I guess.
}

- (void) setVelocity: (unsigned) velocity {
	// Do nothing.
}


@end
