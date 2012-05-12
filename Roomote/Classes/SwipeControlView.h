//
//  SwipeControlView.h
//  Roomote
//
//  Created by Brian on 7/13/09.
//  Copyright 2009 Brian Pratt. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SwipeControlView;


@interface SwipeControlView : UIView {
	
	id	delegate;
	
	// Display elements
    UIImageView *roombaView;
}

- (void) setDelegate: (id) newDelegate;
- (void) updateRoombaViewWithX: (float) x andY: (float) y;
- (void) recenterAndRotateRoombaView: (BOOL) clockwise;
- (void) endRotation;

@end
