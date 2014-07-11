//
//  SetReminderViewController.h
//  LifeBalancer
//
//  Created by IgnitionIT Solutions on 4/11/13.
//  Copyright (c) 2013 EFutures. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>
@class Goal;
@interface SetReminderViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *dateField;
@property (strong, nonatomic) EKEventStore *eventStore;
- (IBAction)setReminder:(id)sender;
@property (strong, nonatomic) Goal *goal;
@end
