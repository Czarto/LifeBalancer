//
//  SetPrioritiesViewController.h
//  LifeBalancer
//
//  Created by IgnitionIT Solutions on 4/13/13.
//  Copyright (c) 2013 EFutures. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"
#import "CCustomButton.h"

@interface SetPrioritiesViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,UITabBarControllerDelegate,SWTableViewCellDelegate>
{
	BOOL deleteWithoutConfirmation;
}
@property (strong, nonatomic) IBOutlet UITableView *tableView;
//@property (nonatomic,assign)BOOL shouldReset;

@property (nonatomic,assign)BOOL shouldBePresentedInEditMode;
@property (weak, nonatomic) IBOutlet UITabBar *tabBar;
@property (weak, nonatomic) IBOutlet UITabBarItem *tabBarItem1;
@property (nonatomic,assign)BOOL isPink;
@property (nonatomic, strong) NSIndexPath *deletedIndexPath;
@end
