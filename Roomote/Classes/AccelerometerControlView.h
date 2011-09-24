//
//  AccelerometerControlView.h
//  Roomote
//
//  Created by Brian on 7/13/09.
//  Copyright 2009 Brian Pratt. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AccelerometerControlView;

@protocol AccelerometerControlViewDelegate

@required
- (void) hold: (BOOL) holdOn;

@end

@interface AccelerometerControlView : UIView {
	
	id<AccelerometerControlViewDelegate>	delegate;
	
	// Display elements
    UIImageView *roombaView;
    UIButton *holdButton;
	
    BOOL holdButtonIsShowing;
}

- (void) setDelegate: (id) newDelegate;
- (void) toggleHoldButton: (id) sender;
- (void) updateRoombaViewWithX: (float) x andY: (float) y;
- (void) rotateRoombaViewWithX: (float) x andY: (float) y;
- (void) recenterAndRotateRoombaView: (BOOL) clockwise;
- (void) endRotation;

@end
