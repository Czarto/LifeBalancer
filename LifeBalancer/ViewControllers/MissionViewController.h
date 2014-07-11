//
//  MissionViewController.h
//  LifeBalancer
//
//  Created by Pradeep Kumara on 3/21/13.
//  Copyright (c) 2013 EFutures. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MissionViewController : UIViewController<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *txtmissionstatement;
@property (nonatomic,assign) int selectedVcIndex;

@end
