//
//  A1AllDataSource.h
//  A1Lib
//
//  Created by Hidetomo Katsura on 11/30/2004.
//  Copyright 2004 Hidetomo Katsura. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "A1Lib.h"

// NOTE: believe it or not, the MIDI implementation chart in the A1 owner's manual is incorrect.
//	the patch name length is actually 12, not 10. and the total patch size is 192 bytes, not 190 bytes.

#define kA1PatchNameOffset	0
#define kA1PatchNameLength	12
#define kA1PatchDataLength	192
#define kA1AllDataSize		( kA1PatchDataLength * 100 + 6 + 100 )

enum
{
	// utility parameters
	kA1MIDIVolumeOffset,
	kA1DigitalInOffset,
	kA1EmphasisModeOffset,
	kA1EmphasisStatusOffset,
	kA1Pedal1AssignmentOffset,
	kA1Pedal2AssignmentOffset
};

typedef struct A1Patch
{
	UInt8	data[ kA1PatchDataLength ];		// 190 byte data
} A1Patch;

typedef struct A1AllData
{
	UInt8	sysExHeader[ 4 ];				// F0, 42, 3n, 2C: Exclusive Header
	UInt8	sysExType;						// 50: A1 All Data
	UInt8	format;							// 00 or 01: Internal or Card
	
	A1Patch	patch[ 100 ];					// 100 patches
	
	UInt8	utility[ 6 ];					// Utility Parameters
	
	UInt8	map[ 100 ];						// Map Parameters
} A1AllData;

@interface A1AllDataSource : NSObject
{
	A1AllData	data;
}

- (NSInteger)numberOfRows;
- (BOOL)setSyxData:(NSData *)inSyxData;
- (NSData *)syxData;

- (void)setMIDICh:(NSInteger)midiCh;
- (NSInteger)midiCh;

- (NSInteger)mapAt:(NSInteger)inRow;
- (void)setMap:(NSInteger)inMap at:(NSInteger)inRow;

- (NSInteger)utilityDataAt:(NSInteger)inOffset;
- (void)setUtilityData:(NSInteger)inData at:(NSInteger)inOffset;

- (NSString *)patchNameAt:(NSInteger)inRow;
- (void)setPatchName:(NSString *)inName at:(NSInteger)inRow;
- (NSData *)patchDataAt:(NSInteger)inRow;
- (void)setPatchData:(NSData *)inPatchData at:(NSInteger)inRow;

@end
