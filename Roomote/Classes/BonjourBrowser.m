//
//  BonjourBrowser.m
//  Roomote
//
//  Created by Brian on 2/12/09.
//  Copyright 2009 Brian Pratt. All rights reserved.
//

#import "BonjourBrowser.h"
#import "constants.h"

@implementation BonjourBrowser


//@synthesize delegate;
@synthesize pickerNavigationBar;
@synthesize serverPickerController;
@synthesize	serverPickerView;
@synthesize	netService;


- (id)initWithFrame:(CGRect)frame type:(NSString*)type {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		self.netService = nil;
		
		// Set up the ServerPickerController
		ServerPickerController *aServerPickerController = [[ServerPickerController alloc] init];
		[aServerPickerController setDelegate:self];
		self.serverPickerController = aServerPickerController;
		[aServerPickerController release];
		
		// Start browsing for services
		[self.serverPickerController searchForServicesOfType:type inDomain:@"local"];
		
		
		// Set up the Picker navigation bar
		//UINavigationBar *aNavigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0.0, kScreenHeightNoStatus-kPickerViewHeight-kNavigationBarHeight, 320.0, kNavigationBarHeight)];
		UINavigationBar *aNavigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, kNavigationBarHeight)];
		aNavigationBar.barStyle = UIBarStyleBlackOpaque;
		self.pickerNavigationBar = aNavigationBar;
		[aNavigationBar release];
		UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneSelecting)];
		UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:@"Select Roomote Server:"];
		navigationItem.rightBarButtonItem = buttonItem;
		[pickerNavigationBar pushNavigationItem:navigationItem animated:NO];
		[navigationItem release];
		[buttonItem release];
		
		// Set up the ServerPickerView
		//UIPickerView *aServerPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0, kScreenHeightNoStatus-kPickerViewHeight, 320.0, kPickerViewHeight)];
		UIPickerView *aServerPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0, kNavigationBarHeight, 320.0, kPickerViewHeight)];
		aServerPickerView.showsSelectionIndicator = YES;
		aServerPickerView.delegate = serverPickerController;
		aServerPickerView.dataSource = serverPickerController;
		self.serverPickerView = aServerPickerView;
		[aServerPickerView release];
		
		
		[self addSubview:self.serverPickerView];
		[self addSubview:self.pickerNavigationBar];
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
}

- (void)setDelegate:(id)aDelegate {
	delegate = aDelegate;
}


- (void) serverPickerController:(ServerPickerController*)spc didResolveInstance:(NSNetService*)ref {
	//[delegate bonjourBrowser:self didResolveInstance:ref];
	self.netService = ref;
}

- (void) doneSelecting {
	[delegate bonjourBrowser:self didResolveInstance:netService];
}

- (void) reloadServerPickerView {
	[self.serverPickerView reloadAllComponents];
}

/*
- (id<ServerPickerControllerDelegate>)delegate {
	return self.serverPickerController.delegate;
}


- (void)setDelegate:(id<ServerPickerControllerDelegate>)delegate {
	[self.serverPickerController setDelegate:delegate];
}
*/

- (void)dealloc {
	[self.serverPickerView release];
	[self.pickerNavigationBar release];
	[self.serverPickerController release];
	
    [super dealloc];
}


@end
