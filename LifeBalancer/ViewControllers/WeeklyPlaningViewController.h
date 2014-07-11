//
//  WeeklyPlaningViewController.h
//  LifeBalancer
//
//  Created by IgnitionIT Solutions on 4/2/13.
//  Copyright (c) 2013 EFutures. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKitUI/EventKitUI.h>
@interface WeeklyPlaningViewController : UIViewController


@property (strong, nonatomic) IBOutlet UIButton *resumeButtton;


- (IBAction)resume:(id)sender;
- (IBAction)reset:(id)sender;

@end
