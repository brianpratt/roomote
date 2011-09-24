//
//  AccelerometerControlViewController.h
//  Roomote
//
//  Created by Brian on 7/13/09.
//  Copyright 2009 Brian Pratt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoombaComm.h"
#import "ControlViewController.h"
#import "AccelerometerControlView.h"


@interface AccelerometerControlViewController : UIViewController <ControlViewController, UIAccelerometerDelegate, AccelerometerControlViewDelegate> {
	
	RoombaComm					*roombaComm;
	AccelerometerControlView	*accelerometerControlView;
	
	// Accelerometer values
	UIAccelerationValue m_accX, m_accY, m_accZ;
	UIAccelerationValue m_accX_hp, m_accY_hp, m_accZ_hp; // With high-pass filter
	UIAccelerationValue m_accX_lp, m_accY_lp, m_accZ_lp; // With low-pass filter
	BOOL hold;
	
	// Command delay: Number of accelerometer updates before a command is sent to the Roomba
	unsigned commandDelay;
	
	// Sensitivity
	double m_thresholdX, m_thresholdY, m_thresholdZ;
	double m_stepSizeX, m_stepSizeY, m_stepSizeZ;
	int m_stepSizeVelocity, m_stepSizeRadius;
}

@property (nonatomic, retain) RoombaComm *roombaComm;

@end
