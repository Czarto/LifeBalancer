//
//  RoleViewController.h
//  LifeBalancer
//
//  Created by Pradeep Kumara on 3/22/13.
//  Copyright (c) 2013 EFutures. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RoleViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,UITextFieldDelegate>
{
	int roleCount;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
