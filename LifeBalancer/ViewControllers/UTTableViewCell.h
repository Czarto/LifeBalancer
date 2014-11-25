//
//  UTTableViewCell.h
//  LifeBalancer
//
//  Created by fff on 11/11/14.
//  Copyright (c) 2014 Czarto. All rights reserved.
//

#import "UMTableViewCell.h"
#import "CCustomButton.h"
#import "customtextfield.h"

@interface UTTableViewCell : UMTableViewCell
@property (strong, nonatomic) IBOutlet CCustomButton *radioCheckButton;
@property (strong, nonatomic) IBOutlet customtextfield *textfield;
@end
