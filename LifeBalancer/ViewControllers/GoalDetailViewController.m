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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(editDone)];
    self.navigationItem.title = @"Goal Details";
    
    if (goal) {
        self.txtgoalname.text = goal.name;
        
        
       // if (goal.note) {
            txtGoalNote.text = goal.note;
       // }
    }
    txtGoalNote.delegate = self;
    self.txtgoalname.delegate = self;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.tableView addGestureRecognizer:singleTap];
    
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
    
    if (self.txtgoalname.text.length==0) {
        [[[UIAlertView alloc]initWithTitle:nil message:@"Goal name shouldn't be empty" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
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

- (void)textViewDidEndEditing:(UITextView *)textView
{
    self.navigationItem.rightBarButtonItem.title = @"Edit";
}

#pragma mark UITextFieldDelegate


- (void)textFieldDidBeginEditing:(UITextField *)textField{
     self.navigationItem.rightBarButtonItem.title = @"Done";
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
     self.navigationItem.rightBarButtonItem.title = @"Edit";
}

@end
