//
//  RoleViewController.m
//  LifeBalancer
//
//  Created by Pradeep Kumara on 3/22/13.
//  Copyright (c) 2013 EFutures. All rights reserved.
//

#import "RoleViewController.h"
#import "RoleDetailViewController.h"
#import "DataAdapter.h"
#import "Role.h"

@interface RoleViewController () {
    NSMutableArray *rolesarray;
}

@end

@implementation RoleViewController

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
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Home" style:UIBarButtonItemStyleBordered target:self action:@selector(goToHome)];
}

- (void)viewWillAppear:(BOOL)animated
{
    
  self.parentViewController.navigationItem.title = @"Roles";
    self.parentViewController.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tabBarController.tabBar.hidden = NO;
   // [self.tabBarController setSelectedIndex:2];
    [super viewWillAppear:animated];
    self.navigationItem.title = @"Roles";
    [self loadroles];
    
    NSLog(@"Role count : %d",roleCount);
    
    if (!self.editing) {
        
        if (roleCount<1) {
        [self.tableView setEditing:YES animated:YES];
        [self setEditing:YES];
        }
    }
    
}

-(void)viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated];
   // [self.tableView setEditing: YES animated: YES];
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    self.title = nil;
}

- (void)loadroles
{
    //rolesarray
    rolesarray = [[NSMutableArray alloc]init];
    NSArray *originalArray = [[[DataAdapter alloc]init]roles];
    
    for (Role *role in originalArray) {
        
        if ([role.name isEqualToString:@"Physical"] ||[role.name isEqualToString:@"Spiritual"]||[role.name isEqualToString:@"Mental"]||[role.name isEqualToString:@"Social"]) {
            // default values
        }
        else{
            NSLog(@"Role Name %@", role.name);
            [rolesarray addObject:role];
        }
        roleCount = rolesarray.count;
    }
    
    [self.tableView reloadData];
}

- (void)goToHome
{
    [self.tabBarController setSelectedIndex:0];
}

- (IBAction)goToPrev:(id)sender {
    [self.tabBarController setSelectedIndex:1];
}

- (IBAction)goToNext:(id)sender {
    [self.tabBarController setSelectedIndex:3];
}
#pragma mark -
#pragma mark Editing

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    
    [super setEditing:editing animated:animated];
    
    [self.navigationItem setHidesBackButton:editing animated:YES];
	
    [self.tableView setEditing:editing animated:animated];
    
    if (rolesarray.count < 12) {
        [self.tableView beginUpdates];
        
        NSArray *rolesInsertIndexPath = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:[rolesarray count] inSection:0]];
        
        if (editing) {
            [self.tableView insertRowsAtIndexPaths:rolesInsertIndexPath withRowAnimation:UITableViewRowAnimationTop];
            
        } else {
            [self.tableView deleteRowsAtIndexPaths:rolesInsertIndexPath withRowAnimation:UITableViewRowAnimationTop];
            
        }
        
        [self.tableView endUpdates];
    }
}

#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;
    rows = [rolesarray count];
    NSLog(@"count : %d",rows);
    if (self.editing && rows<12) {
        rows++;
    }
    return rows;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        
    UITableViewCell *rolecell = [tableView dequeueReusableCellWithIdentifier:@"RoleCell"];
    NSUInteger rolescount = [rolesarray count];
    
    if (indexPath.row < rolescount) {
        rolecell.textLabel.text = [[rolesarray objectAtIndex:indexPath.row]name];
    } else {
        rolecell.textLabel.text = @"Add Role";
    }
    rolecell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return rolecell;
}

#pragma mark -
#pragma mark Editing rows

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSIndexPath *rowToSelect = indexPath;
    
    if (/*!self.isEditing*/NO) {
        rowToSelect = nil;
    }else if (indexPath.row < [rolesarray count]) {
        Role *role = [rolesarray objectAtIndex:indexPath.row];
        
       // if (!role.custom.boolValue) {
           //rowToSelect = nil;
       // }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
	return rowToSelect;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
     
    [self selectRowAtIndexPath:indexPath];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    UITableViewCellEditingStyle style = UITableViewCellEditingStyleNone;
    
    if (indexPath.row < [rolesarray count]) {
        Role *role = [rolesarray objectAtIndex:indexPath.row];
        
       // if (role.custom.boolValue) {
            style = UITableViewCellEditingStyleDelete;
       // }
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
                                  
                                  if (indexPath.row < [rolesarray count]) {
                                      Role *role = [rolesarray objectAtIndex:indexPath.row];
                                      
                                      DataAdapter *db = [[DataAdapter alloc]init];
                                      NSMutableArray *goalsarray = [NSMutableArray arrayWithArray:[db tasksSavedInTheCalender:[role objectID]]];
                                      
                                      if(goalsarray.count>0) {
                                          
                                          permission = [[[DataAdapter alloc]init]deleteCalenderEvents:role.objectID];
                                      }
                                      
                                      if(permission){
                                         
                                          [role.managedObjectContext deleteObject:role];
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
        [self selectRowAtIndexPath:indexPath];
    }
}

- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath {
    RoleDetailViewController *nextViewController = nil;
    
    nextViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RoleDetailViewController"];
    
    Role *role = nil;
    
    if (indexPath.row < [rolesarray count]) {
        role = [rolesarray objectAtIndex:indexPath.row];
        nextViewController.role = role;
    }
    
    nextViewController.rolesarray = rolesarray;
    // If we got a new view controller, push it .
    if (nextViewController) {
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
}



- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}
@end
