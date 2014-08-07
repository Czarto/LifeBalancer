//
//  HomeTempViewController.m
//  LifeBalancer
//
//  Created by Rukshan Marapana on 8/1/13.
//  Copyright (c) 2013 EFutures. All rights reserved.
//

#import "HomeTempViewController.h"

@interface HomeTempViewController ()

@end

@implementation HomeTempViewController

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
   // [self.navigationController popToRootViewControllerAnimated:YES];
	// Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.selectedVcIndex==0) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else{
    [self.tabBarController setSelectedIndex:self.selectedVcIndex];
        self.selectedVcIndex =0;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
