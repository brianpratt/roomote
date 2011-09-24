//
//  SongPickerController.h
//  Roomote
//
//  Created by Brian on 2/11/09.
//  Copyright 2009 Brian Pratt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "networking.h"

@class SongPickerController;

@protocol SongPickerControllerDelegate
@required
- (void) setSongNum:(unsigned)songNum;
- (void) reloadSongPickerView;
@end


@interface SongPickerController : NSObject<UIPickerViewDelegate, UIPickerViewDataSource> {
	
	id<SongPickerControllerDelegate>	delegate;
	SongName							*songNameList;
	unsigned							numSongs;
	
}

// Accessor Methods
- (SongName*) songNameList;
- (NSString*) songName:(unsigned)songNum;
- (void) setDelegate:(id)aDelegate;
- (void) setSongNameList:(SongName*)newSongNameList count:(unsigned)newNumSongs;

@end
