//
//  DataAdapter.h
//  LifeBalancer
//
//  Created by Pradeep Kumara on 3/25/13.
//  Copyright (c) 2013 EFutures. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>
@class Role;
@class Goal;
@class Task;
@interface DataAdapter : NSObject {
    NSManagedObjectContext* managedObjectContext;
    EKEventStore *eventDB;
}
-(void)initialSetup;
-(void)initialSetup2;
-(NSArray *)missions;
-(Role *)getemptyrole;
-(NSArray *)roles;
-(NSArray*)customRoles;
-(BOOL)resetPriorities;
-(BOOL)deleteCalenderEvent:(Task *)task;
-(BOOL)editCalenderEvent:(Task *)task withTaskName:(NSString *)taskName;
-(void)syncWithCalender:(Task *)task withTaskName:(NSString *)taskName;
-(BOOL)deleteCalenderEvents:(NSManagedObjectID *)roleID;
-(NSArray *)tasksSavedInTheCalender:(NSManagedObjectID *)roleID;
-(NSArray *)getTasksByPriority:(NSManagedObjectID *)roleID;
-(NSArray *)checkforTask;
-(void)reset;
@end
