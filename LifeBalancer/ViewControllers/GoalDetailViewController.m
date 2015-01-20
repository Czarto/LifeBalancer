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

@end

@implementation GoalDetailViewController

@synthesize goal, role, txtGoalNote;

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
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(editDone)];
	self.navigationItem.title = @"Goal Details";
	
	[self.navigationItem setHidesBackButton:YES];
	if (goal) {
		self.txtgoalname.text = goal.name;
		
		
		// if (goal.note) {
		txtGoalNote.text = goal.note;
		// }
	}
	
	UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, self.txtgoalname.frame.size.height)];
	self.txtgoalname.leftView = paddingView;
	self.txtgoalname.leftViewMode = UITextFieldViewModeAlways;
	
	self.txtgoalname.text = goal.name;
	txtGoalNote.delegate = self;
	self.txtgoalname.delegate = self;
	UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
	[self.tableView addGestureRecognizer:singleTap];
}
- (void) viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];
	
	txtGoalNote.frame = CGRectMake(0, txtGoalNote.frame.origin.y, 320, [self measureHeight]+16);
}
- (void) viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];

}
-(void)editDone
{
	if ([self.navigationItem.rightBarButtonItem.title isEqualToString:@"Done"]) {
		[self.txtgoalname resignFirstResponder];
		self.navigationItem.rightBarButtonItem.title = @"Edit";
		[self saveclicked:nil];
	}
	else
	{
		[self.txtgoalname becomeFirstResponder];
		self.navigationItem.rightBarButtonItem.title = @"Done";
	}
	//[self.tableView reloadData];
	//[self reloadInputViews];
}

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	// self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


-(void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer
{
	[txtGoalNote resignFirstResponder];
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
		goal.note = txtGoalNote.text;
		
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

- (void)textViewDidBeginEditing:(UITextView *)textView
{
	//     if ([self.navigationItem.rightBarButtonItem.title isEqualToString:@"Done"]) {
	//
	//     }
	
	self.navigationItem.rightBarButtonItem.title = @"Done";
}
- (void)textViewDidChangeSelection:(UITextView *)textView {
	//[textView sizeToFit]; //added
}
- (void)textViewDidEndEditing:(UITextView *)textView
{
	//self.navigationItem.rightBarButtonItem.title = @"Edit";
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
{
	const char * _char = [text cStringUsingEncoding:NSUTF8StringEncoding];
	int isBackSpace = strcmp(_char, "\b");
	
	if ( [text isEqualToString:@"\n"] || isBackSpace == -8 ) {
		textView.frame = CGRectMake(0, textView.frame.origin.y, 320, [self measureHeight]+16);
	}
	return YES;
}
#pragma mark UITextFieldDelegate


- (void)textFieldDidBeginEditing:(UITextField *)textField{
	self.navigationItem.rightBarButtonItem.title = @"Done";
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
	self.navigationItem.rightBarButtonItem.title = @"Edit";
}
- (CGFloat)measureHeight
{
	if ([self respondsToSelector:@selector(snapshotViewAfterScreenUpdates:)])
	{
		CGRect frame = self.txtGoalNote.bounds;
		CGSize fudgeFactor;
		// The padding added around the text on iOS6 and iOS7 is different.
		fudgeFactor = CGSizeMake(10.0, 16.0);
		
		frame.size.height -= fudgeFactor.height;
		frame.size.width -= fudgeFactor.width;
		
		NSMutableAttributedString* textToMeasure;
		if(self.txtGoalNote.attributedText && self.txtGoalNote.attributedText.length > 0){
			textToMeasure = [[NSMutableAttributedString alloc] initWithAttributedString:self.txtGoalNote.attributedText];
		}
		else{
			textToMeasure = [[NSMutableAttributedString alloc] initWithString:self.txtGoalNote.text];
			[textToMeasure addAttribute:NSFontAttributeName value:self.txtGoalNote.font range:NSMakeRange(0, textToMeasure.length)];
		}
		
		if ([textToMeasure.string hasSuffix:@"\n"])
		{
			[textToMeasure appendAttributedString:[[NSAttributedString alloc] initWithString:@"-" attributes:@{NSFontAttributeName: self.txtGoalNote.font}]];
		}
		
		// NSAttributedString class method: boundingRectWithSize:options:context is
		// available only on ios7.0 sdk.
		CGRect size = [textToMeasure boundingRectWithSize:CGSizeMake(CGRectGetWidth(frame), MAXFLOAT)
												  options:NSStringDrawingUsesLineFragmentOrigin
												  context:nil];
		
		return CGRectGetHeight(size) + fudgeFactor.height;
	} else {
		return self.txtGoalNote.contentSize.height;
	}
}
@end
