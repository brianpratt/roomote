//
//  ServerPickerController.h
//  Roomote
//
//  Created by Brian on 2/12/09.
//  Copyright 2009 Brian Pratt. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ServerPickerController;

@protocol ServerPickerControllerDelegate <NSObject>
@required
// This method will be invoked when the user selects one of the service instances from the list.
// The ref parameter will be the selected (already resolved) instance or nil if the user taps the 'Cancel' button (if shown).
- (void) serverPickerController:(ServerPickerController*)spc didResolveInstance:(NSNetService*)ref;
- (void) reloadServerPickerView;
@end

@interface ServerPickerController : NSObject<UIPickerViewDelegate, UIPickerViewDataSource> {
	
@private
	id<ServerPickerControllerDelegate> _delegate;
	NSString* _searchingForServicesString;
	NSString* _ownName;
	NSNetService* _ownEntry;
	BOOL _showDisclosureIndicators;
	NSMutableArray* _services;
	NSNetServiceBrowser* _netServiceBrowser;
	NSNetService* _currentResolve;
	NSTimer* _timer;
	BOOL _needsActivityIndicator;
	BOOL _initialWaitOver;

}

@property (nonatomic, assign) id<ServerPickerControllerDelegate> delegate;
@property (nonatomic, copy) NSString* searchingForServicesString;
@property (nonatomic, copy) NSString* ownName;

- (BOOL)searchForServicesOfType:(NSString *)type inDomain:(NSString *)domain;

@end
