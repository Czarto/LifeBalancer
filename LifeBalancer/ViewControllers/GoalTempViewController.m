//
//  GoalTempViewController.m
//  LifeBalancer
//
//  Created by Rukshan Marapana on 8/1/13.
//  Copyright (c) 2013 EFutures. All rights reserved.
//

#import "GoalTempViewController.h"

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
    
    UIBarButtonItem *backButton = [[ UIBarButtonItem alloc ] initWithTitle: @"Home"
                                                                     style: UIBarButtonItemStyleBordered
                                                                    target: self
                                                                    action: @selector(home)];
    self.tabBar.delegate = self;
    gvc = [self.storyboard instantiateViewControllerWithIdentifier:@"goalsVC"];
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem = backButton;
    [self.tabBar setSelectedItem:self.tabBarItem4];
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

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{

    
    NSLog(@"selected item tag : %d",item.tag);
    if (item.tag==1) {
        [self home];
    }
    else  if (item.tag==2) {
        //[self back];
        [self switchToFirstTab];
    }
    else  if (item.tag==3) {
        [self switchToSecondTab];
    }
}

@end
