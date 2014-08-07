//
//  Role+Cutomable.m
//  LifeBalancer
//
//  Created by Pradeep Kumara on 3/29/13.
//  Copyright (c) 2013 EFutures. All rights reserved.
//

#import "Role+Cutomable.h"

@implementation Role (Cutomable)
-(NSArray *)getGoalsByPriority
{
    NSSortDescriptor *prioritySort = [NSSortDescriptor sortDescriptorWithKey:@"priority" ascending:YES];
    return [[self.goals allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:prioritySort]];
}
@end
