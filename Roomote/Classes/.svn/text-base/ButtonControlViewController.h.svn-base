//
//  ButtonControlViewController.h
//  Roomote
//
//  Created by Brian on 7/13/09.
//  Copyright 2009 Brian Pratt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoombaComm.h"
#import "ControlViewController.h"


@interface ButtonControlViewController : UIViewController <ControlViewController> {
	
	//id<MainViewController>		delegate;
	
	RoombaComm					*roombaComm;

}

@property (nonatomic, retain) RoombaComm *roombaComm;

// Movement Actions
- (IBAction) goForward:(id)sender;
- (IBAction) goBackward:(id)sender;
- (IBAction) goForwardLeft:(id)sender;
- (IBAction) goForwardRight:(id)sender;
- (IBAction) goBackwardLeft:(id)sender;
- (IBAction) goBackwardRight:(id)sender;
- (IBAction) spinLeft:(id)sender;
- (IBAction) spinRight:(id)sender;
- (IBAction) stop:(id)sender;

// Other
//- (void) setDelegate:(id)newDelegate;

@end
