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
#import "Faulter.h"
#import "CoreDataImporter.h"
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

}

- (NSDictionary*)selectedUniqueAttributes {

    
	
//    if (debug==1) {NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));}
    
    NSMutableArray *entities   = [NSMutableArray new];
    NSMutableArray *attributes = [NSMutableArray new];
    
    // Select an attribute in each entity for uniqueness
    [entities addObject:@"Goal"];[attributes addObject:@"name"];
    [entities addObject:@"Mission"];[attributes addObject:@"statement"];
    [entities addObject:@"Role"];[attributes addObject:@"name"];
    [entities addObject:@"Task"];[attributes addObject:@"calendarId"];
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:attributes
                                                           forKeys:entities];
    return dictionary;
}


- (void)initialSetup2 {
	
	NSError *error = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Mission" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!(fetchedObjects == nil || fetchedObjects.count == 0)) {
        return;
    }

	
	CoreDataImporter *importer = [[CoreDataImporter alloc] initWithUniqueAttributes:[self selectedUniqueAttributes]];
	
	
	NSDictionary *attributeDict = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObject:@"To find happiness, fulfillment and value in living I will strive to make a positive difference in the lives of others; spend more quality time with friends and family; strive for excellence and inspire others; and apologize sincerely when necessary."] forKeys:[NSArray arrayWithObject:@"statement"]];
	// STEP 3a: Insert a unique 'Item' from XML with a single attribute
	NSManagedObject *missionItem = [importer insertBasicObjectInTargetEntity:@"Mission"
													   targetEntityAttribute:@"statement"
														  sourceXMLAttribute:@"statement"
															   attributeDict:attributeDict
																	 context:managedObjectContext];
	
	NSDictionary *role1 = [NSDictionary dictionaryWithObjectsAndKeys:
						   @"Physical",@"name",
						   [NSNumber numberWithBool:NO],@"custom",
						   nil];

	
	NSManagedObject *roleItem1 = [importer insertFieldObjectInTarget:@"Role" attributeDict:role1 contect:managedObjectContext];
	
	
	NSDictionary *role2 = [NSDictionary dictionaryWithObjectsAndKeys:
						   @"Mental",@"name",
						   [NSNumber numberWithBool:NO],@"custom",
						   nil];

	NSManagedObject *roleItem2 = [importer insertFieldObjectInTarget:@"Role" attributeDict:role2 contect:managedObjectContext];

	NSDictionary *role3 = [NSDictionary dictionaryWithObjectsAndKeys:
						   @"Spiritual",@"name",
						   [NSNumber numberWithBool:NO],@"custom",
						   nil];

	
	NSManagedObject *roleItem3 = [importer insertFieldObjectInTarget:@"Role" attributeDict:role3 contect:managedObjectContext];

	NSDictionary *role4 = [NSDictionary dictionaryWithObjectsAndKeys:
						   @"Social",@"name",
						   [NSNumber numberWithBool:NO],@"custom",
						   nil];

	
	NSManagedObject *roleItem4 = [importer insertFieldObjectInTarget:@"Role" attributeDict:role4 contect:managedObjectContext];

	NSMutableDictionary *role5 = [NSMutableDictionary dictionaryWithObject:@"Individual" forKey:@"name"];
	[role5 setObject:[NSNumber numberWithBool:YES] forKey:@"custom"];
	
	
	NSManagedObject *roleItem5 = [importer insertFieldObjectInTarget:@"Role" attributeDict:role5 contect:managedObjectContext];

	NSMutableDictionary *role6 = [NSMutableDictionary dictionaryWithObject:@"Family" forKey:@"name"];
	[role6 setObject:[NSNumber numberWithBool:YES] forKey:@"custom"];
	
	NSManagedObject *roleItem6 = [importer insertFieldObjectInTarget:@"Role" attributeDict:role6 contect:managedObjectContext];

	NSMutableDictionary *role7 = [NSMutableDictionary dictionaryWithObject:@"Friend" forKey:@"name"];
	[role7 setObject:[NSNumber numberWithBool:YES] forKey:@"custom"];
	
	NSManagedObject *roleItem7 = [importer insertFieldObjectInTarget:@"Role" attributeDict:role7 contect:managedObjectContext];

	NSMutableDictionary *role8 = [NSMutableDictionary dictionaryWithObject:@"Employee" forKey:@"name"];
	[role8 setObject:[NSNumber numberWithBool:YES] forKey:@"custom"];

	
	NSManagedObject *roleItem8 = [importer insertFieldObjectInTarget:@"Role" attributeDict:role8 contect:managedObjectContext];

	NSMutableDictionary *role9 = [NSMutableDictionary dictionaryWithObject:@"Homeowner" forKey:@"name"];
	[role9 setObject:[NSNumber numberWithBool:YES] forKey:@"custom"];

	NSManagedObject *roleItem9 = [importer insertFieldObjectInTarget:@"Role" attributeDict:role9 contect:managedObjectContext];

	
	// STEP 6: Save new objects to the persistent store.
	[CoreDataImporter saveContext:managedObjectContext];
	
	[Faulter faultObjectWithID:missionItem.objectID inContext:managedObjectContext];
	[Faulter faultObjectWithID:roleItem1.objectID inContext:managedObjectContext];
	[Faulter faultObjectWithID:roleItem2.objectID inContext:managedObjectContext];
	[Faulter faultObjectWithID:roleItem3.objectID inContext:managedObjectContext];
	[Faulter faultObjectWithID:roleItem4.objectID inContext:managedObjectContext];
	[Faulter faultObjectWithID:roleItem5.objectID inContext:managedObjectContext];
	[Faulter faultObjectWithID:roleItem6.objectID inContext:managedObjectContext];
	[Faulter faultObjectWithID:roleItem7.objectID inContext:managedObjectContext];
	[Faulter faultObjectWithID:roleItem8.objectID inContext:managedObjectContext];
	[Faulter faultObjectWithID:roleItem9.objectID inContext:managedObjectContext];
	
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
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"custom" ascending:YES];
	NSSortDescriptor *orderIDSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sortID" ascending:YES];
	[fetchRequest setSortDescriptors:[[NSArray alloc] initWithObjects:sortDescriptor, orderIDSortDescriptor, nil]];

	NSError *error;
	NSArray *roles = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
	[self checkRolesSorting:roles];
	if (error)
		NSLog(@"Error %@", error);
    return roles;
}
-(NSArray*)customRoles
{

	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:[NSEntityDescription entityForName:@"Role"
										inManagedObjectContext:managedObjectContext]];
	NSSortDescriptor *customSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"custom" ascending:YES];
	NSSortDescriptor *orderIDSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sortID" ascending:YES];
	[fetchRequest setSortDescriptors:[[NSArray alloc] initWithObjects:customSortDescriptor,orderIDSortDescriptor, nil]];
	
	NSError *error;
	NSArray *roles = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
	[self checkRolesSorting:roles];
	if (error)
		NSLog(@"Error %@", error);
	return roles;
}

-(void)checkRolesSorting:(NSArray*)roles {
	BOOL changes = NO;
	for(int i = 0; i < roles.count; i++) {
		Role *role = roles[i];
		if(role.sortID == nil) {
			role.sortID = @(i);
			changes = YES;
		}
	}
	if(changes) {
		NSError *error;
		[managedObjectContext save:&error];
		if(error)
			NSLog(@"Error %@", error);
	}
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
