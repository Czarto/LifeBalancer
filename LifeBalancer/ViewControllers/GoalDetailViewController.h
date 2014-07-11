//
//  GoalDetailViewController.h
//  LifeBalancer
//
//  Created by Pradeep Kumara on 3/28/13.
//  Copyright (c) 2013 EFutures. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoalViewController.h"
@class Role;
@class Goal;

@interface GoalDetailViewController : UITableViewController<UITextViewDelegate,UITextFieldDelegate>

@property (strong, nonatomic) Goal *goal;
@property (strong, nonatomic) Role *role;
@property (weak, nonatomic) IBOutlet UITextField *txtgoalname;
@property (weak, nonatomic) IBOutlet UITextView *txtGoalNote;
@property (nonatomic,strong) GoalViewController *goalVC;
@property (nonatomic,strong) NSIndexPath *currentIndexPath;
- (IBAction)saveclicked:(id)sender;
- (IBAction)deleteClicked:(id)sender;
@end
