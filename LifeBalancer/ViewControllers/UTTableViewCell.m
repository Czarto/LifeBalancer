//
//  UTTableViewCell.m
//  LifeBalancer
//
//  Created by fff on 11/11/14.
//  Copyright (c) 2014 Czarto. All rights reserved.
//

#import "UTTableViewCell.h"

@implementation UTTableViewCell
@synthesize radioCheckButton;
-(CCustomButton *)radioCheckButton{
	if (!radioCheckButton) {
		radioCheckButton = [CCustomButton buttonWithType:UIButtonTypeCustom];
	}
	return radioCheckButton;
}
-(void)layoutSubviews{
	[super layoutSubviews];
	
	float inset = 10.0;
	
	CGRect bounds = [[self contentView] bounds];
	
	CGFloat h = bounds.size.height;
	CGFloat w = bounds.size.height;
	
	CGFloat centerHeight = h/2;
	CGFloat centerWidth =  w/2;
	
	[[self contentView]addSubview:self.radioCheckButton];
	
	CGRect imageFrame = CGRectMake(10, 12, 20, 20);
	[self.radioCheckButton setFrame:imageFrame];
	CGPoint centerPoint = CGPointMake(centerWidth, centerHeight);
	[self.radioCheckButton setCenter:centerPoint];
	
	[[self contentView]addSubview:self.textfield];
	
	imageFrame = CGRectMake(inset*4, 0, 280, 44);
	[self.textfield setFrame:imageFrame];
	
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
//checkbox = [[CCustomButton alloc] initWithFrame:CGRectMake(10, 12, 20, 20)];
//[checkbox setBackgroundImage:[UIImage imageNamed:@"radio_checked.png"] forState:UIControlStateNormal];
//[checkbox setBackgroundImage:[UIImage imageNamed:@"radio_unchecked.png"] forState:UIControlStateSelected];
//[checkbox addTarget:self action:@selector(checkboxSelected:) forControlEvents:UIControlEventTouchUpInside];
@end
