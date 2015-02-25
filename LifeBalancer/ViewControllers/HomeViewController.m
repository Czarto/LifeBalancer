//
//  HomeViewController.m
//  LifeBalancer
//
//  Created by Pradeep Kumara on 3/21/13.
//  Copyright (c) 2013 EFutures. All rights reserved.
//

#import "HomeViewController.h"
#import "DataAdapter.h"
#import "Role.h"
#import "Task.h"
#import "AppDelegate.h"
#import "WeeklyPlaningViewController.h"
#import "SetPrioritiesViewController.h"



@interface HomeViewController ()<UIAlertViewDelegate, UIActionSheetDelegate>

@end

@implementation HomeViewController

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
	[[[DataAdapter alloc]init] initialSetup];
	self.tabBarController.tabBar.hidden = YES;
	self.view.tag = 101;
}

- (void)viewWillAppear:(BOOL)animated
{
	[self.navigationController setToolbarHidden:YES];
	self.tabBarController.tabBar.hidden = YES;
	[super viewWillAppear:animated];
	self.navigationItem.title = @"Life Balancer";
}
-(void)viewWillDisappear:(BOOL)animated{
	[super viewWillDisappear:animated];
	self.navigationItem.title = @"Home";
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	WeeklyPlaningViewController *wpvc = (WeeklyPlaningViewController *)[segue destinationViewController];
	wpvc.hidesBottomBarWhenPushed = YES;
	if ([segue.identifier isEqualToString:@"segueToTab1"]) {
		((MissionViewController *)[[((UITabBarController *)segue.destinationViewController) viewControllers] objectAtIndex:0]).selectedVcIndex = selectedTab;
	}
	
	
	if ([segue.identifier isEqualToString:@"weekSegue1"] || [segue.identifier isEqualToString:@"weekSegue2"])
	{
		UITableViewCell *cell = (UITableViewCell*)sender;
		NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
		
		SetPrioritiesViewController *vc = (SetPrioritiesViewController*)[segue destinationViewController];
		
		if (indexPath.row==0) {
			vc.shouldBePresentedInEditMode = NO;
		}
		
	}
	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	
	if (indexPath.section == 0)
	{
		if (indexPath.row == 0)
		{
			selectedTab = 0;
		}
		else if(indexPath.row == 1)
		{
			selectedTab = 1;
		}
		else if(indexPath.row == 2)
		{
			selectedTab =2;
		}
		[self performSegueWithIdentifier:@"segueToTab1" sender:self];
		
	}
	else if(indexPath.section == 1)
	{
		if (indexPath.row == 0) {
			
		}
		else if (indexPath.row==1)
		{
			UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select for New Week" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Copy Previous Week",@"Start With Blank Week", nil];
			actionSheet.tag = 1;
			[actionSheet showInView:self.view];
			
			
		}
	}
	
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	switch (actionSheet.tag) {
  case 1:{
	  if (buttonIndex==0) {
		  // YES
		  SetPrioritiesViewController *spVC = [self.storyboard instantiateViewControllerWithIdentifier:@"NewTabVC"];
		  
		  // Reseting
		  for (Role *role in [[[DataAdapter alloc]init]roles]) {
			  for (Task *task in role.tasks) {
				  task.isDone = [NSNumber numberWithInt:1];
				  task.calendarId = nil;
			  }
		  }
		  NSError *error;
		  AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
		  if (![appdelegate.managedObjectContext save:&error]) {
			  NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			  abort();
		  }
		  
		  //spVC.tabBarItem1.shouldBePresentedInEditMode = YES;
		  [self.navigationController pushViewController:spVC animated:YES];
	  }
	  else if(buttonIndex == 1){
		  //NO
		  if([self checkforSelectedGoals]){
			  
			  BOOL permission = YES;
			  
			  permission = [[[DataAdapter alloc]init]resetPriorities];
			  
			  if(permission){
				  [[[DataAdapter alloc]init]reset];
				  SetPrioritiesViewController *setPrioritiesViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"NewTabVC"];
				//d  setPrioritiesViewController.shouldBePresentedInEditMode = YES;
				  [self.navigationController pushViewController:setPrioritiesViewController animated:YES];
				  
			  }
			  
		  }else
		  {
			  
			  
			  SetPrioritiesViewController *setPrioritiesViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"NewTabVC"];
			 // setPrioritiesViewController.shouldBePresentedInEditMode = YES;
			  [self.navigationController pushViewController:setPrioritiesViewController animated:YES];
			  
			  
		  }
		  
	  }
	  else if (buttonIndex == 2)
	  {
		  
	  }
	  
  }
			
			break;
			
  default:
			break;
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


- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	[self tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}





@end
