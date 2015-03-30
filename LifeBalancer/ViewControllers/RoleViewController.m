//
//  RoleViewController.m
//  LifeBalancer
//
//  Created by Pradeep Kumara on 3/22/13.
//  Copyright (c) 2013 EFutures. All rights reserved.
//

#import "RoleViewController.h"
#import "RoleDetailViewController.h"
#import "DataAdapter.h"
#import "Role.h"
#import "customtextfield.h"

@interface RoleViewController () {
	NSMutableArray *rolesarray;
	Role *role;
	BOOL isDeleted;
}

@end

@implementation RoleViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self editHidenRole];
	isDeleted = NO;
	self.tabBarController.tabBar.hidden = NO;
	self.parentViewController.navigationItem.rightBarButtonItem = self.editButtonItem;
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Home" style:UIBarButtonItemStyleBordered target:self action:@selector(goToHome)];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"SomethingChanged" object:nil];
}

-(void)textFieldDidBeginEditing:(customtextfield *)textField{
	[self setEditing:YES];
	[self.tableView setEditing:NO];
	
	if ([UIScreen mainScreen].bounds.size.height>480) {
		if ([self.tableView cellForRowAtIndexPath:textField.indexPath].frame.origin.y > 216) {
			[self.tableView setContentOffset:CGPointMake(0, [self.tableView cellForRowAtIndexPath:textField.indexPath].frame.origin.y - 216)];
		}
	}else{
		if ([self.tableView cellForRowAtIndexPath:textField.indexPath].frame.origin.y > 128) {
			[self.tableView setContentOffset:CGPointMake(0, [self.tableView cellForRowAtIndexPath:textField.indexPath].frame.origin.y - 128)];
		}
	}
	for (Role *roleobj in rolesarray) {
		if ([roleobj.name isEqualToString:textField.text]) {
			self->role = roleobj;
		}
	}
}

-(BOOL)textField:(customtextfield *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	return YES;
}

-(void)textFieldDidEndEditing:(customtextfield *)textField{
	NSLog(@"%@",textField.text);
	NSLog(@"%d",(int)textField.tag);
	[self save:textField];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	[self setEditing:NO animated:YES];
	return YES;
}

-(void)save:(customtextfield*)textfield{
	if (textfield.text.length==0) {
		return;
	}
	
	BOOL exist = NO;
	for (Role *roleobj in rolesarray) {
		if ([roleobj.name isEqualToString:textfield.text]) {
			exist = YES;
			break;
		}
	}
	if(isDeleted) {
		exist = YES;
		isDeleted = NO;
	}
	if (!exist) {
		if (!role) {
			role = [[[DataAdapter alloc] init] getemptyrole];
		}
		role.name = textfield.text;
		role.sortID = @(rolesarray.count + 4);
		NSError *error = nil;
		if (![role.managedObjectContext save:&error]) {
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
		}
		[self loadroles];
		role = nil;
	}
}

-(void)refreshData
{
	[self loadroles];
	if (!self.editing) {
		
		if (roleCount<1) {
			[self.tableView setEditing:YES animated:YES];
			[self setEditing:YES];
		}
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	
	self.parentViewController.navigationItem.title = @"Roles";
	self.parentViewController.navigationItem.rightBarButtonItem = self.editButtonItem;
	self.tabBarController.tabBar.hidden = NO;
	[self.tabBarController setSelectedIndex:1];
	[super viewWillAppear:animated];
	self.navigationItem.title = @"Roles";
	[self loadroles];
	
	NSLog(@"Role count : %d",roleCount);
	
	if (!self.editing) {
		
		if (roleCount<1) {
			[self.tableView setEditing:YES animated:YES];
			[self setEditing:YES];
		}
		
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:@"SomethingChanged" object:nil];
	
}

-(void)editHidenRole{
	
	
}

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self.tableView setEditing: YES animated: YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	self.title = nil;
}

- (void)loadroles
{
	//rolesarray
	rolesarray = [[NSMutableArray alloc]init];
	NSArray *originalArray = [[[DataAdapter alloc]init] customRoles];
	
	for (Role *role_ in originalArray) {
		
		if ([role_.name isEqualToString:@"Physical"] ||[role_.name isEqualToString:@"Spiritual"]||[role_.name isEqualToString:@"Mental"]||[role_.name isEqualToString:@"Social"]) {
			// default values
			NSLog(@"Role Name %@", role_.name);
			//[rolesarray addObject:role_];
		}
		else{
			NSLog(@"Role Name %@", role_.name);
			[rolesarray addObject:role_];
		}
		roleCount = (int)rolesarray.count;
	}
	[self.tableView reloadData];
}

- (void)goToHome
{
	[self.tabBarController setSelectedIndex:0];
}

- (IBAction)goToPrev:(id)sender {
	[self.tabBarController setSelectedIndex:1];
}

- (IBAction)goToNext:(id)sender {
	[self.tabBarController setSelectedIndex:3];
}
#pragma mark -
#pragma mark Editing

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
	
	[self.navigationItem setHidesBackButton:editing animated:YES];
	[self.tableView setEditing:editing animated:animated];
	
	if(!editing) {
		[self updateRolesSortID];
		for(int i=0; i<rolesarray.count; i++) {
			Role *objRole = [rolesarray objectAtIndex:i];
			if(objRole.hasChanges) {
				[objRole didSave];
			}
		}
		Role *saveRole = rolesarray.firstObject;
		NSError *error;
		[saveRole.managedObjectContext save:&error];
		if(error) {
			NSLog(@"Error %@", error);
		}
		
		[self.tableView reloadData];
		role = nil;
	}
}

- (void)updateRolesSortID {
	for(int i = 0; i < rolesarray.count; i++) {
		Role *srole = rolesarray[i];
		if([srole.sortID integerValue] != i+4)
			srole.sortID = @(i+4);
	}
}

#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger rows = 0;
	rows = [rolesarray count];
	NSLog(@"count : %d",(int)rows);
	return rows+1;
}
-(void)deleteLastText{
	[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[rolesarray count]-1 inSection:0]].contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UITableViewCell *rolecell = [tableView dequeueReusableCellWithIdentifier:@"RoleCell"];
	NSUInteger rolescount = [rolesarray count];
	customtextfield *textField = [[customtextfield alloc] initWithFrame:CGRectMake(20, 0, 280, rolecell.frame.size.height)];
	
	if (indexPath.row < rolescount) {
		for(UIView *subview in rolecell.contentView.subviews)
		{
			if([subview isKindOfClass: [UITextField class]])
			{
				[subview removeFromSuperview];
			}
		}
		
		[rolecell.contentView addSubview:textField];
		textField.text = [[rolesarray objectAtIndex:indexPath.row]name];
		textField.indexPath = indexPath;
		textField.delegate = self;
	} else {
		
		for(UIView *subview in rolecell.contentView.subviews)
		{
			if([subview isKindOfClass: [UITextField class]])
			{
				[subview removeFromSuperview];
			}
		}
		
		[rolecell.contentView addSubview:textField];
		textField.text =  @"";
		textField.indexPath = indexPath;
		textField.delegate = self;
		
	}
	textField.indexPath = indexPath;
	rolecell.accessoryType = UITableViewCellAccessoryNone; //DisclosureIndicator;
	rolecell.tag = indexPath.row;
	return rolecell;
}

#pragma mark -
#pragma mark Editing rows

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSIndexPath *rowToSelect = indexPath;
	
	if (/*!self.isEditing*/NO) {
		rowToSelect = nil;
	}else if (indexPath.row < [rolesarray count]) {
		//Role *role = [rolesarray objectAtIndex:indexPath.row];
		
		// if (!role.custom.boolValue) {
		//rowToSelect = nil;
		// }
	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	return rowToSelect;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	[self selectRowAtIndexPath:indexPath];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UITableViewCellEditingStyle style = UITableViewCellEditingStyleNone;
	
	if (indexPath.row < [rolesarray count]) {
		style = UITableViewCellEditingStyleDelete;
	} else if(indexPath.row == [rolesarray count]){
		style = UITableViewCellEditingStyleNone;
	}
	
	
	return style;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		BOOL permission = YES;
		if (indexPath.row < [rolesarray count]) {
			Role *role_ = [rolesarray objectAtIndex:indexPath.row];
			DataAdapter *db = [[DataAdapter alloc]init];
			NSMutableArray *goalsarray = [NSMutableArray arrayWithArray:[db tasksSavedInTheCalender:[role_ objectID]]];
			if(goalsarray.count>0) {
				permission = [[[DataAdapter alloc]init]deleteCalenderEvents:role_.objectID];
			}
			if(permission){
				[role_.managedObjectContext deleteObject:role_];
				[rolesarray removeObject:role_];
				[self deleteLastText];
				NSLog(@"%@",role_);
				// Save the context.
				NSError *error;
				if (![role_.managedObjectContext save:&error]) {
					NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
					abort();
				}
				//isDeleted = YES;
				role_ = nil;
				
			}
			[self loadroles];
		}
	}
	
}
- (void)refreshOrders {
	for(int i=0; i<rolesarray.count; i++) {
		
		Role *objRole = [rolesarray objectAtIndex:i];
		if(objRole.hasChanges) {
			[objRole didSave];
		}
	}
}

- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self refreshData];
	[self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
	if((sourceIndexPath.row != rolesarray.count) && (destinationIndexPath.row != rolesarray.count)) {
		Role *roleMove = [rolesarray objectAtIndex:sourceIndexPath.row];
		[rolesarray removeObjectAtIndex:sourceIndexPath.row];
		[rolesarray insertObject:roleMove atIndex:destinationIndexPath.row];
	}
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger rolesCount = [rolesarray count];
	if (indexPath.row < rolesCount)
		return YES;
	
	return NO;
}

- (void)viewDidUnload {
	[self setTableView:nil];
	[super viewDidUnload];
}

@end
