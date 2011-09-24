//
//  BonjourBrowser.h
//  Roomote
//
//  Created by Brian on 2/12/09.
//  Copyright 2009 Brian Pratt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerPickerController.h"

@class BonjourBrowser;

@protocol BonjourBrowserDelegate <NSObject>
@required
// This method will be invoked when the user selects one of the service instances from the list.
// The netService parameter will be the selected (already resolved) instance or nil if the user taps the 'Cancel' button (if shown).
- (void) bonjourBrowser:(BonjourBrowser*)browser didResolveInstance:(NSNetService*)netService;
@end

@interface BonjourBrowser : UIView <ServerPickerControllerDelegate> {
	
	id<BonjourBrowserDelegate>			delegate;
    UINavigationBar						*pickerNavigationBar;
	ServerPickerController				*serverPickerController;
	UIPickerView						*serverPickerView;
	NSNetService						*netService;
}

//@property (nonatomic, assign) id<BonjourBrowserDelegate> delegate;
@property (nonatomic, retain) ServerPickerController	*serverPickerController;
@property (nonatomic, retain) UINavigationBar *pickerNavigationBar;
@property (nonatomic, retain) UIPickerView	*serverPickerView;
@property (nonatomic, retain) NSNetService	*netService;

- (id)initWithFrame:(CGRect)frame type:(NSString*)type;
- (void) setDelegate:(id)aDelegate;
- (void) reloadServerPickerView;
- (void) serverPickerController:(ServerPickerController*)spc didResolveInstance:(NSNetService*)ref;
- (void) doneSelecting;

@end
