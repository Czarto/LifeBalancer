//
//  GoalViewController.h
//  LifeBalancer
//
//  Created by Pradeep Kumara on 3/28/13.
//  Copyright (c) 2013 EFutures. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface GoalViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    BOOL deleteWithoutConfirmation;
    BOOL shouldDisplayInEditMode;
    AppDelegate *appDel;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSIndexPath *deletedIndexPath;
@end
