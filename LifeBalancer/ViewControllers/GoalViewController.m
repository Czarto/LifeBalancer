//
//  GoalViewController.m
//  LifeBalancer
//
//  Created by Pradeep Kumara on 3/28/13.
//  Copyright (c) 2013 EFutures. All rights reserved.
//

#import "GoalViewController.h"
#import "GoalDetailViewController.h"
#import "DataAdapter.h"
#import "Role+Cutomable.h"
#import "Goal.h"
#import "AppDelegate.h"

@interface GoalViewController (){
    NSMutableArray *rolesarray;
}

@end

@implementation GoalViewController

@synthesize deletedIndexPath = _deletedIndexPath;

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
   
    self.tabBarController.tabBar.hidden = NO;
    self.parentViewController.navigationItem.rightBarButtonItem = self.editButtonItem;
    //self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Home" style:UIBarButtonItemStyleBordered target:self action:@selector(goToHome)];
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.parentViewController.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    if (self.deletedIndexPath) {
        NSLog(@"should delete %@",self.deletedIndexPath);
        deleteWithoutConfirmation = YES;
        [self tableView:self.tableView commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:self.deletedIndexPath];
        
    }
}
- (void)viewWillAppear:(BOOL)animated
{
    self.parentViewController.navigationItem.title = @"Goals";
    appDel = [[UIApplication sharedApplication] delegate];
    shouldDisplayInEditMode = YES;
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = NO;
    self.navigationItem.title = @"Goals";
    [self loadroles];
    
    if (!self.editing) {
        
        if (shouldDisplayInEditMode || appDel.isGoalEditing) {
            [self.tableView setEditing:YES animated:YES];
            [self setEditing:YES];
            shouldDisplayInEditMode = NO;
        }
     
    }

    
    [self.tableView setContentOffset:appDel.lastGoalScrollPosition];
    // [self.tableView setEditing:YES animated:YES];
   // [self performSelector:@selector(execLater) withObject:nil afterDelay:5];
}

-(void)viewWillDisappear:(BOOL)animated
{
    appDel = [[UIApplication sharedApplication] delegate];
    appDel.isGoalEditing = self.isEditing;
    appDel.lastGoalScrollPosition = self.tableView.contentOffset;
}

-(void)execLater
{
    [self.tableView setEditing:YES animated:YES];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    self.title = nil;
}

- (void)loadroles
{
    rolesarray = [[NSMutableArray alloc]init];
    
     NSArray *originalArray =  [[[DataAdapter alloc]init]roles];
    
    for (Role *role in originalArray) {
        
        if ([role.name isEqualToString:@"Physical"] ||[role.name isEqualToString:@"Spiritual"]||[role.name isEqualToString:@"Mental"]||[role.name isEqualToString:@"Social"]) {
            // default values
        }
        else{
            NSLog(@"Role Name %@", role.name);
            [rolesarray addObject:role];
        }
    }
//
    
    if ([rolesarray count]<=0) {
        NSLog(@"No goals");
        
        UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"You must specify at least one Role first" completionBlock:^(NSUInteger buttonIndex, UIAlertView *alertView) {
            NSLog(@"switch");
            [self.tabBarController setSelectedIndex:1];
            
        } cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alrt show];
    }
    else{
        
    }
    
    
    [self.tableView reloadData];
}

- (void)goToHome
{
    [self.tabBarController setSelectedIndex:0];
}

- (IBAction)goToPrev:(id)sender {
    [self.tabBarController setSelectedIndex:2];
}
#pragma mark -
#pragma mark Editing

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    
    [self.navigationItem setHidesBackButton:editing animated:YES];
	
    [self.tableView setEditing:editing animated:animated];
    
    [self.tableView beginUpdates];
    
    for (int rolecount=0; rolecount < rolesarray.count; rolecount++) {
        Role *role = rolesarray[rolecount];
        if (role.goals.count < 5) {
            NSArray *rolesInsertIndexPath = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:[role.goals count] inSection:rolecount]];
            
            if (editing) {
                [self.tableView insertRowsAtIndexPaths:rolesInsertIndexPath withRowAnimation:UITableViewRowAnimationTop];
                
            } else {
                [self.tableView deleteRowsAtIndexPaths:rolesInsertIndexPath withRowAnimation:UITableViewRowAnimationTop];
                
            }
        }
    }
    [self.tableView endUpdates];
}



#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return rolesarray.count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;
    Role *role = rolesarray[section];
    rows = [role.goals count];
    
    if (role.goals.count != 0) {
        shouldDisplayInEditMode = NO;
    }
    
    if (self.editing && rows < 5) {
        rows++;
    }
    return rows;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    Role *role = rolesarray[section];
    return role.name;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *rolecell = [tableView dequeueReusableCellWithIdentifier:@"GoalCell"];
    Role *role = rolesarray[indexPath.section];
    
    if (indexPath.row < role.goals.count) {
        Goal *goal = [role.getGoalsByPriority objectAtIndex:indexPath.row];
        rolecell.textLabel.text = goal.name;
    } else {
        rolecell.textLabel.text = @"Add Goal";
    }
    
    rolecell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return rolecell;
}

//- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//	NSIndexPath *rowToSelect = indexPath;
//    BOOL isEditing = self.editing;
//    
//    if (!isEditing) {
//        rowToSelect = nil;
//    }
//    
//	return rowToSelect;
//}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GoalDetailViewController *nextViewController = nil;
    
    nextViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GoalDetailViewController"];
    nextViewController.goalVC = self;
    nextViewController.currentIndexPath = indexPath;
    
    self.deletedIndexPath = nil;
    
    Role *role = rolesarray[indexPath.section];
    nextViewController.role = role;
    
    if (indexPath.row < role.goals.count) {
        nextViewController.goal = role.getGoalsByPriority[indexPath.row];
    }
    
    if (nextViewController) {
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
    
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCellEditingStyle style = UITableViewCellEditingStyleNone;
    
    Role *role = rolesarray[indexPath.section];
    
    if (indexPath.row < role.goals.count) {
        style = UITableViewCellEditingStyleDelete;
    } else {
        style = UITableViewCellEditingStyleInsert;
    }
    
    return style;
}




- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (deleteWithoutConfirmation) {
         deleteWithoutConfirmation = NO;
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            Role *role = rolesarray[indexPath.section];
            
            if (indexPath.row < role.goals.count) {
                
                NSMutableArray *goalsarray = [NSMutableArray arrayWithArray:[role getGoalsByPriority]];
                
                Goal *selectedgoal = [goalsarray objectAtIndex:indexPath.row];
                
                [role removeGoalsObject:selectedgoal];
                [selectedgoal.managedObjectContext deleteObject:selectedgoal];
                
                [goalsarray removeObjectAtIndex:indexPath.row];
                
                for (int order=0; order<goalsarray.count; order++) {
                    Goal *goal = [goalsarray objectAtIndex:order];
                    goal.priority = [NSNumber numberWithInt:order];
                }
                
                // Save the context.
                NSError *error;
                if (![role.managedObjectContext save:&error]) {
                    
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                    abort();
                }
                
                [self loadroles];
            }
            
            
            
        }
        else if (editingStyle == UITableViewCellEditingStyleInsert) {
            [self tableView:tableView didSelectRowAtIndexPath:indexPath];
        }
       
    }
    else
    {
    
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        
        [[[UIAlertView alloc]initWithTitle:@"Confirmation"
                                   message:@"Do you want to delete ?"
                           completionBlock:^(NSUInteger buttonIndex, UIAlertView *alertView) {
                               if (buttonIndex == 1) {
                                   
                                   Role *role = rolesarray[indexPath.section];
                                   
                                   if (indexPath.row < role.goals.count) {
                                       
                                       NSMutableArray *goalsarray = [NSMutableArray arrayWithArray:[role getGoalsByPriority]];
                                       
                                       Goal *selectedgoal = [goalsarray objectAtIndex:indexPath.row];
                                                                                                                     
                                           [role removeGoalsObject:selectedgoal];
                                           [selectedgoal.managedObjectContext deleteObject:selectedgoal];
                                           
                                           [goalsarray removeObjectAtIndex:indexPath.row];
                                           
                                           for (int order=0; order<goalsarray.count; order++) {
                                               Goal *goal = [goalsarray objectAtIndex:order];
                                               goal.priority = [NSNumber numberWithInt:order];
                                           }
                                           
                                           // Save the context.
                                           NSError *error;
                                           if (![role.managedObjectContext save:&error]) {
                                               
                                               NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                                               abort();
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
}

#pragma mark -
#pragma mark Moving rows

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL canMove = NO;
    Role *role = rolesarray[indexPath.section];
    canMove = indexPath.row != [role.goals count];
    return canMove;
}


- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    NSIndexPath *target = proposedDestinationIndexPath;
    NSIndexPath *source = sourceIndexPath;
    
    Role *role = rolesarray[source.section];
    
    if (target.section < source.section) {
        target = [NSIndexPath indexPathForRow:0 inSection:source.section];
    } else if (target.section > source.section) {
        target = [NSIndexPath indexPathForRow:([role.goals count] - 1) inSection:source.section];
    } else {
        NSUInteger ingredientsCount_1 = [role.goals count] - 1;
        
        if (target.row > ingredientsCount_1) {
            target = [NSIndexPath indexPathForRow:ingredientsCount_1 inSection:source.section];
        }
    }
	
    return target;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	
    if (fromIndexPath.section == toIndexPath.section) {
        Role *role = [rolesarray objectAtIndex:fromIndexPath.section];
        NSMutableArray *goalsarray = [NSMutableArray arrayWithArray:[role getGoalsByPriority]];
        
        Goal *selectedgoal = [goalsarray objectAtIndex:fromIndexPath.row];
        
        [goalsarray removeObjectAtIndex:fromIndexPath.row];
        [goalsarray insertObject:selectedgoal atIndex:toIndexPath.row];
        
        for (int order=0; order<goalsarray.count; order++) {
            Goal *goal = [goalsarray objectAtIndex:order];
            goal.priority = [NSNumber numberWithInt:order];
        }
        
        // Save the context.
        NSError *error;
        if (![role.managedObjectContext save:&error]) {
            
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
