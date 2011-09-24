//
//  CustomCommandEditViewController.h
//  Roomote
//
//  Created by Brian on 1/20/10.
//  Copyright 2010 Brian Pratt. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomCommandEditViewControllerDelegate
@required
- (void) doneEditingCustomCommand;
- (void) setCustomCommandName: (NSUInteger) commandNumber toString: (NSString*) commandName;
@end

@interface CustomCommandEditViewController : UIViewController <UITextFieldDelegate> {
	
	id<CustomCommandEditViewControllerDelegate>	delegate;
	
	IBOutlet UITextView		*textView;
	IBOutlet UITextField	*commandNameTextField;
	IBOutlet UITextField	*commandTextField;
	NSUInteger				commandNumber;
	
}

@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (nonatomic, retain) IBOutlet UITextField *commandNameTextField;
@property (nonatomic, retain) IBOutlet UITextField *commandTextField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil commandNumber:(NSUInteger)commandNumberToEdit;

// IBAction Methods
- (IBAction)doneEditingCustomCommand;

// Accessor Methods
- (void) setDelegate:(id)aDelegate;

@end
