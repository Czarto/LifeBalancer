//
//  SchedulePrioritiesViewController.h
//  LifeBalancer
//
//  Created by IgnitionIT Solutions on 4/4/13.
//  Copyright (c) 2013 EFutures. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoalViewController.h"

@interface SchedulePrioritiesViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITableView *tableView;
//@property (nonatomic,assign) BOOL removeMarks;
@property (weak, nonatomic) IBOutlet UITabBar *tabBar;
@property (weak, nonatomic) IBOutlet UITabBarItem *tabBarItem3;
@property (weak, nonatomic) IBOutlet UITabBarItem *tabBarItem2;

@end
