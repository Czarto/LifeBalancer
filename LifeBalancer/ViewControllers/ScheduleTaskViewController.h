//
//  ScheduleTaskViewController.h
//  LifeBalancer
//
//  Created by IgnitionIT Solutions on 4/4/13.
//  Copyright (c) 2013 EFutures. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKitUI/EventKitUI.h>
@class Task;
@class Role;
@interface ScheduleTaskViewController : UIViewController<EKEventEditViewDelegate>

@property (strong, nonatomic) Task *task;
@property (strong, nonatomic) Role *role;
@property (strong, nonatomic) IBOutlet UIButton *doneButton;

- (IBAction)markAsDone:(id)sender;
- (IBAction)sendToCalender:(id)sender;
- (IBAction)sendToReminder:(id)sender;


@end
