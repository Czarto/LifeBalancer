//
//  ScheduleTaskViewController.m
//  LifeBalancer
//
//  Created by IgnitionIT Solutions on 4/4/13.
//  Copyright (c) 2013 EFutures. All rights reserved.
//

#import "ScheduleTaskViewController.h"
#import "Task.h"
#import "Role.h"
#import "SetReminderViewController.h"
#import "DataAdapter.h"
#import <EventKitUI/EventKitUI.h>
@interface ScheduleTaskViewController ()

@end

@implementation ScheduleTaskViewController
@synthesize task,role;
@synthesize doneButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

}
- (void)viewWillAppear:(BOOL)animated
{


    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:NO];
    self.navigationItem.hidesBackButton=NO;
    self.navigationItem.title =task.name;
    //create bar buttons
    [self.navigationController setToolbarHidden:YES];
//    UIBarButtonItem *backButton = [[ UIBarButtonItem alloc ] initWithTitle: @"Back"
//                                                                     style: UIBarButtonItemStyleBordered
//                                                                    target: self
//                                                                    action: @selector(back)];
	
   // self.toolbarItems = [ NSArray arrayWithObjects: backButton, nil];
    
   
    if([[task isDone] intValue]== 1){
        
        //[doneButton setEnabled:false]; mark as not done
         [doneButton setTitle:@"Mark As Not Done" forState:UIControlStateNormal];
        
     }else{
        //[doneButton setEnabled:true];mark as done
          [doneButton setTitle:@"Mark As Done" forState:UIControlStateNormal];
     }
    
}

//-(void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//    if([[task isDone] intValue]== 1){
//        
//        //[doneButton setEnabled:false]; mark as not done
//        [doneButton setTitle:@"Mark as not done" forState:UIControlStateNormal];
//    }else{
//        //[doneButton setEnabled:true];mark as done
//        [doneButton setTitle:@"Mark as done" forState:UIControlStateNormal];
//    }
//    
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark Bottum Bar Buttons

-(void)back{
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Action Buttons

- (IBAction)markAsDone:(id)sender {
 
    if([[task isDone] intValue]== 1)
    {
      task.isDone = [NSNumber numberWithBool:NO];
    }
    else{
        task.isDone = [NSNumber numberWithBool:YES];
    }
    //task.isDone = !task.isDone;
       NSError *error;
         
          if (![role.managedObjectContext save:&error]) {
        
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
          }
     
    
    //[doneButton setEnabled:false];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)sendToCalender:(id)sender {
    

    if(task.calendarId == nil ||[task.calendarId isEqualToString:@""]) {
        [self calendarPermission:@"Add"];//add new 
        
    }else{
        
        [self calendarPermission:@"Update"];//update
        
    }

}

- (IBAction)sendToReminder:(id)sender {
  /*  SetReminderViewController *setReminderViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ReminderViewController"];
    
    setReminderViewController.goal = goal;
    [self.navigationController pushViewController:setReminderViewController animated:YES];*/
    
      
}


#pragma mark -
#pragma mark Calendar Methods

-(void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action{
    
    EKEvent *myEvent =controller.event;
    
    switch (action) {
        case EKEventEditViewActionSaved:
            [self updateLocalDatabase :myEvent];//update local database
            break;
        case EKEventEditViewActionCanceled:
            break;
        case EKEventEditViewActionDeleted:
            [self deleteFromLocalDatabase];//delete from local data base
            break;
    }
    
    if (![self.presentedViewController isBeingDismissed])
    [controller dismissViewControllerAnimated:YES completion:NULL];
    
 
    
}


-(void)updateLocalDatabase:(EKEvent *)myEvent{
    
    
    task.calendarId = myEvent.eventIdentifier;
    
    NSError *error;
    if (![role.managedObjectContext save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    }

-(void)deleteFromLocalDatabase{
    
    
    task.calendarId = @"";
    
    NSError *error;
    if (![role.managedObjectContext save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

}



-(void)calendarPermission:(NSString *)mode{
    
    EKEventStore *eventDB = [[EKEventStore alloc] init];
    
    //Calender Permission
    
    if ([eventDB respondsToSelector:@selector(requestAccessToEntityType:completion:)]) {
        
        // iOS 6 and later
        [eventDB requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted,NSError *error){
            
            
            
            if(granted){
                
                [self performSelectorOnMainThread:
                 @selector(editCalendar:)
                                       withObject:mode
                                    waitUntilDone:NO];
                
                
            }else{
                [self performSelectorOnMainThread:@selector(showAlert:) withObject:@"You have to provide permission to access calender" waitUntilDone:YES];
                
                
            }
        }];
    }else{
        //iOS < 6
        
        [self editCalendar:mode];
    }
    
}



-(void)editCalendar:(NSString *) mode{
    
    
    
    EKEventStore *eventDB = [[EKEventStore alloc] init];
    
    if([mode isEqualToString:@"Update"]){
        
        //update existing events
        
        eventDB = [[EKEventStore alloc] init];
        EKEvent * event = [eventDB eventWithIdentifier:task.calendarId];
        
        if(event != nil){
            
            
            EKEventEditViewController * controller =[[EKEventEditViewController alloc] init];
            controller.eventStore = eventDB;
            controller.event = event;
            controller.editViewDelegate = self;
            [self presentViewController:controller animated:YES completion:NULL];
            
            
            
        }else{
            //Events directly deleted from iPhone default Calendar app
            event  = [EKEvent eventWithEventStore:eventDB];
            event.title=task.name;
            event.startDate = [[NSDate alloc] init];
            event.endDate = [[NSDate alloc] initWithTimeInterval:1800 sinceDate: event.startDate];
            EKEventEditViewController * controller =[[EKEventEditViewController alloc] init];
            controller.eventStore = eventDB;
            controller.event = event;
            controller.editViewDelegate = self;
            
            
            [self presentViewController:controller animated:YES completion:NULL];
            
        }
    }else if([mode isEqualToString:@"Add"]){
        // Add new Events
        
        
        EKEvent *myEvent  = [EKEvent eventWithEventStore:eventDB];
        myEvent.title=task.name;
        myEvent.startDate = [[NSDate alloc] init];
        myEvent.endDate = [[NSDate alloc] initWithTimeInterval:1800 sinceDate: myEvent.startDate];
        EKEventEditViewController * controller =[[EKEventEditViewController alloc] init];
        controller.eventStore = eventDB;
        controller.event = myEvent;
        controller.editViewDelegate = self;
        
        
        [self presentViewController:controller animated:YES completion:NULL];
    }
    
    
    
}

#pragma mark - Alert

-(void)showAlert:(NSString *)message{
    
    [[[UIAlertView alloc] initWithTitle:@"Calendar" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
    
}


@end
