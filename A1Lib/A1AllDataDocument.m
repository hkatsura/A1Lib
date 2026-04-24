//
//  A1AllDataDocument.m
//  A1Lib
//
//  Created by Hidetomo Katsura on 11/30/2004.
//  Copyright Hidetomo Katsura 2004 . All rights reserved.
//

#import "A1AllDataDocument.h"
#import "A1AllDataSource.h"
#import "PrintView.h"

#define	kA1PatchDataPboardType		@"com.katsurashareware.a1lib.patch"
#define	kA1MapDataPboardType		@"com.katsurashareware.a1lib.map"
#define kA1PatchNumberPboardType	@"com.katsurashareware.a1lib.number"

@interface A1AllDataDocument ()

    // table views
@property (weak) IBOutlet NSTableView *patchTableView;
@property (weak) IBOutlet NSTableView *mapTableView;

    // checkboxes
@property (weak) IBOutlet NSButton *midiVolumeCheckbox;
@property (weak) IBOutlet NSButton *digitalInCheckbox;
@property (weak) IBOutlet NSButton *emphasisCheckbox;

    // popup buttons
@property (weak) IBOutlet NSPopUpButton *emphasisModePopUpButton;
@property (weak) IBOutlet NSPopUpButton *pedal1PopUpButton;
@property (weak) IBOutlet NSPopUpButton *pedal2PopUpButton;

    // midi channel popup button
@property (weak) IBOutlet NSPopUpButton *midiChPopUpButton;

    // A1 all data source
@property (strong, nonatomic) A1AllDataSource *a1AllDataSource;

- (NSData *)dataFromString:(NSString *)string;

@end

@implementation A1AllDataDocument

- (id)init
{
    self = [super init];
    if ( self != nil )
	{
    
        // Add your subclass-specific initialization here.
        // If an error occurs here, send a [self release] message and return nil.
    
		_a1AllDataSource = [[A1AllDataSource alloc] init];
    }
	
    return self;
}

- (void)dealloc
{
    _a1AllDataSource = nil;
}

- (A1AllDataSource *)dataSource
{
	return _a1AllDataSource;
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"A1AllDataDocument";
}

- (void)updateUI
{
	[_midiVolumeCheckbox setState:( [_a1AllDataSource utilityDataAt:kA1MIDIVolumeOffset]? NSOnState: NSOffState )];
	[_digitalInCheckbox setState:( [_a1AllDataSource utilityDataAt:kA1DigitalInOffset]? NSOnState: NSOffState )];
	[_emphasisCheckbox setState:( [_a1AllDataSource utilityDataAt:kA1EmphasisStatusOffset]? NSOnState: NSOffState )];
	
	[_emphasisModePopUpButton selectItemAtIndex:[_a1AllDataSource utilityDataAt:kA1EmphasisModeOffset]];
	[_pedal1PopUpButton selectItemAtIndex:[_a1AllDataSource utilityDataAt:kA1Pedal1AssignmentOffset]];
	[_pedal2PopUpButton selectItemAtIndex:[_a1AllDataSource utilityDataAt:kA1Pedal2AssignmentOffset]];
	
	[_midiChPopUpButton selectItemAtIndex:[_a1AllDataSource midiCh]];

	[_patchTableView reloadData];
    [_patchTableView scrollRowToVisible:0];
	[_mapTableView reloadData];
    [_mapTableView scrollRowToVisible:0];
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
   
	// Add any code here that needs to be executed once the windowController has loaded the document's window.

    // We tell the table that we'll be dragging in string
    [_patchTableView registerForDraggedTypes:[NSArray arrayWithObjects:kA1PatchDataPboardType, NSStringPboardType, nil]];
    [_mapTableView registerForDraggedTypes:[NSArray arrayWithObjects:kA1PatchNumberPboardType, nil]];

	[self updateUI];
}

//- (NSData *)dataRepresentationOfType:(NSString *)aType
- (nullable NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
	#pragma unused( typeName )
	
	DEBUGLOG( @"dataOfType:(%@) error:", typeName );
	
   // Insert code here to write your document from the given data.  You can also choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.
    NSData *data = [_a1AllDataSource syxData];

	DEBUGLOG( @"outData: 0x%x, length: %d", data, [data length] );
	
    return data;
}

//- (BOOL)loadDataRepresentation:(NSData *)data ofType:(NSString *)aType
- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
	#pragma unused( typeName )
	
	DEBUGLOG( @"readFromData:(%@)", typeName );
	
	// Insert code here to read your document from the given data.  You can also choose to override -loadFileWrapperRepresentation:ofType: or -readFromFile:ofType: instead.
    BOOL validData = [_a1AllDataSource setSyxData:data];
	if ( validData )
	{
		[self updateUI];
	}
    else
    {
        if (outError != nil)
        {
            NSError *error = [NSError errorWithDomain:@"com.katsurashareware.a1lib" code:1 userInfo:@{NSLocalizedDescriptionKey: @"Invalid Data"}];
            *outError = error;
        }
    }

	DEBUGLOG( @"inData: 0x%x, length: %d", data, [data length] );
	DEBUGLOG( @"isValidData: %s", validData? "YES": "NO" );
	
	return validData;
}

- (IBAction)checkboxChanged:(id)sender
{
	DEBUGLOG( @"checkboxChanged" );
	
	NSInteger tag = [sender tag];
	[_a1AllDataSource setUtilityData:( [sender state]? 1: 0 ) at:tag];
	
	DEBUGLOG( @"  tag: %d", tag );

	[self updateChangeCount:NSChangeDone];
}

- (IBAction)popUpButtonChanged:(id)sender
{
	DEBUGLOG( @"popUpButtonChanged" );

	NSInteger tag = [sender tag];
	NSInteger idx = [sender indexOfSelectedItem];
	if ( idx != [_a1AllDataSource utilityDataAt:tag] )
	{
		[_a1AllDataSource setUtilityData:idx at:tag];
		
		[self updateChangeCount:NSChangeDone];
	}
	
	DEBUGLOG( @"  tag: %d, idx: %d", tag, idx );
}

- (IBAction)midiChChanged:(id)sender
{
	#pragma unused( sender )
	
	NSInteger idx = [_midiChPopUpButton indexOfSelectedItem];
	if ( idx != [_a1AllDataSource midiCh] )
	{
		[_a1AllDataSource setMIDICh:idx];

		[self updateChangeCount:NSChangeDone];
	}
}

- (BOOL)isPastable:(NSTableView *)tableView
{
	NSPasteboard *pasteboard;
	NSData *pasteData;
	NSString *pasteType, *string;

	//grab the general pasteboard
	pasteboard = [NSPasteboard generalPasteboard];
	
	pasteType = ( ( tableView == _patchTableView )? kA1PatchDataPboardType: kA1PatchNumberPboardType );
	
	//get the content from the pasteboard for our data type 
	pasteData = [pasteboard dataForType:pasteType];
	NSUInteger length = [pasteData length];
	if ( length != 0 )
	{
		return YES;
	}
	
	if ( tableView != _patchTableView )
	{
		// nothing to paste
		return NO;
	}
	
	// check if there is a string type patch data
	string = [pasteboard stringForType:NSStringPboardType];
	length = [string length];
	if ( length != 0 )
	{
		pasteData = [self dataFromString:string];
		length = [pasteData length];
		if ( length != 0 )
		{
			return YES;
		}
	}

	return NO;
}

- (BOOL)validateMenuItem:(NSMenuItem *)anItem
{
	SEL action;
	
	action = [anItem action];
	if ( ( action == @selector( copy: ) ) ||
		( action == @selector( delete: ) ) ||
		( action == @selector( paste: ) ) ||
		( action == @selector( cut: ) ) )
	{
		NSTableView *tableView;
		
		tableView = (NSTableView *) [[_patchTableView window] firstResponder];
		if ( ( tableView == _patchTableView ) || ( tableView == _mapTableView ) )
		//if ( tableView == patchTableView )
		{
			if ( action == @selector( paste: ) )
			{
				return [self isPastable:tableView];
			}
			else
			{
				return ( [tableView numberOfSelectedRows] != 0 );
			}
		}
		else
		{
			return NO;
		}
	}
	else if ( action == @selector( revertDocumentToSaved: ) )
	{
		return ( [self isDocumentEdited] && ( [self fileURL] != nil ) );
	}
	else if ( action == @selector( saveDocument: ) )
	{
		return ( [self isDocumentEdited] || ( [self fileURL] == nil ) );
	}
	
	return [super validateMenuItem:anItem];
}

// convert NSString -> NSData -> NSPropertyList -> NSData
- (NSData *)dataFromString:(NSString *)string
{
	NSDictionary *dictionary;
	NSData *data;
	NSString *error;
	NSPropertyListFormat format;
	
	dictionary = [NSPropertyListSerialization propertyListFromData:[string dataUsingEncoding:NSUTF8StringEncoding] mutabilityOption:NSPropertyListImmutable format:&format errorDescription:&error];
	if ( dictionary == nil )
	{
		DEBUGLOG( error );
	}
	
	data = ( [dictionary isKindOfClass:[NSDictionary class]] )? [dictionary objectForKey:kA1PatchDataPboardType]: nil;

	DEBUGLOG( @"string -> data: %@", data );

	return data;
}

// convert NSData -> NSPropertyList -> NSData -> NSString
- (NSString *)stringFromData:(NSData *)data
{
	NSData *xmlData;
	NSString *string, *error;
	
	xmlData = [NSPropertyListSerialization dataFromPropertyList:[NSDictionary dictionaryWithObject:data forKey:kA1PatchDataPboardType] format:NSPropertyListXMLFormat_v1_0 errorDescription:&error];
	if ( xmlData == nil )
	{
		DEBUGLOG( error );
	}
	
	string = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
	
	DEBUGLOG( @"data -> string: %@", string );

	return string;
}

- (NSData *)dataWithNumbers:(NSIndexSet *)rows
{
#if 0
	NSUInteger count = [array count];
    UInt8 *buffer = malloc( count );
	for (NSUInteger idx = 0; idx < count; ++idx)
	{
		buffer[ idx ] = [[array objectAtIndex:idx] intValue];
	}
    NSData *data = [NSData dataWithBytes:buffer length:count];
	free( buffer );
#else
    NSUInteger count = rows.count;
    __block UInt8 *buffer = malloc( count );
    __block int i = 0;
    [rows enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
#pragma unused(stop)
        buffer[i++] = (UInt8)idx;
    }];
    NSData *data = [NSData dataWithBytes:buffer length:count];
    free( buffer );
#endif

	//NSLog( @"map data: %@", data );
	
	return data;
}

- (void)writePatchRows:(NSIndexSet *)rows toPasteboard:(NSPasteboard *)pasteboard
{
	NSMutableData *data;
	data = [NSMutableData dataWithCapacity:0];
	
#if 0
    NSNumber *number;
    NSEnumerator *tableEnumerator = [rows objectEnumerator];
	while ( ( number = [tableEnumerator nextObject] ) != nil )
	{
		[data appendData:[_a1AllDataSource patchDataAt:[number intValue]]];
	}
#else
    [rows enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
#pragma unused(stop)
        [data appendData:[_a1AllDataSource patchDataAt:idx]];
    }];
#endif

	DEBUGLOG( @"  numberOfSelectedRows: %d", [patchTableView numberOfSelectedRows] );
	
	//tell the copy/paste system what type of data we'll be putting up there
	[pasteboard declareTypes:[NSArray arrayWithObjects:NSStringPboardType, kA1PatchDataPboardType, kA1PatchNumberPboardType, nil] owner:nil];

	//go ahead and place the display string on the pasteboard for other apps to paste
	[pasteboard setString:[self stringFromData:data] forType:NSStringPboardType];
	[pasteboard setData:data forType:kA1PatchDataPboardType];
	[pasteboard setData:[self dataWithNumbers:rows] forType:kA1PatchNumberPboardType];
}

- (void)writeMapRows:(NSIndexSet *)rows toPasteboard:(NSPasteboard *)pasteboard
{
	//tell the copy/paste system what type of data we'll be putting up there
	[pasteboard declareTypes:[NSArray arrayWithObjects:kA1PatchNumberPboardType, nil] owner:nil];

	//go ahead and place the map numbers
	[pasteboard setData:[self dataWithNumbers:rows] forType:kA1PatchNumberPboardType];
}

- (IBAction)copy:(id)sender
{
	#pragma unused( sender )
	
	DEBUGLOG( @"copy" );

	if ( [[_patchTableView window] firstResponder] == _patchTableView )
	{
		DEBUGLOG( @"  patch table view" );

		[self writePatchRows:[_patchTableView selectedRowIndexes] toPasteboard:[NSPasteboard generalPasteboard]];
	}
	else
	{
		// map table view
		DEBUGLOG( @"  map table view" );

		[self writeMapRows:[_mapTableView selectedRowIndexes] toPasteboard:[NSPasteboard generalPasteboard]];
	}
}

- (void)readFromData:(NSData *)pasteData atRow:(NSInteger)row
{
	NSInteger numberOfPrograms = [pasteData length] / kA1PatchDataLength;
	if ( ( row + numberOfPrograms ) <= [_a1AllDataSource numberOfRows] )
	{
		const UInt8 *dataPtr;
		
		// multiple-to-one paste
		dataPtr = [pasteData bytes];
		while ( numberOfPrograms-- )
		{
			[_a1AllDataSource setPatchData:[NSData dataWithBytes:dataPtr length:kA1PatchDataLength] at:row];
			dataPtr += kA1PatchDataLength;

			++row;
		}
	}
	else
	{
		// doesn't fit error...
		DEBUGLOG( @"  number of selected programs does not fit." );
	}
}

- (void)readMapFromData:(NSData *)pasteData atRow:(NSInteger)row
{
	NSUInteger numberOfPrograms = [pasteData length];
	if ( ( row + numberOfPrograms ) <= 100 )
	{
		const UInt8 *dataPtr;
		
		// multiple-to-one paste
		dataPtr = [pasteData bytes];
		while ( numberOfPrograms-- )
		{
			[_a1AllDataSource setMap:*dataPtr at:row];
			++dataPtr;

			++row;
		}
	}
	else
	{
		// doesn't fit error...
		DEBUGLOG( @"  number of selected programs does not fit." );
	}
}

- (void)readFromPasteboard:(NSPasteboard *)pasteboard toTableView:(NSTableView *)tableView atRow:(NSInteger)row
{
	if ( tableView == _patchTableView )
	{
		DEBUGLOG( @"  patch table view" );

		// get number of selected programs
		// get number of programs in pasteboard
		// show alert if the numbers don't match
		// otherwise, paste
		
		NSData *pasteData;
		NSUInteger length;

		//get the content from the pasteboard for our data type 
		pasteData = [pasteboard dataForType:kA1PatchDataPboardType];
		length = [pasteData length];
		
		DEBUGLOG( @ "  pasteData: %@", pasteData );
		
		if ( length == 0 )
		{
			// try "string"
			NSString *string;
			
			string = [pasteboard stringForType:NSStringPboardType];
			length = [string length];
			if ( length == 0 )
			{
				// nothing to paste
				return;
			}
			
			pasteData = [self dataFromString:string];
			length = [pasteData length];
			if ( length == 0 )
			{
				// nothing to paste
				return;
			}
		}

		//set the program data to the current selection
		NSInteger selectedRows, numberOfPrograms;
		__block const UInt8 *dataPtr;
		
		numberOfPrograms = length / kA1PatchDataLength;
		selectedRows = [tableView numberOfSelectedRows];
		
		if ( row != -1 )
		{
			[self readFromData:pasteData atRow:row];
		}
		else if ( numberOfPrograms == selectedRows )
		{
			// one-to-one paste (1 -> 1 or n -> n)
            dataPtr = [pasteData bytes];
#if 0
            NSNumber *number;
            NSEnumerator *tableEnumerator = [tableView selectedRowEnumerator];
			while ( ( number = [tableEnumerator nextObject] ) != nil )
			{
				int idx;
				
				idx = [number intValue];
				[_a1AllDataSource setPatchData:[NSData dataWithBytes:dataPtr length:kA1PatchDataLength] at:idx];
				dataPtr += kA1PatchDataLength;
			}
#else
            NSIndexSet *rows = [tableView selectedRowIndexes];
            [rows enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
    #pragma unused(stop)
                [_a1AllDataSource setPatchData:[NSData dataWithBytes:dataPtr length:kA1PatchDataLength] at:idx];
                dataPtr += kA1PatchDataLength;
            }];
#endif
		}
		else if ( selectedRows == 1 )
		{
			// multiple-to-one paste
			NSInteger selectedRow;
			
			selectedRow = [tableView selectedRow];
			[self readFromData:pasteData atRow:selectedRow];
		}
		else
		{
			// number of selected programs does not match error...
			DEBUGLOG( @"  number of selected programs does not match." );
			
			return;
		}
	
		[tableView reloadData];
		[self updateChangeCount:NSChangeDone];
			
		// refresh the map table view since one of the patch names has changed
		[_mapTableView setNeedsDisplay:YES];
	}
	else if ( tableView == _mapTableView )
	{
		DEBUGLOG( @"  map table view" );

		NSData *pasteData;
		NSUInteger length;

		//get the content from the pasteboard for our data type 
		pasteData = [pasteboard dataForType:kA1PatchNumberPboardType];
		length = [pasteData length];
		DEBUGLOG( @ "  pasteData: %@", pasteData );
		if ( length != 0 )
		{
			//set the program data to the current selection
			NSInteger selectedRows, numberOfPrograms;
			__block const UInt8 *dataPtr;
			
			numberOfPrograms = length;
			selectedRows = [tableView numberOfSelectedRows];
			
			if ( row != -1 )
			{
				[self readMapFromData:pasteData atRow:row];
			}
			else if ( numberOfPrograms == selectedRows )
			{
				// one-to-one paste (1 -> 1 or n -> n)

				dataPtr = [pasteData bytes];
#if 0
                NSNumber *number;
                NSEnumerator *tableEnumerator = [tableView selectedRowEnumerator];
				while ( ( number = [tableEnumerator nextObject] ) != nil )
				{
					[_a1AllDataSource setMap:*dataPtr at:[number intValue]];
					++dataPtr;
				}
#else
                NSIndexSet *rows = [tableView selectedRowIndexes];
                [rows enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        #pragma unused(stop)
                    [_a1AllDataSource setMap:*dataPtr at:idx];
                    ++dataPtr;
                }];
#endif
			}
			else if ( selectedRows == 1 )
			{
				// multiple-to-one paste
				NSInteger selectedRow = [tableView selectedRow];
				[self readMapFromData:pasteData atRow:selectedRow];
			}
			else
			{
				// number of selected programs does not match error...
				DEBUGLOG( @"  number of selected programs does not match." );
				
				return;
			}
		
			[tableView reloadData];
			[self updateChangeCount:NSChangeDone];
		}
	}
}

- (IBAction)paste:(id)sender
{
	#pragma unused( sender )
	
	DEBUGLOG( @"paste" );

	NSTableView *tableView;
	
	tableView = (NSTableView *) [[_patchTableView window] firstResponder];
	[self readFromPasteboard:[NSPasteboard generalPasteboard] toTableView:tableView atRow:-1];
}

#if 0
- (IBAction)delete:(id)sender
{
	#pragma unused( sender )
	
	DEBUGLOG( @"delete" );

	
	[self updateChangeCount:NSChangeDone];
}

- (IBAction)cut:(id)sender
{
	DEBUGLOG( @"cut" );
	
	[self copy:sender];
	[self delete:sender];
}
#endif

// NSTableDataSource protocol

#define	kNumberColumnIdentifier		@"number"
#define	kNameColumnIdentifier		@"name"
#define	kMapToColumnIdentifier		@"mapTo"

enum
{
	kPatchTableViewTag,
	kMapTableViewTag
};

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	#pragma unused( aTableView )
	
	if ( [aTableView tag] == kPatchTableViewTag )
	{
		return [_a1AllDataSource numberOfRows];
	}
	else
	{
		// map is always 100
		return 100;
	}
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	NSString *identifier = [aTableColumn identifier];
	if ( [identifier isEqualToString:kNumberColumnIdentifier] )
	{
		// patch or map number
		return [NSString stringWithFormat:@"%02ld", (long)rowIndex];
	}
	else if ( [identifier isEqualToString:kNameColumnIdentifier] )
	{
		if ( [aTableView tag] == kPatchTableViewTag )
		{
			// patch name
			return [_a1AllDataSource patchNameAt:rowIndex];
		}
		else
		{
			// map to patch name
			NSInteger map = [_a1AllDataSource mapAt:rowIndex];

			return ( ( map >= 100 )? @"---": [_a1AllDataSource patchNameAt:map] );
		}
	}
	else
	{
		// map to patch number
		NSInteger map = [_a1AllDataSource mapAt:rowIndex];
        return [NSString stringWithFormat:@"%s%02ld", (map >= 100)? "C": "", (long)(map % 100)];
	}
}

- (BOOL)validNumber:(int *)map withObject:(id)anObject
{
	int value;
	BOOL valid;
	
	value = -1;
	valid = [[NSScanner scannerWithString:anObject] scanInt:&value];
	if ( ! valid )
	{
		value = -1;
		valid = [[NSScanner scannerWithString:[anObject substringFromIndex:1]] scanInt:&value];
		if ( ! valid )
		{
			value = -1;		// invalid value
		}
		else
		{
			// C00 ... C99 -> 100 ... 199
			value += 100;
		}
	}
	
	if ( ( value < 0 ) || ( value >= 200 ) )
	{
		NSBeep();
		
		return NO;
	}

	*map = value;
	
	return YES;
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	DEBUGLOG( @"tableView:setObjectValue:forTableColumn:row:" );
	
	if ( aTableView == _patchTableView )
	{
		if ( [[aTableColumn identifier] isEqualToString:kNameColumnIdentifier] )
		{
			DEBUGLOG( @"patchName: \"%@\" at: %d", anObject, rowIndex );
			if ( ! [[_a1AllDataSource patchNameAt:rowIndex] isEqualTo:anObject] )
			{
				[_a1AllDataSource setPatchName:anObject at:rowIndex];
			
				// refresh the map table view since one of the patch names has changed
				[_mapTableView setNeedsDisplay:YES];
				[self updateChangeCount:NSChangeDone];
			}
		}
	}
	else if ( aTableView == _mapTableView )
	{
		if ( [[aTableColumn identifier] isEqualToString:kMapToColumnIdentifier] )
		{
			int map;
			
			// INT: 00 ... 99, CARD: 100 ... 199
			if ( [self validNumber:&map withObject:anObject] )
			{
				DEBUGLOG( @"map: %d at: %d", map, rowIndex );
				if ( [_a1AllDataSource mapAt:rowIndex] != map )
				{
					[_a1AllDataSource setMap:map at:rowIndex];
					[self updateChangeCount:NSChangeDone];
				}
			}
		}
	}
}

// accept the drop
- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id <NSDraggingInfo>)info row:(int)row dropOperation:(NSTableViewDropOperation)operation
{
	#pragma unused( row )
	
	DEBUGLOG( @"acceptDrop:%@ dropOperation:%d", info, operation );
	
	NSPasteboard *pboard;
	
	pboard = [info draggingPasteboard];
	if ( pboard == nil )
	{
		return NO;
	}

	if ( operation != NSTableViewDropOn )
	{
		return NO;
	}
	
	[self readFromPasteboard:pboard toTableView:tableView atRow:row];
	
	return YES;
}

// check if the drop is valid
- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id <NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation
{
	DEBUGLOG( @"validateDrop:%@ proposedRow:%d proposedDropOperation:%d", info, row, operation );
	
	NSPasteboard *pboard;
	
	pboard = [info draggingPasteboard];
	if ( pboard == nil )
	{
		return NSDragOperationNone;
	}
	
	if ( operation != NSTableViewDropOn )
	{
		NSInteger numberOfRows = [tableView numberOfRows];
		if ( row >= numberOfRows )
		{
			row = numberOfRows - 1;
		}
		[tableView setDropRow:row dropOperation:NSTableViewDropOn];
	}
	
	return NSDragOperationCopy;
}

// drag
//- (BOOL)tableView:(NSTableView *)tableView writeRows:(NSArray *)rows toPasteboard:(NSPasteboard *)pboard
- (BOOL)tableView:(NSTableView *)tableView writeRowsWithIndexes:(NSIndexSet *)rows toPasteboard:(NSPasteboard *)pboard
{
	DEBUGLOG( @"writeRows:%@", rows );

	if ( tableView == _patchTableView )
	{
		DEBUGLOG( @"  patch table view" );

		[self writePatchRows:rows toPasteboard:pboard];
	}
	else if ( tableView == _mapTableView )
	{
		// map table view
		DEBUGLOG( @"  map table view" );

		[self writeMapRows:rows toPasteboard:pboard];
	}
	
	return YES;
}

// printing
#if 0
- (void)printShowingPrintPanel:(BOOL)showPanels
{
	NSPrintOperation *op;
	NSPrintInfo *printInfo;
	
	printInfo = [self printInfo];
	op = [NSPrintOperation printOperationWithView:[PrintView printViewWithPrintInfo:printInfo withDocument:self]
		printInfo:printInfo];
	[op setShowPanels:showPanels];
	if ( showPanels )
	{
		// add accessory view here
	}
	
	// run operation...
	[self runModalPrintOperation:op
		delegate:nil
		didRunSelector:NULL
		contextInfo:nil];
}
#else
- (NSPrintOperation *)printOperationWithSettings:(NSDictionary<NSPrintInfoAttributeKey, id> *)printSettings
                                           error:(NSError * _Nullable *)outError {
    NSPrintInfo *printInfo = [self printInfo];
    NSPrintOperation *op = [NSPrintOperation printOperationWithView:[PrintView printViewWithPrintInfo:printInfo withDocument:self] printInfo:printInfo];
    return op;
}
#endif

@end
