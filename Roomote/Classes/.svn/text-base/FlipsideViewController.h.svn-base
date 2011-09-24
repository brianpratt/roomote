//
//  FlipsideViewController.h
//  Roomote
//
//  Created by Brian on 1/22/09.
//  Copyright Brian Pratt 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoombaComm.h"
#import "SongPickerController.h"
#import "DemoPickerController.h"

@class FlipsideViewController;


@protocol FlipsideViewControllerDelegate

@required
- (void) toggleView;
- (void) selectServer;

@end


@interface FlipsideViewController : UIViewController <SongPickerControllerDelegate, DemoPickerControllerDelegate> {
	
	id<FlipsideViewControllerDelegate>	delegate;
	RoombaComm							*roombaComm;
	
	IBOutlet UIActivityIndicatorView	*serverConnectActivityView;
	IBOutlet UIButton					*selectServerButton;
	IBOutlet UIButton					*selectDemoButton;
	IBOutlet UIButton					*selectSongButton;
	IBOutlet UISegmentedControl			*controlTypeSelector;
	IBOutlet UILabel					*accelUpdateIntervalLabel;
	IBOutlet UISegmentedControl			*accelUpdateIntervalSelector;
	IBOutlet UILabel					*versionLabel;
	IBOutlet UIView						*tutorialView;
	IBOutlet UIWebView					*tutorialWebView;
	
	SongPickerController				*songPickerController;
	DemoPickerController				*demoPickerController;
    UINavigationBar						*pickerNavigationBar;
	UIPickerView						*songPickerView;
	UIPickerView						*demoPickerView;
	UIView								*noTouchBackground;

}

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *serverConnectActivityView;
@property (nonatomic, retain) IBOutlet UIButton *selectServerButton;
@property (nonatomic, retain) IBOutlet UIButton *selectDemoButton;
@property (nonatomic, retain) IBOutlet UIButton *selectSongButton;
@property (nonatomic, retain) IBOutlet UISegmentedControl *controlTypeSelector;
@property (nonatomic, retain) IBOutlet UILabel *accelUpdateIntervalLabel;
@property (nonatomic, retain) IBOutlet UISegmentedControl *accelUpdateIntervalSelector;
@property (nonatomic, retain) IBOutlet UILabel *versionLabel;
@property (nonatomic, retain) IBOutlet UIView *tutorialView;
@property (nonatomic, retain) IBOutlet UIWebView *tutorialWebView;
@property (nonatomic, retain) SongPickerController	*songPickerController;
@property (nonatomic, retain) DemoPickerController	*demoPickerController;
@property (nonatomic, retain) UINavigationBar *pickerNavigationBar;
@property (nonatomic, retain) UIPickerView	*songPickerView;
@property (nonatomic, retain) UIPickerView	*demoPickerView;
@property (nonatomic, retain) UIView *noTouchBackground;


// UI Actions
- (IBAction) toggleView:(id)sender;
- (IBAction) connectToServer:(id)sender;
- (IBAction) selectServer:(id)sender;
- (IBAction) selectSong:(id)sender;
- (IBAction) selectDemo:(id)sender;
- (IBAction) selectControlType:(id)sender;
- (IBAction) selectAccelUpdateInterval:(id)sender;
- (IBAction) displayTutorial:(id)sender;
- (IBAction) hideTutorial:(id)sender;


// Other
- (void) setDelegate:(id)newDelegate;
- (void) setRoombaComm:(RoombaComm*)newRoombaComm;
- (void) setSongNameList:(SongName*)songNameList count:(uint8_t)numSongs;
- (void) setDemoNameList:(DemoName*)demoNameList count:(uint8_t)numDemos;
- (void) setSelectServerButtonTitle:(NSString*)newServerText;
- (void) setSelectDemoButtonTitle:(NSString*)newDemoText;
- (void) setSelectSongButtonTitle:(NSString*)newSongText;

// Delegate methods
- (void) setSongNum:(unsigned)songNum;
- (void) setDemoNum:(unsigned)demoNum;
- (void) reloadSongPickerView;
- (void) reloadDemoPickerView;


@end
