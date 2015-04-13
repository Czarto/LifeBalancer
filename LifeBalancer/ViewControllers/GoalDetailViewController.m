//
//  GoalDetailViewController.m
//  LifeBalancer
//
//  Created by Pradeep Kumara on 3/28/13.
//  Copyright (c) 2013 EFutures. All rights reserved.
//

#import "GoalDetailViewController.h"
#import "Role.h"
#import "Goal.h"
#import <UIKit/UIKit.h>

@interface ContentHeightTextView ()
@property (nonatomic, strong) NSLayoutConstraint *heightConstraint;
@end

@implementation ContentHeightTextView

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	[self setNeedsUpdateConstraints];
}

- (void)updateConstraints
{
	CGSize size = [self sizeThatFits:CGSizeMake(self.bounds.size.width, FLT_MAX)];
	
	if (!self.heightConstraint) {
		self.heightConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0f constant:size.height];
		[self addConstraint:self.heightConstraint];
	}
	
	self.heightConstraint.constant = size.height;
	[super updateConstraints];
}

@end


@interface GoalDetailViewController ()
@property (weak, nonatomic) IBOutlet UITableViewCell *deleteButtonTableCell;

/**
 * A UITextView does not have placeholder capability at the time of this message. We have to fake it, using a 
 * light gray label that is displayed when there is no text in the text view and hiddne once the user starts typing.
 * See textViewDidChange and textViewDidEndEditing.
 */
@property (weak, nonatomic) IBOutlet UILabel *goalNotePlaceHolderLabel;
@end

@implementation GoalDetailViewController

@synthesize goal, role;

- (id)initWithStyle:(UITableViewStyle)style
{
	self = [super initWithStyle:style];
	if (self) {
		// Custom initialization
	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(editCancel)];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(editDone)];
	self.navigationItem.title = @"Goal Details";
	
	self.goalNote.delegate = self;
	
	[self.navigationItem setHidesBackButton:YES];
	if (goal) {
		self.txtgoalname.text = goal.name;
		self.goalNote.text = goal.note;
		[self.deleteButtonTableCell setHidden:NO];
		// If there's already text in the goal note then make sure our fake placeholder is hidden.
		if (self.goalNote.text.length > 0) {
			self.goalNotePlaceHolderLabel.hidden = YES;
		}
	} else {
		// Hide the delete button if the user is adding a new detail
		[self.deleteButtonTableCell setHidden:YES];
	}
	
	UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, self.txtgoalname.frame.size.height)];
	self.txtgoalname.leftView = paddingView;
	self.txtgoalname.leftViewMode = UITextFieldViewModeAlways;
	
	self.txtgoalname.text = goal.name;
	self.txtgoalname.delegate = self;
	UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
	[self.tableView addGestureRecognizer:singleTap];
}
- (void) viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];
}
- (void) viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];

}
-(void)editDone
{
	[self.txtgoalname resignFirstResponder];
	[self saveclicked:nil];
}
-(void)editCancel
{
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	if(!self.txtgoalname.text.length)
		[self.txtgoalname becomeFirstResponder];
}


-(void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer
{
	[self.txtgoalname resignFirstResponder];
}


- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (IBAction)saveclicked:(id)sender {
	
	BOOL containsText = [self.txtgoalname.text rangeOfCharacterFromSet:[NSCharacterSet alphanumericCharacterSet]].location != NSNotFound;
	if (!containsText) {
		[self.navigationController popViewControllerAnimated:YES];
//		[[[UIAlertView alloc]initWithTitle:nil message:@"Goal name shouldn't be empty" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
		return;
	}
	
	BOOL exist = NO;
	
	for (Goal *goalobj in role.goals) {
		if ([goalobj.name isEqualToString:self.txtgoalname.text]) {
			exist = YES;
			break;
		}
	}
	
	if (/*!exist*/YES) {
		
		if (!role) {
			return;
		}
		
		NSManagedObjectContext *context = role.managedObjectContext;
		
		if (!goal) {
			self.goal = [NSEntityDescription insertNewObjectForEntityForName:@"Goal" inManagedObjectContext:context];
			self.goal.priority = [NSNumber numberWithInteger:[self.role.goals count]];
			[role addGoalsObject:goal];
		}
		
		goal.name = self.txtgoalname.text;
		goal.note = self.goalNote.text;
		
		NSError *error = nil;
		if (![context save:&error]) {
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
		}
	}
	else
	{
		// [[[UIAlertView alloc]initWithTitle:nil message:@"Goal already exists" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
	}
	
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)deleteClicked:(id)sender {
	
	[ [[UIAlertView alloc] initWithTitle:@"Confirmation" message:@"Do you want to delete this item?" completionBlock:^(NSUInteger buttonIndex, UIAlertView *alertView) {
		if (buttonIndex == 1) {
			self.goalVC.deletedIndexPath = self.currentIndexPath;
			[self.navigationController popViewControllerAnimated:YES];
		}
		else
		{
			//
		}
		
	} cancelButtonTitle:@"NO" otherButtonTitles:@"YES",nil] show];
	
	NSLog(@"presented by : %@",self.goalVC);
}

#pragma mark UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
	self.goalNotePlaceHolderLabel.hidden = ([textView.text length] > 0);
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
	self.goalNotePlaceHolderLabel.hidden = ([textView.text length] > 0);
}

@end
