//
//  CustomCommandEditViewController.m
//  Roomote
//
//  Created by Brian on 1/20/10.
//  Copyright 2010 Brian Pratt. All rights reserved.
//

#import "CustomCommandEditViewController.h"
#import "UserDefaults.h"


@implementation CustomCommandEditViewController

@synthesize textView;
@synthesize commandNameTextField;
@synthesize commandTextField;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil commandNumber:(NSUInteger)commandNumberToEdit {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Save the command number to load/edit
		commandNumber = commandNumberToEdit;
    }
    return self;
}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	// Load the custom command name
	NSString* customCommandName = [UserDefaults customCommandName: commandNumber];
	// Load the text field with the saved text, if any
	if (customCommandName != nil)
		self.commandNameTextField.text = customCommandName;
	
	// Load the custom command bytes
	NSString* customCommand = [UserDefaults customCommandAsString: commandNumber];
	// Load the text field with the saved text, if any
	if (customCommand != nil)
		self.commandTextField.text = customCommand;
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[textView release];
	[commandTextField release];
	[commandNameTextField release];
	
    [super dealloc];
}



#pragma mark ---- Accesssor methods ----

- (void)setDelegate:(id)aDelegate {
	delegate = aDelegate;
}


#pragma mark ---- IBAction Methods ----

- (IBAction)doneEditingCustomCommand {
	
	// Remove any keyboards
	[commandNameTextField resignFirstResponder];
	[commandTextField resignFirstResponder];
	
	// Save the user-entered command name
	[UserDefaults setCustomCommandName: commandNumber withString: self.commandNameTextField.text];
	// Save the command
	[UserDefaults setCustomCommand: commandNumber withString: self.commandTextField.text];
	
	// Send the custom command name to the delegate
	[delegate setCustomCommandName: commandNumber toString: commandNameTextField.text];
	
	// Instruct the delegate to remove the entire CustomCommandEditViewController
	[delegate doneEditingCustomCommand];
}


#pragma mark ---- UITextFieldDelegate Methods ----

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	// Shrink the text view so the user can see it even while the keyboard is up
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	self.textView.frame = CGRectMake(20.0, 132.0, 280.0, 328.0-216.0);
	[UIView commitAnimations];
}

- (BOOL) validateCommandString: (NSString*) commandString {
	// This string should:
	// 1. Contain only numbers and commas
	// 2. Not start with a comma
	// 3. Have numbers between all commas
	// 4. Have a number after the last comma
	// 5. Have a maximum of three numbers in each set of numbers OR
	// 5. The maximum value for each number is 255
	// 6. Have no more than MAX_CUSTOM_COMMAND_LENGTH numbers
	
	// 0. Allow empty string
	if ([commandString length] == 0) {
		return YES;
	}
	// 1. Contain only numbers and commas
	NSCharacterSet* numbersAndCommasSet = [NSCharacterSet characterSetWithCharactersInString: @",0123456789"];
	NSCharacterSet* allButNumbersAndCommasSet = [numbersAndCommasSet invertedSet];
	NSRange allButNumbersAndCommasRange = [commandString rangeOfCharacterFromSet:allButNumbersAndCommasSet];
	if (allButNumbersAndCommasRange.location != NSNotFound) {
		return NO;
	}
	// 2. Not start with a comma
	if ([commandString hasPrefix: @","]) {
		return NO;
	}
	// 3. Have numbers between all commas (no two commas in a row)
	NSRange twoCommas = [commandString rangeOfString: @",,"];
	if (twoCommas.location != NSNotFound) {
		return NO;
	}
	// 4. Have a number after the last comma
	// Must allow this during editing!
	//if ([commandString hasSuffix: @","]) {
	//	return NO;
	//}
	// 5. Have a maximum of three numbers in each set of numbers OR
	// 5. The maximum value for each number is 255
	NSArray* numbers = [commandString componentsSeparatedByString: @","];
	//    Make sure each entry is a valid number (< 256)
	for (int i=0; i < [numbers count]; i++) {
		int number = [[numbers objectAtIndex: i] intValue];
		if (number < 0 || number > 255) {
			return NO;
		}
	}
	// 6. Have no more than MAX_CUSTOM_COMMAND_LENGTH numbers
	if ([numbers count] > MAX_CUSTOM_COMMAND_LENGTH)
		return NO;
	
	// Passed all the tests! The string is valid.
	return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	
	int textFieldID = [textField tag];
	NSString* newText;
	//NSLog(string);
	//NSLog(@"Range: %d, %d", range.location, range.length);
	
	switch (textFieldID) {
		case 0:
			// Custom Command Name Text Field
			if ([textField.text length] - range.length > kMaxCustomCommandNameLength)
				return NO;
			else
				return YES;
			break;
		case 1:
			// Custom Command (Bytes) Text Field
			// Limit the number of command bytes the user can enter
			// (count the number of commas entered?)
			// (also restrict to numbers and commas only)
			
			// Create the full new string
			newText = [NSString stringWithString: textField.text];
			//NSLog(@"Old commandString: %@", newText);
			newText = [newText stringByReplacingCharactersInRange: range withString: string];
			//NSLog(@"New commandString: %@", newText);
			
			// Make sure the new string is valid
			return [self validateCommandString: newText];
			
			break;
		default:
			break;
	}
	return YES;
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
	// Save the data in the text field when the user taps outside the keyboard area
	
	int textFieldID = [textField tag];
	
	switch (textFieldID) {
		case 0:
			// Custom Command Name Text Field
			// Save the user-entered command name
			[UserDefaults setCustomCommandName: commandNumber withString: textField.text];
			break;
		case 1:
			// Custom Command (Bytes) Text Field
			// Save the command
			[UserDefaults setCustomCommand: commandNumber withString: textField.text];
			break;
		default:
			break;
	}
	
	// Remove the text field's keyboard
	[textField resignFirstResponder];
	
	// Re-enlarge the text view so the user has more space to read while the keyboard is down
	self.textView.frame = CGRectMake(20.0, 132.0, 280.0, 328.0);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {

	// Remove the text field's keyboard
	[textField resignFirstResponder];
	
	return YES;
}

@end
