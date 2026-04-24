/*
 *  A1Lib.h
 *  A1Lib
 *
 *  Created by Hidetomo Katsura on 12/1/2004.
 *  Copyright (c) 2004 Hidetomo Katsura. All rights reserved.
 *
 */

#define SHOW_DEBUGLOG   0

#if SHOW_DEBUGLOG
	#define DEBUGLOG	NSLog
#else
	#define DEBUGLOG(...)
#endif

#define	kProductName					"A1Lib"

#define kPaidNotificationName			@"com.katsurashareware.key.PaidNotification"

#define kFirstLaunchDateKey				@"com.katsurashareware.key.FirstLaunchDate"
