//
//  SetPrioritiesDetailViewController.h
//  LifeBalancer
//
//  Created by IgnitionIT Solutions on 4/13/13.
//  Copyright (c) 2013 EFutures. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Task;
@class Role;
@interface SetPrioritiesDetailViewController : UITableViewController
@property (strong, nonatomic) IBOutlet UITextField *taskName;
@property (strong, nonatomic) Task *task;
@property (strong, nonatomic) Role *role;
- (IBAction)saveClicked:(id)sender;

@end
