//
//  Role.h
//  LifeBalancer
//
//  Created by IgnitionIT Solutions on 4/13/13.
//  Copyright (c) 2013 EFutures. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Goal;

@interface Role : NSManagedObject

@property (nonatomic, retain) NSNumber * custom;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * sortID;
@property (nonatomic, retain) NSSet *goals;
@property (nonatomic, retain) NSSet *tasks;

@end

@interface Role (CoreDataGeneratedAccessors)

- (void)addGoalsObject:(Goal *)value;
- (void)removeGoalsObject:(Goal *)value;
- (void)addGoals:(NSSet *)values;
- (void)removeGoals:(NSSet *)values;

- (void)addTasksObject:(NSManagedObject *)value;
- (void)removeTasksObject:(NSManagedObject *)value;
- (void)addTasks:(NSSet *)values;
- (void)removeTasks:(NSSet *)values;

@end
