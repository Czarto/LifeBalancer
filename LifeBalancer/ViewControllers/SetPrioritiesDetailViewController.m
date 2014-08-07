//
//  SetPrioritiesDetailViewController.m
//  LifeBalancer
//
//  Created by IgnitionIT Solutions on 4/13/13.
//  Copyright (c) 2013 EFutures. All rights reserved.
//

#import "SetPrioritiesDetailViewController.h"
#import "Role.h"
#import "Task.h"
#import "DataAdapter.h"
@interface SetPrioritiesDetailViewController ()

@end

@implementation SetPrioritiesDetailViewController
@synthesize role,task;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Task Details";
    
    if (task) {
        self.taskName.text = task.name;
    }
  
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)saveClicked:(id)sender {
    
    if (self.taskName.text.length==0) {
        [[[UIAlertView alloc]initWithTitle:nil message:@"Task name shouldn't be empty" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    
    BOOL exist = NO;
    
    for (Task *taskobj in role.tasks) {
        if ([taskobj.name isEqualToString:self.taskName.text]) {
            exist = YES;
            break;
        }
    }
    
    if (!exist) {
        
        if (!role) {
            return;
        }
        
        NSManagedObjectContext *context = role.managedObjectContext;
        
        if (!task) {
              
            self.task = [NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:context];
            self.task.priority = [NSNumber numberWithInteger:[self.role.tasks count]];
            [role addTasksObject:task];
            
            task.name = self.taskName.text;
            NSError *error = nil;
            if (![context save:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
            
        }else{
            
             if(task.calendarId != nil &&![task.calendarId isEqualToString:@""]) {
               BOOL permission = YES;
               permission =   [[[DataAdapter alloc]init]editCalenderEvent:task withTaskName:self.taskName.text];
               
                 if(permission){
                    //Events directly deleted from iPhone default Calendar app
                     [[[DataAdapter alloc]init]syncWithCalender:task withTaskName:self.taskName.text];
                 }
              
             
             }else{
                  task.name = self.taskName.text;
                  NSError *error = nil;
                  if (![context save:&error]) {
                      NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                      abort();
                  }
        
             }
        
         }

        
        
  }else{
        
        //[[[UIAlertView alloc]initWithTitle:nil message:@"Task already exists" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
	
    [self.navigationController popViewControllerAnimated:YES];
    
}
@end
