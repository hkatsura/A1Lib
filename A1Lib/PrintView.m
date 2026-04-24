//
//  PrintView.m
//  A1Lib
//
//  Created by Hidetomo Katsura on 12/16/2004.
//  Copyright 2004 Hidetomo Katsura. All rights reserved.
//

#import "PrintView.h"
#import "A1AllDataDocument.h"
#import "A1AllDataSource.h"

@implementation PrintView

- (void)setDocument:(A1AllDataDocument *)document
{
	mDocument = document;
	mDataSource = [document dataSource];
}

+ (NSRect)frameWithPrintInfo:(NSPrintInfo *)printInfo
{
	NSRect frame;
	float top, left, bottom, right;
	
	top = [printInfo topMargin];
	left = [printInfo leftMargin];
	bottom = [printInfo bottomMargin];
	right = [printInfo rightMargin];
	
	frame.origin = NSMakePoint( left, bottom );
	frame.size = [printInfo paperSize];
	frame.size.width -= ( left + right );
	frame.size.height -= ( top + bottom );
	
	return frame;
}

+ (PrintView *)printViewWithPrintInfo:(NSPrintInfo *)printInfo withDocument:(A1AllDataDocument *)document
{
	PrintView *printView;
	
    printView = [[PrintView alloc] initWithFrame:[PrintView frameWithPrintInfo:printInfo]];
	[printView setDocument:document];
	
	return printView;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if ( self != nil )
	{
        // Initialization code here.
    }
	
    return self;
}

- (BOOL)isFlipped
{
	// make the top/left (0,0)
	return YES;
}

- (NSString *)stringAtIndex:(int)idx
{
	return [NSString stringWithFormat:@"%02d : %@", idx, [mDataSource patchNameAt:idx]];
}

- (void)drawRect:(NSRect)rect
{
	#pragma unused( rect )
	
	NSRect bounds;
	NSString *string;
	NSDictionary *attributes;
	NSPoint point;
	float halfWidth, fontSize, delta;
	int idx;
	
	bounds = [self bounds];
	
	//NSFrameRect( bounds );
	
	attributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Helvetica" size:12.0], NSFontAttributeName, nil];
	string = [NSString stringWithFormat:@"Korg A1 SysEx File: %@", [mDocument displayName]];
	[string drawAtPoint:NSMakePoint( 5, 5 ) withAttributes:attributes];
	
	string = [NSString stringWithFormat:@"MIDI Channel: %ld", (long)( [mDataSource midiCh] + 1 )];
	[string drawAtPoint:NSMakePoint( 5, 20 ) withAttributes:attributes];
	
	fontSize = ( bounds.size.height / 50 ) - 3;
	if ( fontSize < 0 )
	{
		fontSize = 1;
	}
	halfWidth = bounds.size.width / 2;
	attributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Courier" size:fontSize], NSFontAttributeName, nil];
	string = @" # : Name";
	[string drawAtPoint:NSMakePoint( 15, 35 ) withAttributes:attributes];
	[string drawAtPoint:NSMakePoint( 15 + halfWidth, 35 ) withAttributes:attributes];
	
	delta = ( bounds.size.height - 35 - 5 ) / 51;
	point.x = 15;
	point.y = 35 + delta;
	for ( idx = 0; idx < 50; ++idx )
	{
		string = [self stringAtIndex:idx];
		[string drawAtPoint:point withAttributes:attributes];
		
		string = [self stringAtIndex:( idx + 50 )];
		[string drawAtPoint:NSMakePoint( point.x + halfWidth, point.y ) withAttributes:attributes];
		
		point.y += delta;
	}
}

@end
