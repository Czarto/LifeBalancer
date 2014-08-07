//
//  SetPrioritiesViewController.m
//  LifeBalancer
//
//  Created by IgnitionIT Solutions on 4/13/13.
//  Copyright (c) 2013 EFutures. All rights reserved.
//

#import "SetPrioritiesViewController.h"
#import "SchedulePrioritiesViewController.h"
#import "DataAdapter.h"
#import "Role.h"
#import "Task.h"
#import "Config.h"
#import "SetPrioritiesDetailViewController.h"
#import "GoalViewController.h"

@interface SetPrioritiesViewController ()<UITabBarDelegate>
{
    NSArray *rolesarray;

}
@end

@implementation SetPrioritiesViewController

//- (id)initWithStyle:(UITableViewStyle)style
//{
//    self = [super initWithStyle:style];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [super viewDidLoad];
    self.tabBar.delegate = self;
    [self.tabBar setSelectedItem:self.tabBarItem1];
    self.navigationItem.hidesBackButton=YES;
 
    [self.navigationController setToolbarHidden:YES];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.title = @"Set Priorities";
    
    //Create bar buttons
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle: @"Home"
                                                                   style: UIBarButtonItemStyleBordered
                                                                  target: self
                                                                  action: @selector(back)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                   target:self
                                                                                   action:nil];
    
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc]initWithTitle:@"Schedule"
                                                                  style:UIBarButtonItemStyleBordered
                                                                 target:self
                                                                 action:@selector(goNext)];
    
    // self.toolbarItems = [ NSArray arrayWithObjects: backButton,flexibleSpace,nextButton,nil];
    self.navigationItem.leftBarButtonItem = backButton;
    [self loadroles];
    if (!self.editing) {
        
        if (self.shouldBePresentedInEditMode)
        {
            
            [self.tableView setEditing:YES animated:YES];
            [self setEditing:YES];
            
        }
    }
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tabBar setSelectedItem:self.tabBarItem1];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.tabBar setSelectedItem:nil];
}
- (void)loadroles
{
    
    rolesarray = [[[DataAdapter alloc]init]roles];
    
    [self.tableView reloadData];
    
    
    if([self checkforSelectedGoals]){
        
        [[self.toolbarItems objectAtIndex: 2] setEnabled:(YES)];
        
    }else{
        
        [[self.toolbarItems objectAtIndex: 2] setEnabled:(NO)];
        
    }

}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark -
#pragma mark Editing

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    
    [super setEditing:editing animated:animated];

    [self.tableView setEditing:editing animated:animated];
    
    [self.tableView beginUpdates];
    
    for (int rolecount=0; rolecount < rolesarray.count; rolecount++) {
        Role *role = rolesarray[rolecount];
        if (role.tasks.count < ADD_TASK_MAX_LIMIT) {
            NSArray *rolesInsertIndexPath = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:[role.tasks count] inSection:rolecount]];
            
            if (editing) {
                [self.tableView insertRowsAtIndexPaths:rolesInsertIndexPath withRowAnimation:UITableViewRowAnimationTop];
                
            } else {
                [self.tableView deleteRowsAtIndexPaths:rolesInsertIndexPath withRowAnimation:UITableViewRowAnimationTop];
                
            }
        }
    }
    [self.tableView endUpdates];
}




#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return rolesarray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    Role *role = rolesarray[section];
    
    rows = [role.tasks count];
    if (self.editing && rows < ADD_TASK_MAX_LIMIT) {
        rows++;
    }
    

    
    return rows;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    Role *role = rolesarray[section];
    return role.name;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rows = 0;
    
   
    
    UITableViewCell *rolecell = [tableView dequeueReusableCellWithIdentifier:@"SetPriorityCell"];
    Role *role = rolesarray[indexPath.section];
    
    rows = [role.tasks count];
    if (rows>=4) {
        self.isPink = YES;
    }
    else{
        self.isPink = NO;
    }
    
    DataAdapter *da = [[DataAdapter alloc]init];
    
    
    if (indexPath.row < role.tasks.count) {
        
        NSMutableArray *tasksarray = [NSMutableArray arrayWithArray:[da getTasksByPriority:role.objectID]];
        
        Task *task = [tasksarray objectAtIndex:indexPath.row];
        rolecell.textLabel.text = task.name;
        
        
        
    } else {
        rolecell.textLabel.text = @"Add Task";
    }
    
    if (self.isPink) {
        rolecell.textLabel.textColor = [UIColor purpleColor];
    }
    else
    {
        rolecell.textLabel.textColor = [UIColor blackColor];
    }
    return rolecell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSIndexPath *rowToSelect = indexPath;
    BOOL isEditing = self.editing;
    
    if (!isEditing) {
        rowToSelect = nil;
    }
    
	return rowToSelect;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SetPrioritiesDetailViewController *nextViewController = nil;
    
    nextViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SetPrioritiesDetail"];
    
    Role *role = rolesarray[indexPath.section];
    nextViewController.role = role;
    
    DataAdapter *da = [[DataAdapter alloc]init];
        if (indexPath.row < role.tasks.count) {
            
            NSMutableArray *tasksarray = [NSMutableArray arrayWithArray:[da getTasksByPriority:role.objectID]];
            

        nextViewController.task = tasksarray[indexPath.row];
    }
    
    if (nextViewController) {
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
    
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCellEditingStyle style = UITableViewCellEditingStyleNone;
    
    Role *role = rolesarray[indexPath.section];
    
    
    if (indexPath.row < role.tasks.count) {
        // Detemine if it's in editing mode
        if (self.editing){
        style = UITableViewCellEditingStyleDelete;
        }
    } else {
        style = UITableViewCellEditingStyleInsert;
    }
    
    
    
      
  
    return style;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
       
        
        [[[UIAlertView alloc]initWithTitle:@"Confirmation"
                                   message:@"Do you want to delete ?"
                           completionBlock:^(NSUInteger buttonIndex, UIAlertView *alertView) {
                               if (buttonIndex == 1) {
                                   BOOL permission = YES;
                                   Role *role = rolesarray[indexPath.section];
                                   DataAdapter *da = [[DataAdapter alloc]init];
                                   
                                   if (indexPath.row < role.tasks.count) {
                                       NSMutableArray *tasksarray = [NSMutableArray arrayWithArray:[da getTasksByPriority:role.objectID]];
                                                                                                    
                                       Task * selectedTask = [tasksarray objectAtIndex:indexPath.row];
                                       
                                       if(selectedTask.calendarId != nil &&![selectedTask.calendarId isEqualToString:@""]) {
                                           
                                           permission = [[[DataAdapter alloc]init]deleteCalenderEvent:selectedTask];
                                       }
                                       
                                        if(permission){
                                            
                                        
                                           [role removeTasksObject:selectedTask];
                                           [selectedTask.managedObjectContext deleteObject:selectedTask];
                                           
                                           [tasksarray removeObjectAtIndex:indexPath.row];
                                           
                                           for (int order=0; order<tasksarray.count; order++) {
                                               Task *task = [tasksarray objectAtIndex:order];
                                               task.priority = [NSNumber numberWithInt:order];
                                           }
                                           
                                           // Save the context.
                                           NSError *error;
                                           if (![role.managedObjectContext save:&error]) {
                                               
                                               NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                                               abort();
                                           }
                                        }
                                       [self loadroles];
                                   }
                               }
                           }
                         cancelButtonTitle:@"NO"
                         otherButtonTitles:@"YES",nil] show];
        

        
                
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        [self tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}



#pragma mark -
#pragma mark Moving rows

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL canMove = NO;
    Role *role = rolesarray[indexPath.section];
    canMove = indexPath.row != [role.tasks count];
    return canMove;
}


- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    NSIndexPath *target = proposedDestinationIndexPath;
    NSIndexPath *source = sourceIndexPath;
    
    Role *role = rolesarray[source.section];
    
    if (target.section < source.section) {
        target = [NSIndexPath indexPathForRow:0 inSection:source.section];
    } else if (target.section > source.section) {
        target = [NSIndexPath indexPathForRow:([role.tasks count] - 1) inSection:source.section];
    } else {
        NSUInteger ingredientsCount_1 = [role.tasks count] - 1;
        
        if (target.row > ingredientsCount_1) {
            target = [NSIndexPath indexPathForRow:ingredientsCount_1 inSection:source.section];
        }
    }
	
    return target;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	
    if (fromIndexPath.section == toIndexPath.section) {
        Role *role = [rolesarray objectAtIndex:fromIndexPath.section];
        DataAdapter *da = [[DataAdapter alloc]init];
        NSMutableArray *tasksarray = [NSMutableArray arrayWithArray:[da getTasksByPriority:role.objectID]];
        
        Task *selectedTask = [tasksarray objectAtIndex:fromIndexPath.row];
        
        [tasksarray removeObjectAtIndex:fromIndexPath.row];
        [tasksarray insertObject:selectedTask atIndex:toIndexPath.row];
        
        for (int order=0; order<tasksarray.count; order++) {
            Task *task = [tasksarray objectAtIndex:order];
            task.priority = [NSNumber numberWithInt:order];
        }
        
        // Save the context.
        NSError *error;
        if (![role.managedObjectContext save:&error]) {
            
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

-(BOOL)checkforSelectedGoals{
    DataAdapter *da = [[DataAdapter alloc]init];
    NSMutableArray *availablearray = [NSMutableArray arrayWithArray:[da checkforTask]];
    if(availablearray.count >0){
        return YES;
    }else{
        return NO;
    }
}


#pragma mark -
#pragma mark Buttom Bar Buttons

-(void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)goNext{
    
    SchedulePrioritiesViewController *schedulePrioritiesViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SchedulePriorities"];
    
    [self.navigationController pushViewController:schedulePrioritiesViewController animated:NO];
    
    
}
#pragma mark UITabBarController

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    NSLog(@"selected item tag : %d",item.tag);
    if (item.tag==1) {
        [self back];
    }
    else  if (item.tag==3) {
        [self goNext];
    }
    else if(item.tag==4)
    {
        GoalViewController *gVc = [self.storyboard instantiateViewControllerWithIdentifier:@"tempGoalVC"];
        //CGRect rect = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-49);
       // gVc.view.frame = rect;
        //[self.view addSubview:gVc.view];
        [self.navigationController pushViewController:gVc animated:NO];
    }
}

@end
