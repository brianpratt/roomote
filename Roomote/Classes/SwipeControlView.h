//
//  SwipeControlView.h
//  Roomote
//
//  Created by Brian on 7/13/09.
//  Copyright 2009 Brian Pratt. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SwipeControlView;

@protocol SwipeControlViewDelegate

@required
- (void) hold: (BOOL) holdOn;

@end


@interface SwipeControlView : UIView {
	
	id<SwipeControlViewDelegate>	delegate;
	
	// Display elements
    UIImageView *roombaView;
    UIButton *holdButton;
	
    BOOL holdButtonIsShowing;
}

- (void) setDelegate: (id) newDelegate;
- (void) toggleHoldButton: (id) sender;
- (void) updateRoombaViewWithX: (float) x andY: (float) y;
- (void) recenterAndRotateRoombaView: (BOOL) clockwise;
- (void) endRotation;

@end
