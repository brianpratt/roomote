/*
 *  constants.h
 *  Roomote
 *
 *  Created by Brian on 1/23/09.
 *  Copyright 2009 Brian Pratt. All rights reserved.
 *
 */

#ifndef CONSTANTS_H
#define CONSTANTS_H

// Roomba default parameters
#define DEFAULT_VELOCITY 200
#define MIN_VELOCITY 0
#define MAX_VELOCITY 500
#define MIN_TURN_RADUIS -2000
#define MAX_TURN_RADUIS 2000

// Networking
#define kServiceType @"_roomote._tcp"
#define kInitialDomain  @"local"

// Constant for the number of times per second (Hertz) to sample acceleration in AccelerometerControlView
#define kAccelerometerFrequency     30

// UserDefaults keys
#define kControlType @"controlType"
#define kAccelerometerCommandUpdateDelayIndex @"accelCommandUpdateDelayIndex"
#define kAccelerometerCommandUpdateDelay @"accelCommandUpdateDelay"
#define kCustomCommandKey @"customCommand"
#define kCustomCommandNamesKey @"customCommandNames"

// Default values
#define kDefaultAccelerometerCommandUpdateDelay 15
#define kDefaultAccelerometerCommandUpdateDelayIndex 2

#define kMaxCustomCommands 10
#define kMaxCustomCommandNameLength 25

// Control Types
// These must match the GUI segmented control element
// Must have a zero control type, which is the default (for before settings are saved)
#define kControlTypeButton			0
#define kControlTypeSwipe			1
#define kControlTypeAccelerometer	2


// Global variables describing screen dimensions
extern float kScreenHeight;
extern float kScreenHeightNoStatus;
extern float kPickerViewHeight;
extern float kNavigationBarHeight;
extern float kControlViewHeight;

#endif
