//
//  AccelerometerControlView.m
//  Roomote
//
//  Created by Brian on 7/13/09.
//  Copyright 2009 Brian Pratt. All rights reserved.
//

#import "AccelerometerControlView.h"
// Import QuartzCore for animations
#import <QuartzCore/QuartzCore.h>
#import "constants.h"

#define kRoombaViewScaleFactor 60

@interface AccelerometerControlView ()
- (void)setupSubviewsWithContentFrame:(CGRect)frameRect;
@end


@implementation AccelerometerControlView

BOOL roombaIsSpinning = NO;


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		self.multipleTouchEnabled = YES;
		//self.backgroundColor = [UIColor whiteColor];
		
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
	
	// set up Hold button
	float holdShiftRight = 5.0;
	float holdShiftDown = 5.0;
	
	UIImage *buttonImage = [UIImage imageNamed:@"stop_button.png"];
	CGRect buttonFrame = CGRectMake(holdShiftRight, holdShiftDown, buttonImage.size.width, buttonImage.size.height);
	holdButton = [self buttonWithTitle:nil target:self selector:@selector(toggleHoldButton:) frame:buttonFrame image:buttonImage];
	[holdButton retain];
	
	// add view in proper order and location
	[self addSubview: roombaView];
	[self addSubview: holdButton];
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
        [holdButton setBackgroundImage:[UIImage imageNamed:@"go_button.png"] forState:UIControlStateNormal];
		
		[delegate hold: YES];
    } else {
        holdButtonIsShowing = YES;
        // set image on Hold button
        [holdButton setBackgroundImage:[UIImage imageNamed:@"stop_button.png"] forState:UIControlStateNormal];
		
		[delegate hold: NO];
    }    
}


// Change the position of the Roomba View
- (void) updateRoombaViewWithX: (float) x andY: (float) y {
	
	if (roombaIsSpinning)
		return;
	
	if (fabs(y) < 0.05 && fabs(x) < 0.05)
		x = y = 0;
	
	[UIView beginAnimations:@"moveRoomba" context:NULL];
	[UIView setAnimationDuration: 1.0/kAccelerometerFrequency];
	
	roombaView.center = CGPointMake(self.center.x+x*kRoombaViewScaleFactor, self.center.y+y*kRoombaViewScaleFactor);
	
	// Twist the Roomba to the left or right based on the X value
	[self rotateRoombaViewWithX: x andY: y];
	
    [UIView commitAnimations];
}


// Rotate the Roomba View
- (void) rotateRoombaViewWithX: (float) x andY: (float) y {
	
	if (roombaIsSpinning)
		return;
	
	// Determine the direction of rotation by the y value
	float rotationAmount;
	//if (fabs(y) < 0.03 && fabs(x) < 0.03)
	//	// Don't rotate when the Roomba is in the center of the screen. It tends to jiggle at rest.
	//	rotationAmount = 0;
	//else if (y < 0)
	if (y < 0)
		rotationAmount = x*M_PI/4;
	else
		rotationAmount = -x*M_PI/4;
	
	// Define the transform
	CGAffineTransform transform = CGAffineTransformMakeRotation(rotationAmount);
	
	// Do the transformation to rotate the view
	roombaView.transform = transform;
}

// Re-center the Roomba View and then rotate it
- (void) recenterAndRotateRoombaView: (BOOL) clockwise {
	
	if (roombaIsSpinning)
		return;
	
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

// Spin the Roomba View
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
	
	roombaIsSpinning = YES;
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
	
	roombaIsSpinning = NO;
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
