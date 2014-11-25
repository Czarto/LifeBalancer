
//
//  RoleDetailViewController.h
//  LifeBalancer
//
//  Created by Pradeep Kumara on 3/27/13.
//  Copyright (c) 2013 EFutures. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Role;

@interface RoleDetailViewController : UITableViewController
- (IBAction)saveclick:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *txtrolename;
@property (nonatomic, strong) Role *role;

@end
