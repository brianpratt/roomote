//
//  ButtonControlViewController.m
//  Roomote
//
//  Created by Brian on 7/13/09.
//  Copyright 2009 Brian Pratt. All rights reserved.
//

#import "ButtonControlViewController.h"


@implementation ButtonControlViewController

@synthesize roombaComm;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}


/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

- (void) viewWillDisappear:(BOOL)animated {
	// The View is about to disappear
	
	// Stop the Roomba
	[self stop: self];
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


#pragma mark ----- Movement Actions -----

- (IBAction) goForward:(id)sender {
	
	[roombaComm goForward];
	
}

- (IBAction) goBackward:(id)sender {
	
	[roombaComm goBackward];
	
}

- (IBAction) goForwardLeft:(id)sender {
	
	[roombaComm goForwardLeft];
	
}

- (IBAction) goForwardRight:(id)sender {
	
	[roombaComm goForwardRight];
	
}

- (IBAction) goBackwardLeft:(id)sender {
	
	[roombaComm goBackwardLeft];
	
}

- (IBAction) goBackwardRight:(id)sender {
	
	[roombaComm goBackwardRight];
	
}

- (IBAction) spinLeft:(id)sender {
	
	[roombaComm spinLeft];
	
}

- (IBAction) spinRight:(id)sender {
	
	[roombaComm spinRight];
	
}

- (IBAction) stop:(id)sender {
	
	[roombaComm stop];
	
}



#pragma mark ----- Common ControlViewController Methods -----

- (void) hold: (BOOL) holdOn {
	// Do nothing. Could disable button presses, I guess.
}

- (void) setVelocity: (unsigned) velocity {
	// Do nothing.
}


@end
