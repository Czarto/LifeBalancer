//
//  DataAdapter.m
//  LifeBalancer
//
//  Created by Pradeep Kumara on 3/25/13.
//  Copyright (c) 2013 EFutures. All rights reserved.
//

#import "DataAdapter.h"
#import "AppDelegate.h"
#import "Mission.h"
#import "Role.h"
#import "Goal.h"
#import "Task.h"
#import <EventKit/EventKit.h>

@interface DataAdapter (){
    
    BOOL permission;
}

@end
@implementation DataAdapter
- (id)init
{
    self = [super init];
    if (self) {
        AppDelegate *appdelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        managedObjectContext = appdelegate.managedObjectContext;
    }
    return self;
}

#pragma mark - Setup

- (void)initialSetup {
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Mission" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!(fetchedObjects == nil || fetchedObjects.count == 0)) {
        return;
    }
    
    
    Mission *mission = [NSEntityDescription
                        insertNewObjectForEntityForName:@"Mission"
                        inManagedObjectContext:managedObjectContext];
    
    mission.statement = @"To find happiness, fulfillment, and value in living I will strive to: make a positive difference in the lives of others; continually grow and improve; keep an open mind; and to appologize sincerely when necessary.";
    
    NSArray *rolenames = [NSArray arrayWithObjects:@"Physical",@"Mental",@"Spiritual",@"Social",@"Individual",@"Family Member",@"Friend",@"Employee", @"Homeowner", nil];
   // NSArray *rolenames = [NSArray arrayWithObjects:@"Individual",@"Family Member",@"Friend",@"Employee", @"Homeowner", nil];
   // NSArray *rolenames = [NSArray arrayWithObjects:nil];
    
    for (NSString *name in rolenames) {
        Role *role = [NSEntityDescription insertNewObjectForEntityForName:@"Role" inManagedObjectContext:managedObjectContext];
        role.name = name;
        role.custom = [NSNumber numberWithBool:NO];
    }
    
    if (![managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
}

#pragma mark - Mission

-(NSArray *)missions
{
    // Test listing all FailedBankInfos from the store
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Mission"
                                              inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error;
    return [managedObjectContext executeFetchRequest:fetchRequest error:&error];
}

#pragma mark - Roles

-(Role *)getemptyrole
{
    Role *role = [NSEntityDescription insertNewObjectForEntityForName:@"Role" inManagedObjectContext:managedObjectContext];
    role.custom = [NSNumber numberWithBool:YES];
    return role;
}

-(NSArray *)roles
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Role"
                                        inManagedObjectContext:managedObjectContext]];
    NSError *error;
    return [managedObjectContext executeFetchRequest:fetchRequest error:&error];
}





#pragma mark - set Priorities
// Tasks against roles for week plan

-(NSArray *)getTasksByPriority:(NSManagedObjectID *)roleID;
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Task"
                                        inManagedObjectContext:managedObjectContext]];
    
    NSSortDescriptor *prioritySort = [NSSortDescriptor sortDescriptorWithKey:@"priority" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc]initWithObjects:prioritySort, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"role == %@", [managedObjectContext objectWithID:roleID]];
    [fetchRequest setPredicate:predicate];
    
    

    NSError *error;
    
    return [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
}


// All available tasks for week plan

-(NSArray *)checkforTask{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Task"
                                        inManagedObjectContext:managedObjectContext]];
    
    NSSortDescriptor *prioritySort = [NSSortDescriptor sortDescriptorWithKey:@"priority" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc]initWithObjects:prioritySort, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
       
    
    NSError *error;
    
    return [managedObjectContext executeFetchRequest:fetchRequest error:&error];


}

//Reset existing weekplan

-(BOOL)resetPriorities{
    permission =YES;
    [self calendarPermission];
    
    if(permission){
        
        [self deleteCalenderEvents];
    }else{
       
    }
    return permission;
}

//Delete calender event (durring Set Priorities Reset)
-(void)deleteCalenderEvents{
    
    eventDB = [[EKEventStore alloc] init];
    NSArray *rolesarray = [self roles];
    
    
    for (Role *role in rolesarray) {
        
        NSArray *taskarray = [self getTasksByPriority:role.objectID];
        for(int x = 0; x<taskarray.count;x++){
        
            Task * task = [taskarray objectAtIndex:x];
        
            NSError *err;
            
            
            //Delete existing events from calendar
            
            EKEvent * event = [eventDB eventWithIdentifier:task.calendarId];
            
            if(event != nil){
                
                BOOL success =[eventDB removeEvent:event span:EKSpanThisEvent error:&err];
                
                if(success){
                    NSLog(@"Reset Calender Success");
                }else {
                    NSLog(@"Reset Calender Error");
                }
                
                
            }
            
        }
    }
}

-(void)reset {
   
 
        NSArray *rolesarray = [self roles];

        for (Role *role in rolesarray) {
            
            NSArray *taskarray = [self getTasksByPriority:role.objectID];
            for(int x = 0; x<taskarray.count;x++){
                
                Task * task = [taskarray objectAtIndex:x];
                                             
                      [role removeTasksObject:task];
                      [task.managedObjectContext deleteObject:task];
                
            }
            
            
        }

    
       // Save the context.
    NSError *error;
         
        if (![managedObjectContext save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
             abort();
        }
           
}


//Delete calender event (durring Set Priorities singale task delete)

-(BOOL)deleteCalenderEvent:(Task *)task{
    permission =YES;
    
    [self calendarPermission];
   
    if(permission){
       
      
        eventDB = [[EKEventStore alloc] init];
        
        NSError *err;
        
        
        //delete existing event
        EKEvent * event = [eventDB eventWithIdentifier:task.calendarId];
        
        if(event != nil){
            
            BOOL success =[eventDB removeEvent:event span:EKSpanThisEvent error:&err];
            
            if(success){
                NSLog(@"Delete Calender Success");
            }else {
                NSLog(@"Delete Calender Error");
            }
            
            
        }
        
    }
    
    return permission;
}


//Check Tasks assign wih the calender

-(NSArray *)tasksSavedInTheCalender:(NSManagedObjectID *)roleID{
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Task"
                                        inManagedObjectContext:managedObjectContext]];
    
    NSSortDescriptor *prioritySort = [NSSortDescriptor sortDescriptorWithKey:@"priority" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc]initWithObjects:prioritySort, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"role == %@ AND calendarId.length > 0", [managedObjectContext objectWithID:roleID]];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    
    return [managedObjectContext executeFetchRequest:fetchRequest error:&error];
}



//Delete calender events (durring single Roal delete) 

-(BOOL)deleteCalenderEvents:(NSManagedObjectID *)roleID{
    
    
    permission =YES;
    [self calendarPermission];
    
    if(permission){
        [self delete:roleID];
    }
    
    return permission;
}


-(void)delete:(NSManagedObjectID *)roleID{
    
    eventDB = [[EKEventStore alloc] init];
    
    NSArray *fetchedObjects = [self tasksSavedInTheCalender:roleID];
    
    for (Task *task in fetchedObjects) {
        
        
        NSError *err;
        
        //delete existing events
        EKEvent * event = [eventDB eventWithIdentifier:task.calendarId];
        
        if(event != nil){
            
            BOOL success =[eventDB removeEvent:event span:EKSpanThisEvent error:&err];
            
            if(success){
                NSLog(@"Calender Success");
            }else {
                NSLog(@"Calender Error");
            }
            
            
        }
    }
    
    
}
//Edit Calendar events during setPriority Task edit (Calendar events assign with Task )

-(BOOL)editCalenderEvent:(Task *)task withTaskName:(NSString *)taskName{

    permission =YES;

    [self calendarPermission];

    if(permission){
        eventDB = [[EKEventStore alloc] init];
        
        NSError *err;
 
        EKEvent * event = [eventDB eventWithIdentifier:task.calendarId];
        
        if(event != nil){
             // event update the Calender and task with the new title.
            event.title = taskName;
            BOOL success =[eventDB saveEvent:event span:EKSpanThisEvent error:&err];
            
            if(success){
                task.calendarId = event.eventIdentifier;
                task.name = taskName;
            }
            
        }        
        
        NSError *error;
        if (![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    return permission;
}

//Events directly deleted from iPhone default Calendar app

-(void)syncWithCalender:(Task *)task withTaskName:(NSString *)taskName{
    
        eventDB = [[EKEventStore alloc] init];
        EKEvent * event = [eventDB eventWithIdentifier:task.calendarId];
    
    //If there is no any macthing calendar event update the task with the new title.
        if(event == nil){
            
            task.calendarId = @"";
            task.name = taskName;
                                 
        }
        
        NSError *error;
        if (![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
}



#pragma mark - Calendar Permission

//Check calender Permission

-(void)calendarPermission{
    
    eventDB = [[EKEventStore alloc] init];
    
    if ([eventDB respondsToSelector:@selector(requestAccessToEntityType:completion:)]) {
        
        // iOS 6 and later
        [eventDB requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted,NSError *error){
            
            
            if(granted){
                permission=YES;
                                
            }else{
                permission=NO;
                
                [self performSelectorOnMainThread:@selector(showAlert:) withObject:@"You have to provide permission to access calender" waitUntilDone:YES];
                
            }
        }];
    }else{
        permission = YES;
       
        //iOS < 6
        
    }
    
   
}




#pragma mark - Alert

-(void)showAlert:(NSString *)message{

    [[[UIAlertView alloc] initWithTitle:@"Calendar" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
    
}


@end
