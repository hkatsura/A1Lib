//
//  TableView.m
//  A3Lib
//
//  Created by Hidetomo Katsura on 12/8/2004.
//  Copyright 2004 Hidetomo Katsura. All rights reserved.
//

#import "TableView.h"

@implementation TableView

#if 0
- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)isLocal
{
	#pragma unused( isLocal )
	
	return NSDragOperationCopy;
}
#else
- (NSDragOperation)draggingSession:(NSDraggingSession *)session
sourceOperationMaskForDraggingContext:(NSDraggingContext)context {
    switch(context) {
        case NSDraggingContextOutsideApplication: {
            //return NSDragOperationNone;
            return NSDragOperationCopy;
        }
        case NSDraggingContextWithinApplication:
        default: {
            return NSDragOperationCopy;
        }
    }
}
#endif

@end
