//
//  main.m
//  CS193P.4.SPoT
//
//  Created by Felix Vigl on 20.02.13.
//  Copyright (c) 2013 Felix Vigl. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SPoTAppDelegate.h"

int main(int argc, char *argv[])
{
	int retVal = -1;
	
	@autoreleasepool {
		@try { retVal = UIApplicationMain(argc, argv, nil, NSStringFromClass([SPoTAppDelegate class])); }
		@catch (NSException *exception) {
			NSLog(@"Uncaught exception: %@", exception.description);
			NSLog(@"Stack trace: %@", [exception callStackSymbols]);
		}
	}
	return retVal;
}
