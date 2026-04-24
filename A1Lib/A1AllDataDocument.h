//
//  A1AllDataDocument.h
//  A1Lib
//
//  Created by Hidetomo Katsura on 11/30/2004.
//  Copyright Hidetomo Katsura 2004 . All rights reserved.
//


#import <Cocoa/Cocoa.h>

#import "A1Lib.h"

@class A1AllDataSource;

@interface A1AllDataDocument : NSDocument

- (IBAction)checkboxChanged:(id)sender;
- (IBAction)popUpButtonChanged:(id)sender;
- (IBAction)midiChChanged:(id)sender;

- (A1AllDataSource *)dataSource;

@end
