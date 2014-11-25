//
//  SetPrioritiesViewController.m
//  LifeBalancer
//
//  Created by IgnitionIT Solutions on 4/13/13.
//  Copyright (c) 2013 EFutures. All rights reserved.
//

#import "SetPrioritiesViewController.h"
#import "SchedulePrioritiesViewController.h"
#import "DataAdapter.h"
#import "Role.h"
#import "Task.h"
#import "Config.h"
#import "SetPrioritiesDetailViewController.h"
#import "GoalViewController.h"
#import "GoalDetailViewController.h"
#import "UTTableViewCell.h"
#import "CCustomButton.h"
#import "GoalTempViewController.h"

@interface SetPrioritiesViewController ()<UITabBarDelegate, UITextFieldDelegate>
{
	NSArray *rolesarray;
	SetPrioritiesDetailViewController *nextViewController;
	customtextfield *currenttextField;
}
@property Task* task;
@end

@implementation SetPrioritiesViewController
@synthesize deletedIndexPath;
@synthesize task;
//- (id)initWithStyle:(UITableViewStyle)style
//{
//    self = [super initWithStyle:style];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)viewDidLoad
{
	
	[super viewDidLoad];
	self.tabBar.delegate = self;
	[self.tabBar setSelectedItem:self.tabBarItem1];
	self.navigationItem.hidesBackButton=NO;
 	[self.navigationController setToolbarHidden:YES];
	self.parentViewController.navigationItem.rightBarButtonItem = nil;
	[self setEditing:YES animated:YES];
	self.view.backgroundColor = [UIColor whiteColor];
	// Do any additional setup after loading the view, typically from a nib.
	
}
-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	self.parentViewController.navigationItem.rightBarButtonItem = nil;
	
}
-(void)didSelectedRadioButton:(QRadioButton *)radio groupId:(NSString *)groupId{
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:(NSIndexPath*)groupId];
	cell.Selected = true;
	cell.backgroundColor = [UIColor whiteColor];
	
}

-(void)didUnSelectedRadioButton:(QRadioButton *)radio groupId:(NSString *)groupId{
	
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:(NSIndexPath*)groupId];
	cell.Selected = false;
	cell.backgroundColor = [UIColor whiteColor];
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

-(void)checkboxSelected:(id)sender{
	CCustomButton* checkboxq = (CCustomButton*)sender;
		if([checkboxq isSelected]==YES)
	{
		[checkboxq setSelected:NO];
		[self.tableView cellForRowAtIndexPath:checkboxq.indexPath].backgroundColor = [UIColor whiteColor];

	}
	else{
		[checkboxq setSelected:YES];
		[self.tableView cellForRowAtIndexPath:checkboxq.indexPath].backgroundColor = [UIColor whiteColor];
	}
    Role *role = rolesarray[checkboxq.indexPath.section];
	NSSet *taskset = role.tasks;

	customtextfield *textField = (customtextfield*)[[self.tableView cellForRowAtIndexPath:checkboxq.indexPath].contentView viewWithTag:(NSInteger)checkboxq.indexPath+3];
	NSLog(@"%ld",(long)textField.tag);
	NSLog(@"%@",textField.text);
	for (Task *tasktemp in taskset) {
		if([tasktemp.name isEqualToString:textField.text])
		{
			self.task = tasktemp;
		}
	}
//-	[[self.tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryDetailButton];
	
	[[self.tableView cellForRowAtIndexPath:checkboxq.indexPath].contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
	
	if (!role) {
		return;
	}
	
	if (YES) {
		NSManagedObjectContext *context = role.managedObjectContext;
		
		if (!task) {
			task = [NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:context];
			task.priority = [NSNumber numberWithInteger:checkboxq.indexPath.row];//[role.goals count]//--------------------------
			[role addTasksObject:task];
		}
		task.name = textField.text;
	
	//	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		if (checkboxq.isSelected == YES) {
			task.isDone = [NSNumber numberWithInt:1];
			//task.calendarId = (NSString*)gregorian;
			[checkboxq setSelected:NO];
		}else{
			task.isDone = 0;
			//task.calendarId = nil;
			[checkboxq setSelected:YES];
		}
		//goal.note = txtGoalNote.text;
		NSError *error = nil;
		if (![context save:&error]) {
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
		}
		[[self.tableView cellForRowAtIndexPath:checkboxq.indexPath] setAccessoryType:UITableViewCellAccessoryNone];
		[[self.tableView cellForRowAtIndexPath:checkboxq.indexPath].contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
		
		self->task = nil;
		[self.tableView reloadData];
	}
	[self viewWillAppear:NO];
 /**/
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self.parentViewController.navigationItem.title = @"Set Priorities";
	
	//Create bar buttons
	
	//    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle: @"Home"
	//                                                                   style: UIBarButtonItemStyleBordered
	//                                                                  target: self
	//                                                                  action: @selector(back)];

	// self.toolbarItems = [ NSArray arrayWithObjects: backButton,flexibleSpace,nextButton,nil];
	//    self.navigationItem.leftBarButtonItem = backButton;
	[self loadroles];
	if (!self.editing) {
		
		if (self.shouldBePresentedInEditMode)
		{
			
			[self.tableView setEditing:YES animated:YES];
			[self setEditing:YES];
			
		}
	}
	
}


-(void)viewWillDisappear:(BOOL)animated
{
	self.parentViewController.navigationItem.title = @"Goal";
	[super viewWillDisappear:animated];
	
//	[self.tabBar setSelectedItem:nil];
	//[self.navigationController popToRootViewControllerAnimated:YES];
	
}

- (void)loadroles
{
	
	rolesarray = [[[DataAdapter alloc]init]roles];
	
	[self.tableView reloadData];
	
	
	//if([self checkforSelectedGoals]){
		
	//	[[self.toolbarItems objectAtIndex: 2] setEnabled:(YES)];
		
//	}else{
		
		[[self.toolbarItems objectAtIndex: 2] setEnabled:(NO)];
		
//	}
	
}
#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	self.parentViewController.navigationItem.rightBarButtonItem = nil;
	return YES;
}
-(BOOL)textField:(customtextfield *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	return YES;
}
- (void)textFieldDidBeginEditing:(customtextfield *)textField{

	self.parentViewController.navigationItem.rightBarButtonItem = self.editButtonItem;

	if ([UIScreen mainScreen].bounds.size.height>480) {
		if ([self.tableView cellForRowAtIndexPath:textField.indexPath].frame.origin.y > 216) {
			[self.tableView setContentOffset:CGPointMake(0, [self.tableView cellForRowAtIndexPath:textField.indexPath].frame.origin.y - 216)];
		}
	}else{
		if ([self.tableView cellForRowAtIndexPath:textField.indexPath].frame.origin.y > 128) {
			[self.tableView setContentOffset:CGPointMake(0, [self.tableView cellForRowAtIndexPath:textField.indexPath].frame.origin.y - 128)];
		}
	}
	self.navigationItem.rightBarButtonItem.title = @"Done";
	customtextfield* atextField = (customtextfield*)textField;
	currenttextField = atextField;
	NSIndexPath *indexPath = atextField.indexPath;
	
	Role *role = rolesarray[indexPath.section];
	NSSet *taskset = role.tasks;
	for (Task *tasktemp in taskset) {
		if([tasktemp.name isEqualToString:textField.text])
		{
			self->task = tasktemp;
		}
	}
	[[self.tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryNone];
}
-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
	nextViewController = nil;
	
	nextViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GoalDetailViewController"];
	//nextViewController.goalVC = self;
	//nextViewController.currentIndexPath = indexPath;
	
	self.deletedIndexPath = nil;
	
	Role *role = rolesarray[indexPath.section];
	nextViewController.role = role;
	DataAdapter *da = [[DataAdapter alloc]init];
	NSMutableArray *tasksarray = [NSMutableArray arrayWithArray:[da getTasksByPriority:role.objectID]];
	
	if (indexPath.row < role.tasks.count) {
		nextViewController.task = [tasksarray objectAtIndex:indexPath.row];
	}
	
	if (nextViewController) {
		self.navigationController.navigationBar.backItem.title = @"Back";
		[self.navigationController pushViewController:nextViewController animated:YES];
	}
	
	
}//tableView:accessoryButtonTappedForRowWithIndexPath:

-(void)textFieldDidEndEditing:(UITextField *)textField{
	
	customtextfield* atextField = (customtextfield*)textField;
	NSIndexPath *indexPath = atextField.indexPath;
	[[self.tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryNone];
	//[[self.tableView cellForRowAtIndexPath:indexPath].contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
	[self.tableView reloadData];
	self.navigationItem.rightBarButtonItem.title = @"Edit";
	if (textField.text.length==0) {
		//[[[UIAlertView alloc]initWithTitle:nil message:@"Goal name shouldn't be empty" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
		return;
	}
	
	BOOL exist = NO;
	Role *role = rolesarray[indexPath.section];
	
	NSSet *taskset = role.tasks;
	for (Task *taskobj in taskset) {
		if ([taskobj.name isEqualToString:textField.text]) {
			exist = YES;
			break;
		}
	}
	
	if (!role) {
		return;
	}
	
	if (exist) {
		return;
	}
	NSManagedObjectContext *context = role.managedObjectContext;
	
	if (!task) {
		task = [NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:context];
		task.priority = [NSNumber numberWithInteger:indexPath.row];//[role.goals count]//--------------------------
		[role addTasksObject:task];
	}
	
	task.name = textField.text;
	//goal.note = txtGoalNote.text;
	
	NSError *error = nil;
	if (![context save:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
	[[self.tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryNone];
	self->task = nil;
	[self.tableView reloadData];
	
}


- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark Editing

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	
	[super setEditing:editing animated:animated];
	
	//[self.tableView beginUpdates];
	
	for (int rolecount=0; rolecount < rolesarray.count; rolecount++) {
		Role *role = rolesarray[rolecount];
		if (role.tasks.count < ADD_TASK_MAX_LIMIT) {
			NSArray *rolesInsertIndexPath = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:[role.tasks count] inSection:rolecount]];
			if (editing) {
				[self.tableView insertRowsAtIndexPaths:rolesInsertIndexPath withRowAnimation:UITableViewRowAnimationTop];
				
				[self.tableView endEditing:YES];

			} else
			{
				if ([self.parentViewController.navigationItem.title isEqualToString:@"Goal"]) {
					
					
					
				}else{
					[self textFieldDidEndEditing:self->currenttextField];
					//[self.tableView deleteRowsAtIndexPaths:rolesInsertIndexPath withRowAnimation:UITableViewRowAnimationTop];
					[super setEditing:YES animated:YES];
					[self.tableView reloadData];
				}
				
			}
			
		}
	}
	self.parentViewController.navigationItem.rightBarButtonItem = nil;
	//[self.tableView endUpdates];
}




#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return rolesarray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSInteger rows = 0;
	Role *role = rolesarray[section];
	
	rows = [role.tasks count];
	if (self.editing && rows < ADD_TASK_MAX_LIMIT) {
		rows++;
	}
	
	
	
	return rows;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	Role *role = rolesarray[section];
	return role.name;
}
- (NSArray *)rightButtons
{
	NSMutableArray *rightUtilityButtons = [NSMutableArray new];
//	[rightUtilityButtons sw_addUtilityButtonWithColor:
//	 [UIColor colorWithRed:0.2f green:0.4f blue:0.9f alpha:1.0]
//												title:@"More"];
	[rightUtilityButtons sw_addUtilityButtonWithColor:
	 [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
												title:@"Delete"];
	
	return rightUtilityButtons;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

	NSInteger rows = 0;
	UTTableViewCell *rolecell = [tableView dequeueReusableCellWithIdentifier:@"SetPriorityCell"];
	if (rolecell != nil) {
		
	}
	rolecell.textfield = [[customtextfield alloc] initWithFrame:CGRectMake(40, 0, 280, rolecell.frame.size.height)];
	Role *role = rolesarray[indexPath.section];
	[rolecell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
	
	rolecell.textfield.tag = (NSInteger)indexPath + 3;
	NSLog(@"%ld", (long)rolecell.textfield.tag);
	
	rolecell.textfield.indexPath = indexPath;
	rolecell.textfield.delegate = self;
    rolecell.delegate = self;

	rows = [role.tasks count];
	if (rows>=4) {
		self.isPink = YES;
	}
	else{
		self.isPink = NO;
	}
	DataAdapter *da = [[DataAdapter alloc]init];
	
	if (indexPath.row < role.tasks.count) {
		
		NSMutableArray *tasksarray = [NSMutableArray arrayWithArray:[da getTasksByPriority:role.objectID]];
		
		Task *task_l = [tasksarray objectAtIndex:indexPath.row];
		
		rolecell.textfield.text = task_l.name;
		
		rolecell.radioCheckButton = [[CCustomButton alloc]initWithFrame:CGRectMake(10, 12, 20, 20)];
		[rolecell.radioCheckButton setBackgroundImage:[UIImage imageNamed:@"radio_checked.png"] forState:UIControlStateNormal];
		[rolecell.radioCheckButton setBackgroundImage:[UIImage imageNamed:@"radio_unchecked.png"] forState:UIControlStateSelected];
		[rolecell.radioCheckButton addTarget:self action:@selector(checkboxSelected:) forControlEvents:UIControlEventTouchUpInside];
		
		if (task_l.isDone != 0) {
			rolecell.radioCheckButton.selected = YES;
			rolecell.backgroundColor = [UIColor whiteColor];
		}else{
			rolecell.radioCheckButton.selected = NO;
			rolecell.backgroundColor = [UIColor whiteColor];
			rolecell.textfield.textColor = [UIColor lightGrayColor];
		}
		rolecell.radioCheckButton.indexPath = indexPath;
		[rolecell setRightUtilityButtons:[self rightButtons] WithButtonWidth:58.0f];
	} else {
		rolecell.radioCheckButton = [[CCustomButton alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
		rolecell.selected = 0;
		rolecell.backgroundColor = [UIColor whiteColor];
		rolecell.textfield.text = @"";
	}
	return rolecell;
}



- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSIndexPath *rowToSelect = indexPath;
	BOOL isEditing = self.editing;
	
	if (!isEditing) {
		rowToSelect = nil;
	}
	
	return rowToSelect;
}
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
	//[self textFieldDidEndEditing:currenttextField];
	switch (index) {
		case 0:
		{
			NSLog(@"Delete button was pressed");
			[self.tableView endEditing:YES];
			NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
			
			self->deletedIndexPath = cellIndexPath;
			
			if (self->deletedIndexPath) {
				NSLog(@"should delete %@",self->deletedIndexPath);
				deleteWithoutConfirmation = YES;
				[self tableView:self.tableView commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:cellIndexPath];
			}
			//[self.tableView deleteRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
			break;
		}
		default:
			break;
	}
	[self viewDidLayoutSubviews];
}
- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
	// allow just one cell's utility button to be open at once
	return YES;
}
- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state
{
	switch (state) {
		case 1:
			// set to NO to disable all left utility buttons appearing
			return YES;
			break;
		case 2:
			// set to NO to disable all right utility buttons appearing
			return YES;
			break;
		default:
			break;
	}
	
	return YES;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	CCustomButton* checkboxq = (CCustomButton*)[[self.tableView cellForRowAtIndexPath:indexPath].contentView.subviews objectAtIndex:0] ;
	if([checkboxq isSelected]==YES)
	{
		[checkboxq setSelected:NO];
		[self.tableView cellForRowAtIndexPath:checkboxq.indexPath].backgroundColor = [UIColor whiteColor];
		
	}
	else{
		[checkboxq setSelected:YES];
		[self.tableView cellForRowAtIndexPath:checkboxq.indexPath].backgroundColor = [UIColor whiteColor];
	}
	Role *role = rolesarray[checkboxq.indexPath.section];
	NSSet *taskset = role.tasks;
	
	
 
	
	customtextfield *textField = (customtextfield*)[[self.tableView cellForRowAtIndexPath:checkboxq.indexPath].contentView viewWithTag:(NSInteger)checkboxq.indexPath+3];
	NSLog(@"%ld",(long)textField.tag);
	NSLog(@"%@",textField.text);
	for (Task *tasktemp in taskset) {
		if([tasktemp.name isEqualToString:textField.text])
		{
			self.task = tasktemp;
		}
	}
	//-	[[self.tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryDetailButton];
	
	[[self.tableView cellForRowAtIndexPath:checkboxq.indexPath].contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
	
	
	if (!role) {
		return;
	}
	
	if (YES) {
		NSManagedObjectContext *context = role.managedObjectContext;
		
		if (!task) {
			task = [NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:context];
			task.priority = [NSNumber numberWithInteger:checkboxq.indexPath.row];//[role.goals count]//--------------------------
			[role addTasksObject:task];
		}
		task.name = textField.text;
		
		//	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		if (checkboxq.isSelected == YES) {
			task.isDone = [NSNumber numberWithInt:1];
			//task.calendarId = (NSString*)gregorian;
			[checkboxq setSelected:NO];
		}else{
			task.isDone = 0;
			//task.calendarId = nil;
			[checkboxq setSelected:YES];
		}
		//goal.note = txtGoalNote.text;
		NSError *error = nil;
		if (![context save:&error]) {
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
		}
		[[self.tableView cellForRowAtIndexPath:checkboxq.indexPath] setAccessoryType:UITableViewCellAccessoryNone];
		[[self.tableView cellForRowAtIndexPath:checkboxq.indexPath].contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
		
		self->task = nil;
		[self.tableView reloadData];
	}
	[self viewWillAppear:NO];
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCellEditingStyle style = UITableViewCellEditingStyleNone;
	Role *role = rolesarray[indexPath.section];
	if (indexPath.row < role.tasks.count) {
		// Detemine if it's in editing mode
		if (self.editing){
			style = UITableViewCellEditingStyleDelete;
		}
	} else {
		
	}
	return style;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (deleteWithoutConfirmation) {
		//
		Role *role = rolesarray[indexPath.section];
		DataAdapter *da = [[DataAdapter alloc]init];
		NSMutableArray *tasksarray = [NSMutableArray arrayWithArray:[da getTasksByPriority:role.objectID]];
		//Task *task = [tasksarray objectAtIndex:indexPath.row];
		
		deleteWithoutConfirmation = NO;
		if (editingStyle == UITableViewCellEditingStyleDelete) {
			Role *role = rolesarray[indexPath.section];
			
			if (indexPath.row < role.tasks.count) {
				
				Task *selectedTask = [tasksarray objectAtIndex:indexPath.row];
				
				[role removeTasksObject:selectedTask];
				[selectedTask.managedObjectContext deleteObject:selectedTask];
				
				[tasksarray removeObjectAtIndex:indexPath.row];
				
				for (int order=0; order<tasksarray.count; order++) {
					Task *task_l = [tasksarray objectAtIndex:order];
					task_l.priority = [NSNumber numberWithInt:order];
				}
				
				// Save the context.
				NSError *error;
				if (![role.managedObjectContext save:&error]) {
					
					NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
					abort();
				}
				
				[self loadroles];
			}
			
			
			
		}
		else if (editingStyle == UITableViewCellEditingStyleInsert) {
			[self tableView:tableView didSelectRowAtIndexPath:indexPath];
		}
		
	}
	else
	{
		
		
		if (editingStyle == UITableViewCellEditingStyleDelete) {
			
			//		BOOL permission = YES;
			//			if (indexPath.row < [rolesarray count]) {
			//				Role *role = [rolesarray objectAtIndex:indexPath.row];
			//				DataAdapter *db = [[DataAdapter alloc]init];
			//				NSMutableArray *goalsarray = [NSMutableArray arrayWithArray:[db tasksSavedInTheCalender:[role objectID]]];
			//				if(goalsarray.count>0) {
			//					permission = [[[DataAdapter alloc]init]deleteCalenderEvents:role.objectID];
			//				}
			//				if(permission){
			//					[goal.managedObjectContext deleteObject:goal];
			//					// Save the context.
			//					NSError *error;
			//					if (![role.managedObjectContext save:&error]) {
			//						NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			//						abort();
			//					}
			//				}
			//				[self loadroles];
			//			}
			//
			//
		}
		else if (editingStyle == UITableViewCellEditingStyleInsert) {
			[self tableView:tableView didSelectRowAtIndexPath:indexPath];
		}
		
		
		
	}
//	if (editingStyle == UITableViewCellEditingStyleDelete) {
//		
//		
//		[[[UIAlertView alloc]initWithTitle:@"Confirmation"
//								   message:@"Do you want to delete ?"
//						   completionBlock:^(NSUInteger buttonIndex, UIAlertView *alertView) {
//							   if (buttonIndex == 1) {
//								   BOOL permission = YES;
//								   Role *role = rolesarray[indexPath.section];
//								   DataAdapter *da = [[DataAdapter alloc]init];
//								   
//								   if (indexPath.row < role.tasks.count) {
//									   NSMutableArray *tasksarray = [NSMutableArray arrayWithArray:[da getTasksByPriority:role.objectID]];
//									   
//									   Task * selectedTask = [tasksarray objectAtIndex:indexPath.row];
//									   
//									   if(selectedTask.calendarId != nil &&![selectedTask.calendarId isEqualToString:@""]) {
//										   
//										   permission = [[[DataAdapter alloc]init]deleteCalenderEvent:selectedTask];
//									   }
//									   
//									   if(permission){
//										   
//										   
//										   [role removeTasksObject:selectedTask];
//										   [selectedTask.managedObjectContext deleteObject:selectedTask];
//										   
//										   [tasksarray removeObjectAtIndex:indexPath.row];
//										   
//										   for (int order=0; order<tasksarray.count; order++) {
//											   Task *task = [tasksarray objectAtIndex:order];
//											   task.priority = [NSNumber numberWithInt:order];
//										   }
//										   
//										   // Save the context.
//										   NSError *error;
//										   if (![role.managedObjectContext save:&error]) {
//											   
//											   NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//											   abort();
//										   }
//									   }
//									   [self loadroles];
//								   }
//							   }
//						   }
//						 cancelButtonTitle:@"NO"
//						 otherButtonTitles:@"YES",nil] show];
//		
//		
//		
//		
//	}
//	else if (editingStyle == UITableViewCellEditingStyleInsert) {
//		[self tableView:tableView didSelectRowAtIndexPath:indexPath];
//	}
}



#pragma mark -
#pragma mark Moving rows
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
	return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	BOOL canMove = NO;
	Role *role = rolesarray[indexPath.section];
	canMove = indexPath.row != [role.tasks count];
	return canMove;
}


- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
	NSIndexPath *target = proposedDestinationIndexPath;
	NSIndexPath *source = sourceIndexPath;
	
	Role *role = rolesarray[source.section];
	
	if (target.section < source.section) {
		target = [NSIndexPath indexPathForRow:0 inSection:source.section];
	} else if (target.section > source.section) {
		target = [NSIndexPath indexPathForRow:([role.tasks count] - 1) inSection:source.section];
	} else {
		NSUInteger ingredientsCount_1 = [role.tasks count] - 1;
		
		if (target.row > ingredientsCount_1) {
			target = [NSIndexPath indexPathForRow:ingredientsCount_1 inSection:source.section];
		}
	}
	
	return target;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	
	if (fromIndexPath.section == toIndexPath.section) {
		Role *role = [rolesarray objectAtIndex:fromIndexPath.section];
		DataAdapter *da = [[DataAdapter alloc]init];
		NSMutableArray *tasksarray = [NSMutableArray arrayWithArray:[da getTasksByPriority:role.objectID]];
		
		Task *selectedTask = [tasksarray objectAtIndex:fromIndexPath.row];
		
		[tasksarray removeObjectAtIndex:fromIndexPath.row];
		[tasksarray insertObject:selectedTask atIndex:toIndexPath.row];
		
		for (int order=0; order<tasksarray.count; order++) {
			Task *task_l = [tasksarray objectAtIndex:order];
			task_l.priority = [NSNumber numberWithInt:order];
		}
		
		// Save the context.
		NSError *error;
		if (![role.managedObjectContext save:&error]) {
			
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
		}
	}
}


#pragma mark -
#pragma mark Buttom Bar Buttons

-(void)back{
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)goNext{
	
	SchedulePrioritiesViewController *schedulePrioritiesViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SchedulePriorities"];
	
	[self.navigationController pushViewController:schedulePrioritiesViewController animated:NO];
	
	
}
#pragma mark UITabBarController

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
	NSLog(@"selected item tag : %d",(int)item.tag);
	if (item.tag==1) {
		self.tabBarController.selectedIndex = 2;
		SetPrioritiesViewController *gVc = [self.storyboard instantiateViewControllerWithIdentifier:@"SetPriorities"];
		//[self.navigationController popToRootViewControllerAnimated:YES];
		[self.navigationController pushViewController:gVc animated:YES];
	}
	else  if (item.tag==3) {
		[self goNext];
	}
	else if(item.tag==4)
	{
		self.tabBarController.selectedIndex = 1;
		//[self.navigationController popToRootViewControllerAnimated:YES];
		GoalTempViewController *gVc = [self.storyboard instantiateViewControllerWithIdentifier:@"tempGoalVC"];
		[self.navigationController pushViewController:gVc animated:NO];
	}
}


@end
