//
//  RoleDetailViewController.m
//  LifeBalancer
//
//  Created by Pradeep Kumara on 3/27/13.
//  Copyright (c) 2013 EFutures. All rights reserved.
//

#import "RoleDetailViewController.h"
#import "DataAdapter.h"
#import "Role.h"

@interface RoleDetailViewController ()

@end

@implementation RoleDetailViewController
@synthesize role,rolesarray;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = @"Role Detail";
    self.txtrolename.text = self.role.name;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)saveclick:(id)sender {
    
    if (self.txtrolename.text.length==0) {
        [[[UIAlertView alloc]initWithTitle:nil message:@"Role name shouldn't be empty" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    
    BOOL exist = NO;
    
    for (Role *roleobj in rolesarray) {
        if ([roleobj.name isEqualToString:self.txtrolename.text]) {
            exist = YES;
            break;
        }
    }
    
    if (!exist) {
        if (!role) {
            role = [[[DataAdapter alloc] init] getemptyrole];
        }
        
        role.name = self.txtrolename.text;
        NSError *error = nil;
        if (![role.managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    else
    {
       // [[[UIAlertView alloc]initWithTitle:nil message:@"Role already exists" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
	
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidUnload {
    [self setTxtrolename:nil];
    rolesarray = nil;
    role = nil;
    [super viewDidUnload];
}
@end
