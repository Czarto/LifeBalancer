//
//  SwipeableCellTableViewCell.m
//  LifeBalancer
//
//  Created by fff on 11/8/14.
//  Copyright (c) 2014 Czarto. All rights reserved.
//

#import "SwipeableCellTableViewCell.h"
#import "GoalViewController.h"

static CGFloat const kBounceValue = 20.0f;

@interface SwipeableCellTableViewCell() <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIGestureRecognizer *GestureRecognizer;
@property (nonatomic, assign) CGPoint gestureStartPoint;
@property (nonatomic, assign) CGFloat startingRightLayoutConstraintConstant;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *contentViewRightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *contentviewLeftConstraint;

@end

@implementation SwipeableCellTableViewCell
-(void)awakeFromNib{
	[super awakeFromNib];
	
	
	
	UISwipeGestureRecognizer *ges = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(SwipeThisCell:)];
	ges.direction = UISwipeGestureRecognizerDirectionLeft;
	ges.cancelsTouchesInView = NO;
	ges.delegate = self;
	[self.mycontentView addGestureRecognizer:ges];
	[self.contentView addGestureRecognizer:ges];
	
}
-(void)swipeGes:(id) sender {
	NSLog(@"ABC");
	
}
-(void)SwipeThisCell:(UISwipeGestureRecognizer*)recognizer{
	NSLog(@"OPOPOP");
	
}
-(void)openCell{
	[self setConstraintsToShowAllButtons:NO notifyDelegateDidOpen:NO];
}

- (IBAction)cellTextEditBegin:(id)sender {
    [self.delegate swipeCellTextEditBegin:self];
}

- (IBAction)cellTextEndExit:(id)sender {
    [self.delegate swipeCellTextEndExit:self];
}
#pragma mark - UIGestureRecogmizerDelegate
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
	return NO;
}
-(void)prepareForReuse{
	[super prepareForReuse];
	[self resetConstraintConstantsToZero:NO notifyDelegateDidClose:NO];
}

-(void)updateConstraintsIfNeeded:(BOOL)animated completion:(void (^)(BOOL finished))completion{
	float duration = 0;
	if (animated) {
		duration = 0.1;
	}
	
	[UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
		[self layoutIfNeeded];
	}completion:completion];
}
-(IBAction)buttonClicked:(id)sender{
	if (sender == self.button1) {
		NSLog(@"Clicked Button1" );
		[self.delegate buttonOneActionforItemText:self.itemText];
	}else if(sender == self.button2){
		NSLog(@"Clicked Button2");
		[self.delegate buttonTwoActionforItemText:self.itemText];
	}else{
		NSLog(@"Clicked Unknown button");
		
	}
}

-(CGFloat)buttonTotalWidth{
	return CGRectGetWidth(self.frame) - CGRectGetMinX(self.button2.frame);
}

-(void)resetConstraintConstantsToZero:(BOOL)animated notifyDelegateDidClose:(BOOL)endEditing{
	//TODO: Notify delegate.
	
	if (endEditing) {
		[self.delegate cellDidClose:self];
	}
	
	if (self.startingRightLayoutConstraintConstant == 0 &&
		self.contentViewRightConstraint.constant ==0) {
		return;
	}
	
	self.contentviewLeftConstraint.constant = -kBounceValue;
	self.contentViewRightConstraint.constant = kBounceValue;
	
	[self updateConstraintsIfNeeded:animated completion:^(BOOL finished){
		self.contentviewLeftConstraint.constant = 0;
		self.contentViewRightConstraint.constant = 0;
		
		[self updateConstraintsIfNeeded:animated completion:^(BOOL finished){
			self.startingRightLayoutConstraintConstant = self.contentViewRightConstraint.constant;
		}];
	}];
}

-(void)setConstraintsToShowAllButtons:(BOOL)animated notifyDelegateDidOpen:(BOOL)notifyDelegate
{
	//TODO: Nptify delegate.
	
	if (notifyDelegate) {
		[self.delegate cellDidOpen:self];
	}
	
	//1
	if (self.startingRightLayoutConstraintConstant == [self buttonTotalWidth] &&
		self.contentViewRightConstraint.constant == [self buttonTotalWidth]) {
		return;
	}
	//2
	self.contentviewLeftConstraint.constant = -[self buttonTotalWidth]-kBounceValue;
	self.contentViewRightConstraint.constant = [self buttonTotalWidth]+kBounceValue;
	
	[self updateConstraintsIfNeeded:animated completion:^(BOOL finished){
		//3
		self.contentviewLeftConstraint.constant = -[self buttonTotalWidth];
		self.contentViewRightConstraint.constant = [self buttonTotalWidth];
		
		[self updateConstraintsIfNeeded:animated completion:^(BOOL finished){
			//4
			self.startingRightLayoutConstraintConstant = self.contentViewRightConstraint.constant;
		}];
	}];
}


#pragma mark - SwipeableCellDelegate
-(void)buttonOneActionForItemText:(NSString*)itemText {
	
}

-(void)buttonTwoActionForItemText:(NSString*)itemText {
	
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
	
	// Configure the view for the selected state
}

@end
