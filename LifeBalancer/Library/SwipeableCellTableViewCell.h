//
//  SwipeableCellTableViewCell.h
//  LifeBalancer
//
//  Created by fff on 11/8/14.
//  Copyright (c) 2014 Czarto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "customtextfield.h"

@protocol SwipeableCellDelegate <NSObject>

-(void)buttonOneActionforItemText:(NSString*)itemText;
-(void)buttonTwoActionforItemText:(NSString*)itemText;

-(void)cellDidOpen:(UITableViewCell*)cell;
-(void)cellDidClose:(UITableViewCell*)cell;

- (IBAction)swipeCellTextEditBegin:(id)sender;
- (IBAction)swipeCellTextEndExit:(id)sender;

@end

@interface SwipeableCellTableViewCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIButton *button1;
@property (nonatomic, weak) IBOutlet UIButton *button2;
@property (nonatomic, weak) IBOutlet UIView *mycontentView;
@property (nonatomic, weak) IBOutlet UILabel *myTextLable;
@property (nonatomic, strong) IBOutlet customtextfield *myTextField;

@property (nonatomic, strong) NSString *itemText;
@property (nonatomic, weak) id <SwipeableCellDelegate> delegate;
-(void)openCell;

- (IBAction)cellTextEditBegin:(id)sender;
- (IBAction)cellTextEndExit:(id)sender;

@end
