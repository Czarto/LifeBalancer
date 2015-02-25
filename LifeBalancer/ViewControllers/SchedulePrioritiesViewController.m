//
//  SchedulePrioritiesViewController.m
//  LifeBalancer
//
//  Created by IgnitionIT Solutions on 4/4/13.
//  Copyright (c) 2013 EFutures. All rights reserved.
//

#import "SchedulePrioritiesViewController.h"
#import "DataAdapter.h"
#import "Role.h"
#import "Task.h"

@interface SchedulePrioritiesViewController ()<UITabBarDelegate>
{
 NSArray *rolesarray;
}
@end

@implementation SchedulePrioritiesViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
     self.navigationItem.title = @"Schedule Priorities";
      [self loadroles];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
     [self.tabBar setSelectedItem:self.tabBarItem3];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.tabBar setSelectedItem:nil];
   
}
- (void)viewDidLoad
{
   
    [super viewDidLoad];
    self.tabBar.delegate = self;
     self.navigationItem.hidesBackButton=YES;
    [self.navigationController setToolbarHidden:YES];
    [self addSwipeGesture];
   
  
   }


-(void)addSwipeGesture
{
    UISwipeGestureRecognizer* swipeRightGesture;
    swipeRightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipeRightGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self.tableView addGestureRecognizer:swipeRightGesture];
}

-(void)handleSwipe:(UISwipeGestureRecognizer *)recognizer
{
    NSLog(@"swiped");
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        CGPoint swipeLocation = [recognizer locationInView:_tableView];
        NSIndexPath *swipedIndexPath = [_tableView indexPathForRowAtPoint:swipeLocation];
        UITableViewCell *swipedCell = [_tableView cellForRowAtIndexPath:swipedIndexPath];
        
        NSLog(@"swiped index: %d",(int)swipedIndexPath.row);
        // do what you want here
        
        
        Role *role = rolesarray[swipedIndexPath.section];
        DataAdapter *da = [[DataAdapter alloc]init];
        NSMutableArray *tasksarray = [NSMutableArray arrayWithArray:[da getTasksByPriority:role.objectID]];
        Task *task = [tasksarray objectAtIndex:swipedIndexPath.row];
        
        
        if([[task isDone] intValue]== 1)
        {
            task.isDone = [NSNumber numberWithBool:NO];
        }
        else{
            task.isDone = [NSNumber numberWithBool:YES];
        }
        
         NSString *formatString;
        
        if([[task isDone] intValue]== 1){
            //check mark
            formatString = @"\u2713  %@";
        }else{
            
            formatString = @"\u273A  %@";
        }
        
        NSString *completeString = [NSString stringWithFormat:formatString,task.name];
        swipedCell.textLabel.text = completeString;
    }
}

- (void)loadroles
{
    rolesarray = [[[DataAdapter alloc]init]roles];
    [self.tableView reloadData];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return rolesarray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    Role *role = rolesarray[section];
    return [role.tasks count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    Role *role = rolesarray[section];
    return role.name;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *rolecell = [tableView dequeueReusableCellWithIdentifier:@"SchedulePrioritiesCell"];
    Role *role = rolesarray[indexPath.section];
    
    DataAdapter *da = [[DataAdapter alloc]init];
    NSMutableArray *tasksarray = [NSMutableArray arrayWithArray:[da getTasksByPriority:role.objectID]];
  

    
    
    Task *task = [tasksarray objectAtIndex:indexPath.row];
    rolecell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    
    NSString *formatString;
    
  
    // set cell image
    if([[task isDone] intValue]== 1){
       //check mark
       formatString = @"\u2713  %@";
    }else{
       
       formatString = @"\u273A  %@";
    }
    
     NSString *completeString = [NSString stringWithFormat:formatString,task.name];
    rolecell.textLabel.text = completeString;

    return rolecell;
}

#pragma mark -
#pragma mark Buttom Bar Buttons


-(void)home
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)back{
    [self.navigationController popViewControllerAnimated:NO];
}

-(void)done{
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:NO];
   
}

-(void)switchToFirstTab
{
    
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:NO];
    
}


#pragma mark UITabBarController

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    
    NSLog(@"selected item tag : %d",(int)item.tag);
    if (item.tag==1) {
        [self home];
    }
    else  if (item.tag==2) {
        [self switchToFirstTab];
    }
    else  if (item.tag==3) {
        //[self goNext];
    }
    else if(item.tag==4)
    {
        GoalViewController *gVc = [self.storyboard instantiateViewControllerWithIdentifier:@"tempGoalVC"];
        [self.navigationController pushViewController:gVc animated:NO];
    }
}
@end
