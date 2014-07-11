//
//  MissionViewController.m
//  LifeBalancer
//
//  Created by Pradeep Kumara on 3/21/13.
//  Copyright (c) 2013 EFutures. All rights reserved.
//

#import "MissionViewController.h"
#import "Mission.h"
#import "DataAdapter.h"

@interface MissionViewController (){
    Mission *mission;
}
@end

@implementation MissionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadData
{
    self.tabBarController.tabBar.hidden = NO;
    mission = [[[[DataAdapter alloc]init]missions] objectAtIndex:0];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.parentViewController.navigationItem.rightBarButtonItem = self.editButtonItem;

    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.parentViewController.navigationItem.title = @"Mission";
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:YES];
    self.tabBarController.tabBar.hidden = NO;
    self.navigationItem.title = @"Mission";
    self.txtmissionstatement.text = mission.statement;
    NSLog(@"selected VC index : %d",self.selectedVcIndex);
    
    [self.tabBarController setSelectedIndex:self.selectedVcIndex];
    self.selectedVcIndex = 0;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [super viewWillDisappear:animated];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    self.title = nil;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.navigationItem setHidesBackButton:editing animated:YES];
    
    if (!editing) {
        [self.txtmissionstatement resignFirstResponder];
		mission.statement = self.txtmissionstatement.text;
		
		NSManagedObjectContext *context = mission.managedObjectContext;
		NSError *error = nil;
		if (![context save:&error]) {
			/*
			 Replace this implementation with code to handle the error appropriately.
			 
			 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
			 */
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
		}
	}
    else
        [self.txtmissionstatement becomeFirstResponder];
}

- (IBAction)goToPrev:(id)sender {
    [self.tabBarController setSelectedIndex:0];
}

- (IBAction)goToNext:(id)sender {
    [self.tabBarController setSelectedIndex:2];
}

#pragma TextView Delegation

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self setEditing:YES animated:YES];
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, 150, 0.0);
    textView.contentInset = contentInsets;
    textView.scrollIndicatorInsets = contentInsets;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self setEditing:NO animated:YES];
    
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    textView.contentInset = contentInsets;
    textView.scrollIndicatorInsets = contentInsets;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
//    if([text isEqualToString:@"\n"]) {
//        [textView resignFirstResponder];
//        return NO;
//    }
    
    [textView scrollRangeToVisible:range];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTxtmissionstatement:nil];
    [super viewDidUnload];
}
@end
