//
//  SetReminderViewController.m
//  LifeBalancer
//
//  Created by IgnitionIT Solutions on 4/11/13.
//  Copyright (c) 2013 EFutures. All rights reserved.
//

#import "SetReminderViewController.h"
#import <EventKit/EventKit.h>
#import "Goal.h"
@interface SetReminderViewController ()
{
   NSDateFormatter * dateFormatter;

}
@end

@implementation SetReminderViewController
@synthesize goal,dateField;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];

}
-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setToolbarHidden:NO];
    self.navigationItem.hidesBackButton=YES;
    
    
    UIBarButtonItem *backButton = [[ UIBarButtonItem alloc ] initWithTitle: @"Back"
                                                                     style: UIBarButtonItemStyleBordered
                                                                    target: self
                                                                    action: @selector(back)];
    
    self.toolbarItems = [ NSArray arrayWithObjects: backButton, nil];

    self.navigationItem.title =goal.name;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark -
#pragma mark DateTime Picker


-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    [self createDatePicker];
          
    return NO;
}

-(void)createDatePicker{
    
    if ([self.view viewWithTag:9]) {
        return;
    }
    CGRect toolbarTargetFrame = CGRectMake(0, self.view.bounds.size.height-216-44, 320, 44);
    CGRect datePickerTargetFrame = CGRectMake(0, self.view.bounds.size.height-216, 320, 216);
    
    UIView *darkView = [[UIView alloc] initWithFrame:self.view.bounds];
    darkView.alpha = 0;
    darkView.backgroundColor = [UIColor blackColor];
    darkView.tag = 9;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissDatePicker:)];
    [darkView addGestureRecognizer:tapGesture];
    [self.view addSubview:darkView];
    
    UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height+44, 320, 216)];
    datePicker.tag = 10;
    datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    [datePicker addTarget:self action:@selector(changeDate:) forControlEvents:UIControlEventValueChanged];
    
            
        if(dateField.text == nil || [dateField.text isEqualToString:@""]){
            NSDate *today = [[NSDate alloc] init];
            [datePicker setDate:today animated:YES];
            [datePicker setMinimumDate:[NSDate date]];
        }else{
            NSDate *dateFromString = [[NSDate alloc] init];
            dateFromString = [dateFormatter dateFromString:dateField.text];
            [datePicker setDate:dateFromString animated:YES];
            
           
        
    }
    
    [self.view addSubview:datePicker];
    
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, 320, 44)];
    toolBar.tag = 11;
    toolBar.barStyle = UIBarStyleBlackTranslucent;
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissDatePicker:)];
    [toolBar setItems:[NSArray arrayWithObjects:spacer, doneButton, nil]];
    [self.view addSubview:toolBar];
    
    [UIView beginAnimations:@"MoveIn" context:nil];
    toolBar.frame = toolbarTargetFrame;
    datePicker.frame = datePickerTargetFrame;
    darkView.alpha = 0.5;
    [UIView commitAnimations];
    
    
}

- (void)changeDate:(UIDatePicker *)sender {
    NSString *selectedDate;
    selectedDate =[dateFormatter stringFromDate:[sender date]];
    
        dateField.text = selectedDate;
    
    
}

- (void)removeViews:(id)object {
    [[self.view viewWithTag:9] removeFromSuperview];
    [[self.view viewWithTag:10] removeFromSuperview];
    [[self.view viewWithTag:11] removeFromSuperview];
}

- (void)dismissDatePicker:(id)sender {
    
    NSString *selectedDate;
    
        if(dateField.text == nil || [dateField.text isEqualToString:@""]){
            NSDate *today = [[NSDate alloc] init];
            
            selectedDate =[dateFormatter stringFromDate:today];
            dateField.text = selectedDate;
            }
    
    CGRect toolbarTargetFrame = CGRectMake(0, self.view.bounds.size.height, 320, 44);
    CGRect datePickerTargetFrame = CGRectMake(0, self.view.bounds.size.height+44, 320, 216);
    [UIView beginAnimations:@"MoveOut" context:nil];
    [self.view viewWithTag:9].alpha = 0;
    [self.view viewWithTag:10].frame = datePickerTargetFrame;
    [self.view viewWithTag:11].frame = toolbarTargetFrame;
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(removeViews:)];
    [UIView commitAnimations];
    
    
}



- (IBAction)setReminder:(id)sender {
    
    if (_eventStore == nil)
    {
        _eventStore = [[EKEventStore alloc]init];
        
        [_eventStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error) {
            
            if (!granted)
               [self performSelectorOnMainThread:@selector(showAlert:) withObject:@"You have to provide permission to access Reminder" waitUntilDone:YES];
        }];
    }
    
    if (_eventStore != nil)
        [self createReminder];

}


-(void)createReminder
{
    EKReminder *reminder = [EKReminder
                            reminderWithEventStore:self.eventStore];
    
    reminder.title =@"Text Reminder Event";
  
    reminder.calendar = [_eventStore defaultCalendarForNewReminders];
    
    NSDate *dateFromStringEndDate = [[NSDate alloc] init];
    dateFromStringEndDate = [dateFormatter dateFromString:dateField.text];
    
    
   // EKAlarm *alarm1 = [EKAlarm alarmWithAbsoluteDate:dateFromStringEndDate];
  
    
 //  [reminder addAlarm:alarm1];
    
    NSMutableArray *myAlarmsArray = [[NSMutableArray alloc] init];
    
    EKAlarm *alarm1 = [EKAlarm alarmWithRelativeOffset:-3600]; // 1 Hour
    EKAlarm *alarm2 = [EKAlarm alarmWithRelativeOffset:-86400]; // 1 Day
    
    [myAlarmsArray addObject:alarm1];
    [myAlarmsArray addObject:alarm2];
    
    reminder.alarms = myAlarmsArray;
    NSError *error = nil;
    
    BOOL success =[_eventStore saveReminder:reminder commit:YES error:&error];
    
    
    if (error)
        NSLog(@"error = %@", error);
    
    if(success){
        NSLog(@"ID %@",reminder.calendarItemIdentifier);
    
    }
    
    
    
}

#pragma mark -
#pragma mark Alert

-(void)showAlert:(NSString *)message{
    
    [[[UIAlertView alloc] initWithTitle:@"Reminder" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
    
}


#pragma mark -
#pragma mark Bottum Bar Buttons

-(void)back{
    
    [self.navigationController popViewControllerAnimated:YES];
}
@end
