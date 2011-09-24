//
//  DemoPickerController.m
//  Roomote
//
//  Created by Brian on 2/12/09.
//  Copyright 2009 Brian Pratt. All rights reserved.
//

#import "DemoPickerController.h"


@implementation DemoPickerController

- (id)init {
    if (self = [super init]) {
		demoNameList = NULL;
		numDemos = 0;
    }
    return self;	
}

- (void)dealloc {
	
	free(demoNameList);
	
	[super dealloc];
}


#pragma mark ---- Accesssor methods ----

- (DemoName*) demoNameList {
	return demoNameList;
}

- (NSString*) demoName:(unsigned)demoNum {
	
	NSString* demoName;
	if (demoNameList != NULL && demoNum < numDemos) {
		demoName = [NSString stringWithCString:demoNameList[demoNum].name encoding:NSASCIIStringEncoding];
	}
	else {
		demoName = [NSString stringWithFormat:@"Demo %d", demoNum];
	}
	
	return demoName;
}

- (void)setDelegate:(id)aDelegate {
	delegate = aDelegate;
}

- (void) setDemoNameList:(DemoName*)newDemoNameList count:(unsigned)newNumDemos {
	if (demoNameList == NULL)
		free(demoNameList);
	
	demoNameList = newDemoNameList;
	numDemos = newNumDemos;
	
	[delegate reloadDemoPickerView];
}


#pragma mark ---- UIPickerViewDataSource delegate methods ----

// returns the number of columns to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

// returns the number of rows
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	if (demoNameList == NULL)
		return 1;
	else
		// The first row is just a placeholder to force the user to actually select a demo
		return numDemos+1;
}

#pragma mark ---- UIPickerViewDelegate delegate methods ----

// returns the title of each row
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	
	NSString* demoName;
	if (demoNameList != NULL) {
		// The first row is just a placeholder to force the user to actually select a demo
		if (row == 0)
			demoName = @"- Select a demo:";
		else
			demoName = [NSString stringWithCString:demoNameList[row-1].name encoding:NSASCIIStringEncoding];
	}
	else {
		//demoName = @"Hit \"Refresh\" to retrieve demo list";
		demoName = @"Loading...";
	}
	
	return demoName;
}

// gets called when the user settles on a row
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	
	if (numDemos == 0 || demoNameList == NULL) {
		NSLog(@"User picked a demo when the song list was empty. This can't happen, right?");
		return;
	}
	
	// The first row is just a placeholder to force the user to actually select a demo
	if (row == 0) {
		//return;
		[pickerView selectRow:1 inComponent:0 animated:YES];
		row = 1;
	}
	
	// Call the delegate method to pass this information along
	[delegate setDemoNum:row-1];
}


@end
