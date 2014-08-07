//
//  WeeklyPlaningViewController.m
//  LifeBalancer
//
//  Created by IgnitionIT Solutions on 4/2/13.
//  Copyright (c) 2013 EFutures. All rights reserved.
//

#import "WeeklyPlaningViewController.h"
#import "DataAdapter.h"
#import "SetPrioritiesViewController.h"
@interface WeeklyPlaningViewController ()

@end

@implementation WeeklyPlaningViewController
@synthesize resumeButtton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated{
    
[self.navigationController setToolbarHidden:NO];
 self.navigationItem.hidesBackButton=YES;
 
    UIBarButtonItem *backButton = [[ UIBarButtonItem alloc ] initWithTitle: @"Back"
                                                                     style: UIBarButtonItemStyleBordered
                                                                    target: self
                                                                    action: @selector(back)];
    
    self.toolbarItems = [ NSArray arrayWithObjects: backButton, nil];
    
      
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
     
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)checkforSelectedGoals{
    DataAdapter *da = [[DataAdapter alloc]init];
    NSMutableArray *availablearray = [NSMutableArray arrayWithArray:[da checkforTask]];
    if(availablearray.count >0){
        return YES;
    }else{
        return NO;
    }
}
#pragma mark -
#pragma mark Action Buttons

- (IBAction)resume:(id)sender {
    

    SetPrioritiesViewController *setPrioritiesViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SetPriorities"];
    [self.navigationController pushViewController:setPrioritiesViewController animated:YES];
    

}

- (IBAction)reset:(id)sender {
    
   
  if([self checkforSelectedGoals]){
    
        
      [[[UIAlertView alloc]initWithTitle:@"Confirmation"
                                 message:@"Do you want to reset week plan ?"
                         completionBlock:^(NSUInteger buttonIndex, UIAlertView *alertView) {
                             if (buttonIndex == 1) {
                                      
                                 BOOL permission = YES;
                                 
                                 permission = [[[DataAdapter alloc]init]resetPriorities];
                                 
                                 if(permission){
                                     [[[DataAdapter alloc]init]reset];
                                     SetPrioritiesViewController *setPrioritiesViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SetPriorities"];
                                     [self.navigationController pushViewController:setPrioritiesViewController animated:YES];
                                     
                                     
                                 }
  
            
                             }
                         }
                       cancelButtonTitle:@"NO"
                       otherButtonTitles:@"YES",nil] show];
      
   
    }else{
    
 
            SetPrioritiesViewController *setPrioritiesViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SetPriorities"];
            [self.navigationController pushViewController:setPrioritiesViewController animated:YES];
 
        
    }
    
    
        
    
    
    
    
   }


#pragma mark -
#pragma mark Buttom Bar Buttons

-(void)back{
    
    [self.navigationController popViewControllerAnimated:YES];
}


@end
