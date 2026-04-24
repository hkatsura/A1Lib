//
//  A1AllDataSource.m
//  A1Lib
//
//  Created by Hidetomo Katsura on 11/30/2004.
//  Copyright 2004 Hidetomo Katsura. All rights reserved.
//

#import "A1AllDataSource.h"

@implementation A1AllDataSource

static void ConvertKorgSysExToBinary( const UInt8 *inSysEx, UInt8 *outData, NSInteger inLength );
static NSData *ConvertBinaryToKorgSysEx( const UInt8 *inData, NSInteger inLength );

- (id)init
{
	self = [super init];
	if ( self != nil )
	{
		DEBUGLOG( @"A1AllDataSource init" );

		// exclusive header
		data.sysExHeader[ 0 ] = 0xf0;
		data.sysExHeader[ 1 ] = 0x42;
		data.sysExHeader[ 2 ] = 0x30;
		data.sysExHeader[ 3 ] = 0x2c;
		
		data.sysExType = 0x50;
		data.format = 0;
		
		NSString *path = [NSString stringWithFormat:@"%@/A1Preset", [[NSBundle mainBundle] resourcePath]];
		NSData *presetData = [NSData dataWithContentsOfMappedFile:path];
		if ( presetData != nil )
		{
			bcopy( [presetData bytes], &data.patch[ 0 ].data[ 0 ], kA1AllDataSize );
		}
		else
		{
			// patch
			for (NSInteger idx = 0; idx < 100; ++idx)
			{
				static const A1Patch defaultPatch =
				{ {
					0x41, 0x31, 0x20, 0x45, 0x58, 0x41, 0x4d, 0x50, 0x4c, 0x45, 0x20, 0x20, 0x00, 0x07, 0x01, 0x1c,
					0x00, 0x00, 0x64, 0x14, 0x0a, 0x0a, 0x05, 0x1e, 0x14, 0x0a, 0x0a, 0x05, 0x1e, 0x0a, 0x00, 0x64,
					0x46, 0x09, 0x9c, 0xa0, 0x34, 0x67, 0x01, 0x2a, 0x00, 0x00, 0x64, 0x05, 0x0e, 0x05, 0x0e, 0x01,
					0x64, 0x01, 0x7c, 0x73, 0x46, 0x32, 0x32, 0x32, 0x46, 0x09, 0x9c, 0xa0, 0x34, 0x67, 0x01, 0x0e,
					0x00, 0x00, 0x64, 0x02, 0x00, 0x00, 0x00, 0x64, 0x02, 0x00, 0x00, 0x00, 0x64, 0x01, 0x32, 0x64,
					0x46, 0x09, 0x9c, 0xa0, 0x34, 0x67, 0x01, 0x01, 0x02, 0x00, 0x64, 0x19, 0x28, 0x0a, 0x0f, 0x41,
					0x5a, 0x64, 0xfe, 0x03, 0x64, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00,
					0x00, 0x00, 0x64, 0x00, 0x0a, 0x00, 0x64, 0x32, 0x0a, 0x00, 0x64, 0x00, 0x00, 0x32, 0x32, 0x00,
					0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x64, 0x00, 0x00, 0x05, 0xfd, 0x28,
					0x0d, 0x00, 0xe2, 0x14, 0x32, 0x00, 0x32, 0x32, 0x46, 0x09, 0x9c, 0xa0, 0x34, 0x67, 0x01, 0x00,
					0x00, 0x00, 0x64, 0x00, 0x30, 0x2f, 0xce, 0x35, 0x00, 0x50, 0x32, 0x00, 0x00, 0x00, 0x00, 0x00,
					0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x64, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
				} };
				
				bcopy( &defaultPatch, &data.patch[ idx ].data[ 0 ], kA1PatchDataLength );
			}
			
			// utility parameters
			data.utility[ kA1MIDIVolumeOffset ] = 0;
			data.utility[ kA1DigitalInOffset ] = 0;
			data.utility[ kA1EmphasisModeOffset ] = 1;		// manual
			data.utility[ kA1EmphasisStatusOffset ] = 0;
			data.utility[ kA1Pedal1AssignmentOffset ] = 0;	// program up
			data.utility[ kA1Pedal2AssignmentOffset ] = 1;	// program down
			
			// map parameters
			for (NSInteger idx = 0; idx < 100; ++idx)
			{
				data.map[ idx ] = idx;
			}
		}
	}
	
	return self;
}

- (NSInteger)numberOfRows
{
	return 100;
}

static void ConvertKorgSysExToBinary( const UInt8 *inSysEx, UInt8 *outData, NSInteger inLength )
{
	for ( ;; )
	{
		UInt8 highBits;

		highBits = *inSysEx++;
		for (NSInteger idx = 0; idx < 7; ++idx)
		{
			UInt8 byte;
			
			byte = *inSysEx++;
			if ( highBits & 0x01 )
			{
				byte |= 0x80;
			}
			highBits >>= 1;
			*outData++ = byte;
			--inLength;
			if ( inLength <= 0 )
			{
				return;
			}
		}
	}
}

- (BOOL)setSyxData:(NSData *)inSyxData
{
	BOOL validData;
	const UInt8 *bytes;
	
	// convert syx to binary data
	bytes = [inSyxData bytes];
	bcopy( bytes, &data, 6 );
	validData = ( ( data.sysExHeader[ 0 ] == 0xF0 ) &&
		( data.sysExHeader[ 1 ] == 0x42 ) &&
		( ( data.sysExHeader[ 2 ] & 0xF0 ) == 0x30 ) &&
		( data.sysExHeader[ 3 ] == 0x2C ) &&
		( data.sysExType == 0x50 ) &&
		( data.format == 0x00 ) );
	if ( validData )
	{
		ConvertKorgSysExToBinary( &bytes[ 6 ], &data.patch[ 0 ].data[ 0 ], kA1AllDataSize );
	}
	DEBUGLOG( @"valid syx: %s", validData? "YES": "NO" );
	
	//[[NSData dataWithBytes:&data.patch[ 0 ].data[ 0 ] length:kA1AllDataSize] writeToFile:@"/tmp/A1Preset" atomically:YES];
	//NSLog( @"#99: %@", [NSData dataWithBytes:&data.patch[ 99 ].data[ 0 ] length:kA1PatchDataLength] );
	
	return validData;
}

static NSData *ConvertBinaryToKorgSysEx( const UInt8 *inData, NSInteger inLength )
{
	NSMutableData *syxData;
	UInt8 *bytes;
	
	syxData = [NSMutableData dataWithLength:( inLength / 7 * 8 )];
	bytes = [syxData mutableBytes];
	for ( ;; )
	{
		UInt8 highBits = 0;
		++bytes;
		for (NSInteger idx = 0; idx < 7; ++idx)
		{
			UInt8 byte = *inData++;
			highBits |= ( byte & 0x80 );
			highBits >>= 1;
			
			*bytes++ = ( byte & 0x7f );
			--inLength;
		}
		
		bytes[ -8 ] = highBits;
		
		if ( inLength <= 0 )
		{
			break;
		}
	}
	
	//NSLog( @"syxData: %@", syxData );
	
	return syxData;
}

- (NSData *)syxData
{
	// convert binary data to syx
	NSMutableData *patchData;
	UInt8 eox;
	
	eox = 0xf7;
	patchData = [NSMutableData dataWithBytes:&data length:6];
	[patchData appendData:ConvertBinaryToKorgSysEx( &data.patch[ 0 ].data[ 0 ], kA1AllDataSize )];
	[patchData appendBytes:&eox length:1];
	
	return patchData;
}

- (void)setMIDICh:(NSInteger)midiCh
{
	data.sysExHeader[ 2 ] = 0x30 + midiCh;
}

- (NSInteger)midiCh
{
	return ( data.sysExHeader[ 2 ] & 0x0F );
}

- (NSInteger)mapAt:(NSInteger)inRow
{
	return data.map[ inRow ];
}

- (void)setMap:(NSInteger)inMap at:(NSInteger)inRow
{
	data.map[ inRow ] = inMap;
}

- (NSInteger)utilityDataAt:(NSInteger)inOffset
{
	return data.utility[ inOffset ];
}

- (void)setUtilityData:(NSInteger)inData at:(NSInteger)inOffset
{
	data.utility[ inOffset ] = inData;
}

- (NSString *)patchNameAt:(NSInteger)inRow
{
	// patch name
	return [NSString stringWithFormat:@"%.*s", kA1PatchNameLength, &data.patch[ inRow ].data[ kA1PatchNameOffset ]];
}

- (void)setPatchName:(NSString *)inName at:(NSInteger)inRow
{
	NSUInteger idx, length;
	
	// set patch name
	length = [inName length];
	for ( idx = 0; idx < kA1PatchNameLength; ++idx )
	{
		unichar uchar;
		
		if ( idx < length )
		{
			uchar = [inName characterAtIndex:idx];
			if ( ( uchar < 0x20 ) || ( uchar > 0x7f ) )
			{
				uchar = 0x20;
			}
		}
		else
		{
			uchar = 0x20;
		}
		
		data.patch[ inRow ].data[ kA1PatchNameOffset + idx ] = uchar;
	}

	DEBUGLOG( @"name: %.*s", kA1PatchNameLength, &data.patch[ inRow ].data[ kA1PatchNameOffset ] );
}

- (NSData *)patchDataAt:(NSInteger)inRow
{
	return [NSData dataWithBytes:&data.patch[ inRow ] length:kA1PatchDataLength];
}

- (void)setPatchData:(NSData *)inPatchData at:(NSInteger)inRow
{
	bcopy( [inPatchData bytes], &data.patch[ inRow ], kA1PatchDataLength );
}

@end
