//
//  Common.h
//  LifeBalancer
//
//  Created by Eugene Zozulya on 3/30/15.
//  Copyright (c) 2015 Czarto. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Common : NSObject

+ (void)lastSessionWithLocalStorage:(BOOL)flag;
+ (BOOL)isLastSessionWithLocalStorage;
+ (BOOL)isNewVersion:(NSString*)versionKey;

@end
