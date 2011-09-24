//
//  MainViewController.h
//  Roomote
//
//  Created by Brian on 1/22/09.
//  Copyright Brian Pratt 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "constants.h"
#include "networking.h"
#import "RoombaComm.h"
#import "ControlViewController.h"
#import "CustomCommandEditViewController.h"


@interface MainViewController : UIViewController {
	
	RoombaComm								*roombaComm;
	
	IBOutlet UILabel						*velocityLabel;
	IBOutlet UISlider						*velocitySlider;
	
	UIView									*controlView;
	UIViewController<ControlViewController>	*controlViewController;
	
	CustomCommandEditViewController			*customCommandEditViewController;
	
	IBOutlet UIScrollView					*scrollView;
	
	int	currentControlType;
	
	// Demo and Song buttons
	IBOutlet UIButton						*demoButton;
	IBOutlet UIButton						*singButton;
	
	// Custom Command Buttons
	IBOutlet UIButton						*customButton1;
	IBOutlet UIButton						*customButton2;
	IBOutlet UIButton						*customButton3;

}

@property (nonatomic, retain) RoombaComm *roombaComm;
@property (nonatomic, retain) IBOutlet UILabel *velocityLabel;
@property (nonatomic, retain) IBOutlet UISlider *velocitySlider;
@property (nonatomic, retain) UIViewController<ControlViewController> *controlViewController;
@property (nonatomic, retain) UIView *controlView;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) CustomCommandEditViewController *customCommandEditViewController;
@property (nonatomic, retain) IBOutlet UIButton *demoButton;
@property (nonatomic, retain) IBOutlet UIButton *singButton;
@property (nonatomic, retain) IBOutlet UIButton *customButton1;
@property (nonatomic, retain) IBOutlet UIButton *customButton2;
@property (nonatomic, retain) IBOutlet UIButton *customButton3;

// Other Actions
- (IBAction) beep:(id)sender;
- (IBAction) toggleLEDs:(id)sender;
- (IBAction) test:(id)sender;
- (IBAction) toggleVacuum:(id)sender;
- (IBAction) clean:(id)sender;
- (IBAction) spot:(id)sender;
- (IBAction) max:(id)sender;
- (IBAction) dock:(id)sender;
- (IBAction) stop:(id)sender;
- (IBAction) reconnectRoomba:(id)sender;
- (IBAction) runDemo:(id)sender;
- (IBAction) playSong:(id)sender;
- (IBAction) customCommand:(id)sender;
- (IBAction) editCustomCommand:(id)sender;
- (IBAction) velocitySliderAction:(id)sender;

// Other
- (void) setControlType:(unsigned)controlType;

// Notifications
- (void) songPlaying:(BOOL)isPlaying;
- (void) demoRunning:(BOOL)isRunning;


@end
