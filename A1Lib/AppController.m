//
//  AppController.m
//  A1Lib
//
//  Created by Hidetomo Katsura on 9/9/2004.
//  Copyright 2004 Hidetomo Katsura. All rights reserved.
//

#import "AppController.h"

#import "A1AllDataDocument.h"

@implementation AppController

#pragma mark -- AppController --

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	#pragma unused( aNotification )
	
	DEBUGLOG( @"applicationDidFinishLaunching" );
}

- (IBAction)openWebSite:(id)sender
{
 	#pragma unused( sender )
	
   [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:NSLocalizedString( @"kWebSiteURL", nil )]];
}

@end
