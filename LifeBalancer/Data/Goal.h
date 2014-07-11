//
//  Goal.h
//  LifeBalancer
//
//  Created by Rukshan Marapana on 8/6/13.
//  Copyright (c) 2013 EFutures. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Role;

@interface Goal : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * priority;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) Role *role;

@end
