//
//  GoalTempViewController.m
//  LifeBalancer
//
//  Created by Rukshan Marapana on 8/1/13.
//  Copyright (c) 2013 EFutures. All rights reserved.
//

#import "GoalTempViewController.h"
#import "SetPrioritiesViewController.h"

@interface GoalTempViewController ()<UITabBarDelegate>

@end

@implementation GoalTempViewController
@synthesize gvc;
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
	self.tabBar.delegate = self;
	[self.tabBar setSelectedItem:self.tabBarItem4];
	self.view.backgroundColor = [UIColor whiteColor];
	self.navigationItem.hidesBackButton=NO;
	[self.navigationController setToolbarHidden:YES];
	self.navigationController.navigationItem.rightBarButtonItem = self.editButtonItem;
	self.parentViewController.navigationItem.title = @"Goal";
	gvc = [self.storyboard instantiateViewControllerWithIdentifier:@"goalsVC"];
	
	
    //[self presentViewController:gvc animated:NO completion:nil];
    //[self addChildViewController:gvc];
   // [self.view addSubview:gvc.view];
   // self.view = gvc.view;
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)home
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)switchToSecondTab
{
    SchedulePrioritiesViewController * sPvc;
    sPvc = [self.storyboard instantiateViewControllerWithIdentifier:@"SchedulePriorities"];
    [self.navigationController pushViewController:sPvc animated:NO];
   // [self.navigationController popViewControllerAnimated:NO];
}

-(void)switchToFirstTab
{
    
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:NO];
    
}

//-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
//{
//	if (item.tag == 2) {
//		self.tabBarController.selectedIndex = 2;
//		SetPrioritiesViewController *gVc = [self.storyboard instantiateViewControllerWithIdentifier:@"SetPriorities"];
//		[self.navigationController pushViewController:gVc animated:YES];
//	}
//	else  if (item.tag==3) {
//		
//	}
//	else if(item.tag==4)
//	{
//		self.tabBarController.selectedIndex = 4;
//		GoalViewController *gVc = [self.storyboard instantiateViewControllerWithIdentifier:@"tempGoalVC"];
//		[self.navigationController pushViewController:gVc animated:YES];
//	}
//}
-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
	NSLog(@"selected item tag : %d",(int)item.tag);
	if (item.tag==2) {
		self.tabBarController.selectedIndex = 2;
		SetPrioritiesViewController *gVc = [self.storyboard instantiateViewControllerWithIdentifier:@"SetPriorities"];
		//[self.navigationController popToRootViewControllerAnimated:YES];
		[self.navigationController pushViewController:gVc animated:NO];
	}
	else  if (item.tag==3) {
		//[self goNext];
	}
	else if(item.tag==4)
	{
		self.tabBarController.selectedIndex = 4;
		//[self.navigationController popToRootViewControllerAnimated:YES];
		GoalViewController *gVc = [self.storyboard instantiateViewControllerWithIdentifier:@"tempGoalVC"];
		[self.navigationController pushViewController:gVc animated:NO];
	}
}

-(void)viewWillDisappear:(BOOL)animated
{
	//[self.navigationController popToRootViewControllerAnimated:YES];
}

@end
