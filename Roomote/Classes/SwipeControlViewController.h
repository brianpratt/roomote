//
//  SwipeControlViewController.h
//  Roomote
//
//  Created by Brian on 7/13/09.
//  Copyright 2009 Brian Pratt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoombaComm.h"
#import "ControlViewController.h"
#import "SwipeControlView.h"


@interface SwipeControlViewController : UIViewController <ControlViewController> {
	
	RoombaComm				*roombaComm;
	SwipeControlView		*swipeControlView;
	
	/* -- Touch Handling stuff -- */	
	// Keep track of touches state
	BOOL		touchesBeganButNotEnded;
	
	//Variables for touch gesture recognition
    CGFloat		initialXPosition;
    CGFloat		initialYPosition;
    CGFloat		initialDistance;
    
    //Variables for matrix transformations
    float		movedZ;
    float		movedX;
    float		movedY;
	NSDate		*timeStamp;
	
	// Sensitivity
	double m_thresholdX, m_thresholdY, m_thresholdZ;
	double m_stepSizeX, m_stepSizeY, m_stepSizeZ;
	
}

@property (nonatomic, retain) RoombaComm *roombaComm;

@end
