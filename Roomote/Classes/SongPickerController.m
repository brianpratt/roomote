//
//  SongPickerController.m
//  Roomote
//
//  Created by Brian on 2/11/09.
//  Copyright 2009 Brian Pratt. All rights reserved.
//

#import "SongPickerController.h"


@implementation SongPickerController

- (id)init {
    if (self = [super init]) {
		songNameList = NULL;
		numSongs = 0;
    }
    return self;	
}

- (void)dealloc {
	
	free(songNameList);
	
	[super dealloc];
}


#pragma mark ---- Accesssor methods ----

- (SongName*) songNameList {
	return songNameList;
}

- (NSString*) songName:(unsigned)songNum {
	
	NSString* songName;
	if (songNameList != NULL && songNum < numSongs) {
		songName = [NSString stringWithCString:songNameList[songNum].name encoding:NSASCIIStringEncoding];
	}
	else {
		songName = [NSString stringWithFormat:@"Song %d", songNum];
	}
	
	return songName;
}

- (void)setDelegate:(id)aDelegate {
	delegate = aDelegate;
}

- (void) setSongNameList:(SongName*)newSongNameList count:(unsigned)newNumSongs {
	if (songNameList == NULL)
		free(songNameList);
	
	songNameList = newSongNameList;
	numSongs = newNumSongs;
	
	[delegate reloadSongPickerView];
}


#pragma mark ---- UIPickerViewDataSource delegate methods ----

// returns the number of columns to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

// returns the number of rows
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	if (songNameList == NULL)
		return 1;
	else
		// The first row is just a placeholder to force the user to actually select a song
		return numSongs+1;
}

#pragma mark ---- UIPickerViewDelegate delegate methods ----

// returns the title of each row
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	
	NSString* songName;
	if (songNameList != NULL) {
		// The first row is just a placeholder to force the user to actually select a song
		if (row == 0)
			songName = @"- Select a song:";
		else
			songName = [NSString stringWithCString:songNameList[row-1].name encoding:NSASCIIStringEncoding];
	}
	else {
		//songName = @"Hit \"Refresh\" to retrieve song list";
		songName = @"Loading...";
	}
	
	return songName;
}

// gets called when the user settles on a row
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	
	if (numSongs == 0 || songNameList == NULL) {
		NSLog(@"User picked a song when the song list was empty. This can't happen, right?");
		return;
	}
	
	// The first row is just a placeholder to force the user to actually select a song
	if (row == 0) {
		//return;
		[pickerView selectRow:1 inComponent:0 animated:YES];
		row = 1;
	}
	
	// Call the delegate method to pass this information along
	[delegate setSongNum:row-1];
}


@end
