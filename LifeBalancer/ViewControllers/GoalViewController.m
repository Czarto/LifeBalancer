//
//  GoalViewController.m
//  LifeBalancer
//
//  Created by Pradeep Kumara on 3/28/13.
//  Copyright (c) 2013 EFutures. All rights reserved.
//

#import "GoalViewController.h"
#import "GoalDetailViewController.h"
#import "DataAdapter.h"
#import "Role+Cutomable.h"
#import "Goal.h"
#import "AppDelegate.h"
#import "customtextfield.h"
#import "SWTableViewCell.h"
#import "UMTableViewCell.h"

@interface GoalViewController () <UITextFieldDelegate>{
	NSMutableArray *rolesarray;
	
	Goal *goal;
	GoalDetailViewController *nextViewController;
	int sectionno;
}
@property (nonatomic) BOOL useCustomCells;
@property (nonatomic, weak) UIRefreshControl *refreshControl;
@end

@implementation GoalViewController

@synthesize deletedIndexPath = _deletedIndexPath;
@synthesize buttonshow;
@synthesize refreshControl;
//-(void)buttonOneActionforItemText:(NSString *)itemText{
//
//}
//-(void)buttonTwoActionforItemText:(NSString *)itemText{
//
//}
//-(void)cellDidOpen:(UITableViewCell *)cell{
//
//}
//-(void)cellDidClose:(UITableViewCell *)cell{
//
//}


#pragma mark - UITextFieldDelegate


- (void)textFieldDidBeginEditing:(UITextField *)textField{
	
	[self setEditing:YES];
	[self.tableView setEditing:NO];

	self.navigationItem.rightBarButtonItem.title = @"Done";
	customtextfield* atextField = (customtextfield*)textField;
	NSIndexPath *indexPath = atextField.indexPath;
	
	Role *role = rolesarray[indexPath.section];
	NSSet *goalset = role.goals;
	for (Goal *goaltemp in goalset) {
		if([goaltemp.name isEqualToString:textField.text])
		{
			self->goal = goaltemp;
		}
	}
	if ([UIScreen mainScreen].bounds.size.height>480) {
		if ([self.tableView cellForRowAtIndexPath:atextField.indexPath].frame.origin.y > 216) {
			[self.tableView setContentOffset:CGPointMake(0, [self.tableView cellForRowAtIndexPath:atextField.indexPath].frame.origin.y - 216)];
		}
	}else{
		if ([self.tableView cellForRowAtIndexPath:atextField.indexPath].frame.origin.y > 128) {
			[self.tableView setContentOffset:CGPointMake(0, [self.tableView cellForRowAtIndexPath:atextField.indexPath].frame.origin.y - 128)];
		}
	}
	
	[[self.tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryDetailButton];
}
-(BOOL)textField:(customtextfield *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
//	int cIndex = (int)textField.indexPath.section;
//	
//	Role *role_r = [rolesarray objectAtIndex:cIndex];
//	
//	if(cIndex>=role_r.goals.count && string.length>0) {
//		NSLog(@"New Cell");
//		[self setEditing:YES];
//		[self.tableView setEditing:NO];
//		
//	} else {
//		if(string.length >0) {
//			[self setEditing:YES];
//			[self.tableView setEditing:NO];
//			
//		}
//	}
	return YES;
}
-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
	nextViewController = nil;
	
	nextViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GoalDetailViewController"];
	nextViewController.goalVC = self;
	nextViewController.currentIndexPath = indexPath;
	
	self.deletedIndexPath = nil;
	
	Role *role = rolesarray[indexPath.section];
	nextViewController.role = role;
	
	if (indexPath.row < role.goals.count) {
		nextViewController.goal = role.getGoalsByPriority[indexPath.row];
	}
	
	if (nextViewController) {
		self.navigationController.navigationBar.backItem.title = @"Back";
		nextViewController.txtgoalname.text = [self getTextfromCell:[tableView cellForRowAtIndexPath:indexPath]];
		
		[self.navigationController pushViewController:nextViewController animated:YES];
	}
	
	
}//tableView:accessoryButtonTappedForRowWithIndexPath:
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	[self setEditing:NO animated:YES];

	return YES;
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
	
	customtextfield* atextField = (customtextfield*)textField;
	NSIndexPath *indexPath = atextField.indexPath;
	[[self.tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryNone];
	//[[self.tableView cellForRowAtIndexPath:indexPath].contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
	//[self.tableView reloadData];
	self.navigationItem.rightBarButtonItem.title = @"Edit";
	if (textField.text.length==0) {
		//[[[UIAlertView alloc]initWithTitle:nil message:@"Goal name shouldn't be empty" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
		return;
	}
	BOOL exist = NO;
	
	
	Role *role = rolesarray[indexPath.section];
	NSSet *goalset = role.goals;
	for (Goal *goalobj in goalset) {
		if ([goalobj.name isEqualToString:textField.text]) {
			exist = YES;
			break;
		}
	}
	
	if (!role) {
		return;
	}
	
	if (exist) {
		if(indexPath.row == role.goals.count)
			textField.text = @"";
		return;
	}
	NSManagedObjectContext *context = role.managedObjectContext;
	
	if (!goal) {
		goal = [NSEntityDescription insertNewObjectForEntityForName:@"Goal" inManagedObjectContext:context];
		goal.priority = [NSNumber numberWithInteger:indexPath.row];//[role.goals count]//--------------------------
		goal.name = textField.text;
		[role addGoalsObject:goal];
	}
	
	goal.name = textField.text;
	//goal.note = txtGoalNote.text;
	
	NSError *error = nil;
	if (![context save:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
	[[self.tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryNone];
	[[self.tableView cellForRowAtIndexPath:indexPath].contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
	self->goal = nil;
	[self.tableView reloadData];
	
}
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
	//-
	self.tableView.rowHeight = 50;
	
	
	// Setup refresh control for example app
	UIRefreshControl *refreshControl_l = [[UIRefreshControl alloc] init];
	[refreshControl_l addTarget:self action:@selector(toggleCells:) forControlEvents:UIControlEventValueChanged];
	refreshControl_l.tintColor = [UIColor blueColor];
	
	[self.tableView addSubview:refreshControl_l];
	self.refreshControl = refreshControl_l;
	
	// If you set the seperator inset on iOS 6 you get a NSInvalidArgumentException...weird
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
		self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0); // Makes the horizontal row seperator stretch the entire length of the table view
	}
	
	self.useCustomCells = YES;
	
	self.tableView.allowsSelectionDuringEditing = YES;
	//-
	
	self.tabBarController.tabBar.hidden = NO;
	self.parentViewController.navigationItem.rightBarButtonItem = self.editButtonItem;
	[self.tableView registerClass:[UMTableViewCell class] forCellReuseIdentifier:@"GoalCelldd"];
	//self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Home" style:UIBarButtonItemStyleBordered target:self action:@selector(goToHome)];
}


-(void)viewDidAppear:(BOOL)animated{
	[super viewDidAppear:animated];
	self.parentViewController.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	if (self.deletedIndexPath) {
		NSLog(@"should delete %@",self.deletedIndexPath);
		deleteWithoutConfirmation = YES;
		
	}
}
- (void)viewWillAppear:(BOOL)animated
{
	self.parentViewController.navigationItem.title = @"Goals";
	appDel = [[UIApplication sharedApplication] delegate];
	shouldDisplayInEditMode = YES;
	[super viewWillAppear:animated];
	self.tabBarController.tabBar.hidden = NO;
	self.navigationItem.title = @"Goals";
	[self loadroles];
	
	if (!self.editing) {
		
		if (shouldDisplayInEditMode || appDel.isGoalEditing) {
			[self.tableView setEditing:YES animated:YES];
			[self setEditing:YES];
			shouldDisplayInEditMode = NO;
		}
		
	}
	[self setEditing:NO];
	[self.tableView setContentOffset:appDel.lastGoalScrollPosition];
	//[self.tableView setEditing:YES animated:YES];
	
	
	// [self performSelector:@selector(execLater) withObject:nil afterDelay:5];
}

-(void)viewWillDisappear:(BOOL)animated
{
	appDel = [[UIApplication sharedApplication] delegate];
	appDel.isGoalEditing = self.isEditing;
	appDel.lastGoalScrollPosition = self.tableView.contentOffset;
}

-(void)execLater
{
	// [self.tableView setEditing:YES animated:YES];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	self.title = nil;
}

- (void)loadroles
{
	rolesarray = [[NSMutableArray alloc]init];
	
	NSArray *originalArray =  [[[DataAdapter alloc]init]customRoles];
	
	for (Role *role in originalArray) {
		
		if ([role.name isEqualToString:@"Physical"] ||[role.name isEqualToString:@"Spiritual"]||[role.name isEqualToString:@"Mental"]||[role.name isEqualToString:@"Social"]) {
			// default values
			NSLog(@"Role Name %@", role.name);
			//[rolesarray addObject:role];
		}
		else{
			NSLog(@"Role Name %@", role.name);
			[rolesarray addObject:role];
		}
	}
	if ([rolesarray count]<=0) {
		NSLog(@"No goals");
		
		UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"You must specify at least one Role first" completionBlock:^(NSUInteger buttonIndex, UIAlertView *alertView) {
			NSLog(@"switch");
			[self.tabBarController setSelectedIndex:1];
			
		} cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alrt show];
	}
	else{
		
	}
	
	[self.tableView reloadData];
}

- (void)goToHome
{
	[self.tabBarController setSelectedIndex:0];
}

- (IBAction)goToPrev:(id)sender {
	[self.tabBarController setSelectedIndex:2];
}
#pragma mark -
#pragma mark Editing

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
	
	[self.navigationItem setHidesBackButton:editing animated:YES];
	[self.tableView setEditing:editing animated:animated];
	
	if(!editing) {
		NSLog(@"Done");

		[self.tableView reloadData];
		
	} else {
		goal = nil;

	}
	
	//    [self.tableView beginUpdates];
	//
	//    for (int rolecount=0; rolecount < rolesarray.count; rolecount++) {
	//        Role *role = rolesarray[rolecount];
	//        if (role.goals.count < 10) {
	//            NSArray *goalsInsertIndexPath = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:[role.goals count] inSection:rolecount]];
	//
	//            if (editing) {
	//                [self.tableView insertRowsAtIndexPaths:goalsInsertIndexPath withRowAnimation:UITableViewRowAnimationTop];
	////				[self.tableView reloadData];
	//            } else {
	//                [self.tableView deleteRowsAtIndexPaths:goalsInsertIndexPath withRowAnimation:UITableViewRowAnimationTop];
	//
	//            }
	//        }
	//    }
	//    [self.tableView endUpdates];
}



#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return rolesarray.count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger rows = 0;
	Role *role = rolesarray[section];
	rows = [role.goals count];
	rows++;
	if (role.goals.count != 0) {
		shouldDisplayInEditMode = NO;
	}
	//
	//    if (self.editing && rows < 10) {
	//        rows++;
	//    }
	return rows;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	Role *role = rolesarray[section];
	return [NSString stringWithFormat:@"      %@",role.name];
}
- (void)toggleCells:(UIRefreshControl*)refreshControl
{
	// [refreshControl beginRefreshing];
	self.useCustomCells = !self.useCustomCells;
	if (self.useCustomCells)
	{
		self.refreshControl.tintColor = [UIColor yellowColor];
	}
	else
	{
		self.refreshControl.tintColor = [UIColor blueColor];
	}
	[self.tableView reloadData];
	//  [refreshControl endRefreshing];
}
- (NSArray *)rightButtons
{
	NSMutableArray *rightUtilityButtons = [NSMutableArray new];
	[rightUtilityButtons sw_addUtilityButtonWithColor:
	 [UIColor colorWithRed:0.2f green:0.4f blue:0.9f alpha:1.0]
												title:@"More"];
	[rightUtilityButtons sw_addUtilityButtonWithColor:
	 [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
												title:@"Delete"];
	
	return rightUtilityButtons;
}
- (NSArray *)leftButtons
{
	NSMutableArray *leftUtilityButtons = [NSMutableArray new];
	
	[leftUtilityButtons sw_addUtilityButtonWithColor:
	 [UIColor colorWithRed:0.07 green:0.75f blue:0.16f alpha:1.0]
												icon:[UIImage imageNamed:@"check.png"]];
	[leftUtilityButtons sw_addUtilityButtonWithColor:
	 [UIColor colorWithRed:1.0f green:1.0f blue:0.35f alpha:1.0]
												icon:[UIImage imageNamed:@"clock.png"]];
	[leftUtilityButtons sw_addUtilityButtonWithColor:
	 [UIColor colorWithRed:1.0f green:0.231f blue:0.188f alpha:1.0]
												icon:[UIImage imageNamed:@"cross.png"]];
	[leftUtilityButtons sw_addUtilityButtonWithColor:
	 [UIColor colorWithRed:0.55f green:0.27f blue:0.07f alpha:1.0]
												icon:[UIImage imageNamed:@"list.png"]];
	
	return leftUtilityButtons;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UMTableViewCell *rolecell = [tableView dequeueReusableCellWithIdentifier:@"GoalCelldd"];
	[rolecell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
	Role *role = rolesarray[indexPath.section];
	//customtextfield *textField = [[customtextfield alloc] initWithFrame:CGRectMake(20, 0, 190, rolecell.frame.size.height)];
	//[rolecell.contentView addSubview:textField];
	//[rolecell setLeftUtilityButtons:[self leftButtons] WithButtonWidth:32.0f];
	
	rolecell.delegate = self;
	
	rolecell.label.text = [NSString stringWithFormat:@"Section: %ld, Seat: %ld", (long)indexPath.section, (long)indexPath.row];
	//-
	customtextfield *textField = [[customtextfield alloc] initWithFrame:CGRectMake(20, 0, 300, rolecell.frame.size.height)];
	[rolecell.contentView addSubview:textField];
	
	textField.indexPath = indexPath;
	rolecell.delegate = self;
	textField.delegate = self;
	
	//-
	
	if (indexPath.row < role.goals.count) {
		Goal *goal_s = [role.getGoalsByPriority objectAtIndex:indexPath.row];
		//rolecell.textLabel.text = goal.name;
		textField.text = goal_s.name;
		//NSLog(goal_s.name);
		[rolecell setRightUtilityButtons:[self rightButtons] WithButtonWidth:58.0f];
		//rolecell.button1.hidden = YES;//!buttonshow;
		//rolecell.button2.hidden = YES;//!buttonshow;
	} else {
		textField.text = @"";
		//rolecell.button1.hidden = YES;
		//rolecell.button2.hidden = YES;
	}
	
	//rolecell.accessoryType = UITableViewCellSelectionStyleBlue;//DisclosureIndicator;
	
	return rolecell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSIndexPath *rowToSelect = indexPath;
	BOOL isEditing = self.editing;
	
	if (!isEditing) {
		rowToSelect = nil;
	}
	
	return rowToSelect;
	
	NSLog(@"here?");
	
	//	if (/*!self.isEditing*/NO) {
	//		rowToSelect = nil;
	//	}else if (indexPath.row < [rolesarray count]) {
	//		//role = [rolesarray objectAtIndex:indexPath.row];
	//
	//		// if (!role.custom.boolValue) {
	//		//rowToSelect = nil;
	//		// }
	//	}
	//
	//	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	//
	//	return rowToSelect;
	
}

#pragma mark - SWTableViewDelegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state
{
	switch (state) {
		case 0:
			NSLog(@"utility buttons closed");
			break;
		case 1:
			NSLog(@"left utility buttons open");
			break;
		case 2:
			NSLog(@"right utility buttons open");
			break;
		default:
			break;
	}
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index
{
	switch (index) {
		case 0:
			NSLog(@"left button 0 was pressed");
			break;
		case 1:
			NSLog(@"left button 1 was pressed");
			break;
		case 2:
			NSLog(@"left button 2 was pressed");
			break;
		case 3:
			NSLog(@"left btton 3 was pressed");
		default:
			break;
	}
}
- (NSString*)getTextfromCell:(NSObject*) objClass {
	for(id aSubView in [(UIView*)objClass subviews])
	{
		if([aSubView isKindOfClass:[UITextField class]])
		{
			UITextField *textField=(UITextField*)aSubView;
			return textField.text;
		}
	}
	return @"";
}
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
	switch (index) {
		case 0:
		{
			NSLog(@"More button was pressed");
			
			nextViewController = nil;
			
			nextViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GoalDetailViewController"];
			nextViewController.goalVC = self;
			NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
			nextViewController.currentIndexPath = indexPath;
			
			self.deletedIndexPath = nil;
			
			Role *role = rolesarray[indexPath.section];
			nextViewController.role = role;
			
			if (indexPath.row < role.goals.count) {
				nextViewController.goal = role.getGoalsByPriority[indexPath.row];
			}
			
			if (nextViewController) {
				self.navigationController.navigationBar.backItem.title = @"Back";
				nextViewController.txtgoalname.text = [self getTextfromCell:cell];
				[self.navigationController pushViewController:nextViewController animated:YES];
				
			}
			
			[cell hideUtilityButtonsAnimated:YES];
			break;
		}
		case 1:
		{
			// Delete button was pressed
			NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
			
			self.deletedIndexPath = cellIndexPath;
			if (self.deletedIndexPath) {
				NSLog(@"should delete %@",self.deletedIndexPath);
				deleteWithoutConfirmation = YES;
				[self tableView:self.tableView commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:cellIndexPath];
			}
			//[self.tableView deleteRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
			[self.tableView reloadData];
			break;
		}
		default:
			break;
	}
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

#pragma mark - end

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	nextViewController = nil;
	
	nextViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GoalDetailViewController"];
	nextViewController.goalVC = self;
	nextViewController.currentIndexPath = indexPath;
	
	self.deletedIndexPath = nil;
	
	Role *role = rolesarray[indexPath.section];
	nextViewController.role = role;
	
	if (indexPath.row < role.goals.count) {
		nextViewController.goal = role.getGoalsByPriority[indexPath.row];
	}
	
	if (nextViewController) {
		self.navigationController.navigationBar.backItem.title = @"Back";
		nextViewController.txtgoalname.text = [self getTextfromCell:[tableView cellForRowAtIndexPath:indexPath]];
		
		[self.navigationController pushViewController:nextViewController animated:YES];
	}
	
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCellEditingStyle style = UITableViewCellEditingStyleNone;
	
	Role *role = rolesarray[indexPath.section];
	
	if (indexPath.row < role.goals.count) {
		style = UITableViewCellEditingStyleDelete;
	} else {
		style = UITableViewCellEditingStyleNone;
	}
	
	return style;
}




- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (deleteWithoutConfirmation) {
		deleteWithoutConfirmation = NO;
		if (editingStyle == UITableViewCellEditingStyleDelete) {
			Role *role = rolesarray[indexPath.section];
			
			if (indexPath.row < role.goals.count) {
				
				NSMutableArray *goalsarray = [NSMutableArray arrayWithArray:[role getGoalsByPriority]];
				
				Goal *selectedgoal = [goalsarray objectAtIndex:indexPath.row];
				
				[role removeGoalsObject:selectedgoal];
				[selectedgoal.managedObjectContext deleteObject:selectedgoal];
				
				[goalsarray removeObjectAtIndex:indexPath.row];
				
				for (int order=0; order<goalsarray.count; order++) {
					Goal *goal_ = [goalsarray objectAtIndex:order];
					goal_.priority = [NSNumber numberWithInt:order];
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
			Role *role = rolesarray[indexPath.section];
			
			if (indexPath.row < role.goals.count) {
				
				NSMutableArray *goalsarray = [NSMutableArray arrayWithArray:[role getGoalsByPriority]];
				
				Goal *selectedgoal = [goalsarray objectAtIndex:indexPath.row];
				
				[role removeGoalsObject:selectedgoal];
				[selectedgoal.managedObjectContext deleteObject:selectedgoal];
				[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
				
				[goalsarray removeObjectAtIndex:indexPath.row];
				
				for (int order=0; order<goalsarray.count; order++) {
					Goal *goal_ = [goalsarray objectAtIndex:order];
					goal_.priority = [NSNumber numberWithInt:order];
				}
				
				// Save the context.
				NSError *error;
				if (![role.managedObjectContext save:&error]) {
					
					NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
					abort();
				}
				//			[self loadroles];
			}
			
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
			
			
		}
		else if (editingStyle == UITableViewCellEditingStyleInsert) {
			[self tableView:tableView didSelectRowAtIndexPath:indexPath];
		}
		
		
		
	}
}
/*
 -(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
	
	if (editingStyle == UITableViewCellEditingStyleDelete) {
 [rolesarray[indexPath.section] removeObjectAtIndex:indexPath.row];
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 
	}else{
 NSLog(@"Unhandled editing style! %d",editingStyle);
	}
	
 }
 */
#pragma mark -
#pragma mark Moving rows

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
	return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	BOOL canMove = NO;
	Role *role = rolesarray[indexPath.section];
	canMove = indexPath.row != [role.goals count];
	return canMove;
}


- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
	NSIndexPath *target = proposedDestinationIndexPath;
	NSIndexPath *source = sourceIndexPath;
	
	Role *role = rolesarray[source.section];
	
	if (target.section < source.section) {
		target = [NSIndexPath indexPathForRow:0 inSection:source.section];
	} else if (target.section > source.section) {
		target = [NSIndexPath indexPathForRow:([role.goals count] - 1) inSection:source.section];
	} else {
		NSUInteger ingredientsCount_1 = [role.goals count] - 1;
		
		if (target.row > ingredientsCount_1) {
			target = [NSIndexPath indexPathForRow:ingredientsCount_1 inSection:source.section];
		}
	}
	
	return target;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	
	if (fromIndexPath.section == toIndexPath.section) {
		Role *role = [rolesarray objectAtIndex:fromIndexPath.section];
		NSMutableArray *goalsarray = [NSMutableArray arrayWithArray:[role getGoalsByPriority]];
		
		Goal *selectedgoal = [goalsarray objectAtIndex:fromIndexPath.row];
		
		[goalsarray removeObjectAtIndex:fromIndexPath.row];
		[goalsarray insertObject:selectedgoal atIndex:toIndexPath.row];
		
		for (int order=0; order<goalsarray.count; order++) {
			Goal *goal_ = [goalsarray objectAtIndex:order];
			goal_.priority = [NSNumber numberWithInt:order];
		}
		
		// Save the context.
		NSError *error;
		if (![role.managedObjectContext save:&error]) {
			
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
		}
	}
}


- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end