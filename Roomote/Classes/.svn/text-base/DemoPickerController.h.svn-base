//
//  DemoPickerController.h
//  Roomote
//
//  Created by Brian on 2/12/09.
//  Copyright 2009 Brian Pratt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "networking.h"

@class DemoPickerController;

@protocol DemoPickerControllerDelegate
@required
- (void) setDemoNum:(unsigned)demoNum;
//- (void) setSelectDemoFieldText:(NSString*)newDemoText;
- (void) reloadDemoPickerView;
@end


@interface DemoPickerController : NSObject<UIPickerViewDelegate, UIPickerViewDataSource> {
	
	id<DemoPickerControllerDelegate>	delegate;
	DemoName							*demoNameList;
	unsigned							numDemos;
	
}

// Accessor Methods
- (DemoName*) demoNameList;
- (NSString*) demoName:(unsigned)demoNum;
- (void) setDelegate:(id)aDelegate;
- (void) setDemoNameList:(DemoName*)newDemoNameList count:(unsigned)newNumDemos;

@end
