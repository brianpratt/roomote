//
//  SwipeControlView.m
//  Roomote
//
//  Created by Brian on 7/13/09.
//  Copyright 2009 Brian Pratt. All rights reserved.
//

#import "SwipeControlView.h"
// Import QuartzCore for animations
#import <QuartzCore/QuartzCore.h>

#define kRoombaViewScaleFactor 60


@interface SwipeControlView ()
- (void)setupSubviewsWithContentFrame:(CGRect)frameRect;
@end


@implementation SwipeControlView


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		self.multipleTouchEnabled = YES;
		//self.backgroundColor = [UIColor blueColor];
		
        // Set default state
        holdButtonIsShowing = YES;
		
		// Set up subviews
        [self setupSubviewsWithContentFrame:frame];
    }
    return self;
}


- (UIButton *)buttonWithTitle:(NSString *)title target:(id)target selector:(SEL)inSelector frame:(CGRect)frame image:(UIImage*)image {
	UIButton *button = [[UIButton alloc] initWithFrame:frame];
	button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	[button setTitle:title forState:UIControlStateNormal & UIControlStateHighlighted & UIControlStateSelected];
	[button setTitleColor:[UIColor blackColor] forState:UIControlEventTouchDown];
	UIImage *newImage = [image stretchableImageWithLeftCapWidth:10 topCapHeight:10];
	[button setBackgroundImage:newImage forState:UIControlStateNormal];
	[button addTarget:target action:inSelector forControlEvents:UIControlEventTouchUpInside];
    button.adjustsImageWhenDisabled = YES;
    button.adjustsImageWhenHighlighted = YES;
	[button setBackgroundColor:[UIColor clearColor]];	// in case the parent view draws with a custom color or gradient, use a transparent color
    [button autorelease];
    return button;
}


- (void)setupSubviewsWithContentFrame:(CGRect)frameRect {
	
	// Set up the Roomba View
	roombaView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"roomba.png"]];
	roombaView.center = self.center;
	
	/*
	// set up Hold button
	float holdShiftRight = 5.0;
	float holdShiftDown = 5.0;
	
	UIImage *buttonImage = [UIImage imageNamed:@"hold_button.png"];
	CGRect buttonFrame = CGRectMake(holdShiftRight, holdShiftDown, buttonImage.size.width, buttonImage.size.height);
	holdButton = [self buttonWithTitle:nil target:self selector:@selector(toggleHoldButton:) frame:buttonFrame image:buttonImage];
	[holdButton retain];
	*/
	
	// add view in proper order and location
	[self addSubview: roombaView];
	//[self addSubview: holdButton];
	[self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
}


- (void)dealloc {
	
    [holdButton release];
	[roombaView release];
	
    [super dealloc];
}



- (void) setDelegate:(id)newDelegate {
	delegate = newDelegate;
}


// Display only updates if Hold/Release button hasn't been pressed 
- (void) toggleHoldButton: (id) sender {
    if (holdButtonIsShowing == YES) {
        holdButtonIsShowing = NO;
        [holdButton setImage:[UIImage imageNamed:@"release_button.png"] forState:UIControlStateNormal];
		
		[delegate hold: YES];
    } else {
        holdButtonIsShowing = YES;
        // set image on Hold button
        [holdButton setImage:[UIImage imageNamed:@"hold_button.png"] forState:UIControlStateNormal];
		
		[delegate hold: NO];
    }    
}


// Change the position of the Roomba View
- (void) updateRoombaViewWithX: (float) x andY: (float) y {
	
	[UIView beginAnimations:@"moveRoomba" context:NULL];
	[UIView setAnimationDuration: 0.2];
	
	// Move center of Roomba View to the location specified
	roombaView.center = CGPointMake(self.center.x+x*kRoombaViewScaleFactor, self.center.y+y*kRoombaViewScaleFactor);

	// Give it a slight twist if going to the right or left
	if (y < 0) {
		// Swipe forward
		if (x > 0)
			// and right
			roombaView.transform = CGAffineTransformMakeRotation(M_PI/6);
		else if (x < 0)
			// and  left
			roombaView.transform = CGAffineTransformMakeRotation(-M_PI/6);
		else
			// Straighten out
			roombaView.transform = CGAffineTransformMakeRotation(0);
	}
	else if (y > 0) {
		// Swipe backward
		if (x > 0)
			// and right
			roombaView.transform = CGAffineTransformMakeRotation(-M_PI/6);
		else if (x < 0)
			// and left
			roombaView.transform = CGAffineTransformMakeRotation(M_PI/6);
		else
			// Straighten out
			roombaView.transform = CGAffineTransformMakeRotation(0);
	}
	else {
		roombaView.transform = CGAffineTransformMakeRotation(0);
	}

	
	[UIView commitAnimations];
}

/*
// Move the Roomba View forward and to the right/left with a tilt
- (void) recenterAndRotateRoombaView: (BOOL) right {
	
	if (right)
		[UIView beginAnimations:@"moveRoombaForwardRight" context:NULL];
	else
		[UIView beginAnimations:@"moveRoombaForwardLeft" context:NULL];
	
	[UIView setAnimationDuration: 0.2];
	//[UIView setAnimationDelegate:self];
	//[UIView setAnimationDidStopSelector:@selector(animationDidFinish:finished:context:)];
	
	roombaView.center = CGPointMake(self.center.x, self.center.y);
	
	[UIView commitAnimations];
}
*/

// Re-center the Roomba View and then rotate it
- (void) recenterAndRotateRoombaView: (BOOL) clockwise {

	if (clockwise)
		[UIView beginAnimations:@"moveRoombaThenRotateCW" context:NULL];
	else
		[UIView beginAnimations:@"moveRoombaThenRotateCCW" context:NULL];

	[UIView setAnimationDuration: 0.2];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidFinish:finished:context:)];
	
	roombaView.center = CGPointMake(self.center.x, self.center.y);

	[UIView commitAnimations];
}

// Rotate the Roomba View
- (void) rotateRoombaView: (BOOL) clockwise {

	CABasicAnimation* rotationAnimation = [CABasicAnimation
									   animationWithKeyPath: @"transform.rotation"];
	[rotationAnimation setDelegate:self];
	
	if (clockwise)
		rotationAnimation.toValue = [NSNumber numberWithFloat: 2*M_PI];
	else
		rotationAnimation.toValue = [NSNumber numberWithFloat: -2*M_PI];
	rotationAnimation.duration = 3.0;
	rotationAnimation.repeatCount = INFINITY;
	rotationAnimation.cumulative = YES;
	// Don't snap back to the original position
	//rotationAnimation.removedOnCompletion = NO;
	//[rotationAnimation setFillMode:kCAFillModeForwards];
	
	[roombaView.layer addAnimation:rotationAnimation forKey: @"rotationAnimation"];
	
	// Set the view's center and transformation to the original values in preparation for the end of the animation
	roombaView.center = self.center;
	roombaView.transform = CGAffineTransformIdentity;
}

- (void) endRotation {
	[roombaView.layer removeAnimationForKey: @"rotationAnimation"];
	
	/*
	CABasicAnimation* finishRotationAnimation = [CABasicAnimation
										   animationWithKeyPath: @"transform.rotation"];
	//[rotationAnimation setDelegate:self];
	
	finishRotationAnimation.toValue = [NSNumber numberWithFloat: 0];
	finishRotationAnimation.duration = 0.2;
	
	[roombaView.layer addAnimation:finishRotationAnimation forKey: @"finishRotationAnimation"];
	 */
}

- (void) animationDidFinish:(NSString *)animationID finished:(BOOL)finished context:(void *)context {

	if ([animationID isEqualToString: @"moveRoombaThenRotateCW"])
		[self rotateRoombaView: YES];
	else if ([animationID isEqualToString: @"moveRoombaThenRotateCCW"])
		[self rotateRoombaView: NO];
	else 
		NSLog(@"Should not get here! Someone specified the animactionDidStopSelector in SwipeControlView incorrectly.");
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
	
    //NSLog(@"Animation interrupted: %@", (!flag)?@"Yes" : @"No");
}


@end
