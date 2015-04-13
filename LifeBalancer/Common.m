//
//  Common.m
//  LifeBalancer
//
//  Created by Eugene Zozulya on 3/30/15.
//  Copyright (c) 2015 Czarto. All rights reserved.
//

#import "Common.h"

#define STORAGE_FLAG_KEY				@"LastSessionWithLocalStorage"

@implementation Common

+ (void)lastSessionWithLocalStorage:(BOOL)flag {
	NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
	[def setBool:flag forKey:STORAGE_FLAG_KEY];
	[def synchronize];
}

+ (BOOL)isLastSessionWithLocalStorage {
	NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
	return [def boolForKey:STORAGE_FLAG_KEY];
}

+ (BOOL)isNewVersion:(NSString*)versionKey {
	NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
	BOOL retFlag = [def boolForKey:versionKey];
	if(!retFlag) {
		[def setBool:YES forKey:versionKey];
		[def synchronize];
	}
	
	return retFlag;
}

@end
