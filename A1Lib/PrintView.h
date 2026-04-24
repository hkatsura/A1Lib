//
//  PrintView.h
//  A1Lib
//
//  Created by Hidetomo Katsura on 12/16/2004.
//  Copyright 2004 Hidetomo Katsura. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "A1Lib.h"

@class A1AllDataDocument, A1AllDataSource;

@interface PrintView : NSView
{
	A1AllDataDocument *mDocument;
	A1AllDataSource *mDataSource;
}

+ (PrintView *)printViewWithPrintInfo:(NSPrintInfo *)printInfo withDocument:(A1AllDataDocument *)document;

@end
