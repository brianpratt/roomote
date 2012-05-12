//
//  RootViewController.h
//  Roomote
//
//  Created by Brian on 1/22/09.
//  Copyright Brian Pratt 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BonjourBrowser.h"
#import "networking.h"
#import "RoombaComm.h"
#import "MainViewController.h"
#import "FlipsideViewController.h"

@class MainViewController;

@interface RootViewController : UIViewController <RoombaCommDelegate, FlipsideViewControllerDelegate, BonjourBrowserDelegate, NSStreamDelegate> {

    UIButton				*infoButton;
    MainViewController		*mainViewController;
	RoombaComm				*roombaComm;
    FlipsideViewController	*flipsideViewController;
	BonjourBrowser			*bonjourBrowser;
	UIView					*noTouchBackground;
	NSInputStream			*inStream;
	NSOutputStream			*outStream;
	BOOL					inReady;
	BOOL					outReady;
}

@property (nonatomic, retain) IBOutlet UIButton *infoButton;
@property (nonatomic, retain) RoombaComm *roombaComm;
@property (nonatomic, retain) MainViewController *mainViewController;
@property (nonatomic, retain) FlipsideViewController *flipsideViewController;
@property (nonatomic, retain) BonjourBrowser *bonjourBrowser;
@property (nonatomic, retain) UIView *noTouchBackground;

@property (nonatomic, retain) NSOutputStream *outStream;

- (IBAction) toggleView;

- (void) loadFlipsideViewController;
- (void) setupNetworking;
- (BOOL) networkingReady;
- (void) presentBonjourBrowser:(NSString*)name;

- (NSInputStream*) inStream;
- (NSOutputStream*) outStream;


@end
