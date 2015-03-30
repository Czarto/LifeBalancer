//
//  AppDelegate.m
//  LifeBalancer
//
//  Created by Pradeep Kumara on 3/20/13.
//  Copyright (c) 2013 EFutures. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeViewController.h"
#import "Mission.h"
#import "Role.h"
#import "DataAdapter.h"
#import "Deduplicator.h"
#import "MBProgressHUD.h"
#import "Common.h"

// ** Note: if you adapt this code for your own use, you MUST change this variable:
static NSString *iCloudEnabledAppID = @"75JA9J2CN3.com.lifeaireducators.testdemo1";

// ** Note: if you adapt this code for your own use, you should change this variable:
static NSString *dataFileName = @"lifebalancer.sqlite";

// ** Note: For basic usage you shouldn't need to change anything else
static NSString *iCloudDataDirectoryName = @"Data.nosync";
static NSString *iCloudLogsDirectoryName = @"Logs";

@implementation AppDelegate

@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[[UITabBarItem appearance] setTitleTextAttributes:@{
														NSFontAttributeName: [UIFont systemFontOfSize:16],
														NSForegroundColorAttributeName: [UIColor colorWithRed:47/255.0f green:112/255.0f blue:225/255.0f alpha:1.0]
														}forState:UIControlStateNormal];
	
	[self.managedObjectContext save:nil];
	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	if(self.isICloud) {
		[self migrateICloudToLocaleStore];
	}
	
	[self saveContext];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Saves changes in the application's managed object context before the application terminates.
	[self saveContext];
}

- (void)saveContext
{
	NSError *error = nil;
	NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
	if (managedObjectContext != nil) {
		if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			// Replace this implementation with code to handle the error appropriately.
			// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
		}
	}
}

#pragma mark - Core Data stack


// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext {
	
	if (__managedObjectContext != nil) {
		return __managedObjectContext;
	}
	
	NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
	
	if (coordinator != nil) {
		NSManagedObjectContext* moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
		
		[moc performBlockAndWait:^{
			[moc setPersistentStoreCoordinator: coordinator];
			[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(mergeChangesFrom_iCloud:) name:NSPersistentStoreDidImportUbiquitousContentChangesNotification object:coordinator];
		}];
		__managedObjectContext = moc;
	}
	
	return __managedObjectContext;
}

//Merge changes from iCloud
- (void)mergeChangesFrom_iCloud:(NSNotification *)notification {
	
	NSLog(@"Merging in changes from iCloud...");
	
	NSManagedObjectContext* moc = [self managedObjectContext];
	
	[moc performBlock:^{
		
		[moc mergeChangesFromContextDidSaveNotification:notification];
		
		[Deduplicator checkAndRemoveDublicateswithContext:__managedObjectContext];
		NSNotification* refreshNotification = [NSNotification notificationWithName:@"SomethingChanged"
																			object:self
																		  userInfo:[notification userInfo]];
		
		[[NSNotificationCenter defaultCenter] postNotification:refreshNotification];
	}];
}



// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
	if (__managedObjectModel != nil)
	{
		return __managedObjectModel;
	}
	NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"lifebalancer" withExtension:@"momd"];
	__managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
	return __managedObjectModel;
}


// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
	if((__persistentStoreCoordinator != nil)) {
		return __persistentStoreCoordinator;
	}
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSURL *iCloud = [fileManager URLForUbiquityContainerIdentifier:nil];
	
	if (iCloud) {
		NSLog(@"iCloud is working");
		
		__persistentStoreCoordinator = [self iCloudpersistentStoreCoordinator];
		
		self.isICloud = YES;

		//check weather to load initial data or not
		[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(showProgressBar) userInfo:nil repeats:NO];
		[NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(checkLocalStorageToMigration) userInfo:nil repeats:NO];
	}
	else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"iCloud is not working" message:@"Please enable your iCloud account or enable syncing of Documents/Data in iCloud from Settings -> iCloud. Otherwise data will be stored locally and you may lose your data when delete application." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];
		
		NSLog(@"iCloud is NOT working - using a local store");
		__persistentStoreCoordinator = [self localPersistentStoreCoordinator];
		[self removeDuplicates];
		
		self.isICloud = NO;
		[Common lastSessionWithLocalStorage:YES];
	}
	
	dispatch_async(dispatch_get_main_queue(), ^{
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SomethingChanged" object:self userInfo:nil];
	});
	
	return __persistentStoreCoordinator;
	
}

- (void)showProgressBar
{
	[MBProgressHUD showHUDAddedTo:[[[[UIApplication sharedApplication] keyWindow] subviews] lastObject] animated:YES];
}

-(void)removeDuplicates
{
	[[[DataAdapter alloc] init] initialSetup2];
	
	[Deduplicator checkAndRemoveDublicateswithContext:__managedObjectContext];
	dispatch_async(dispatch_get_main_queue(), ^{
		[MBProgressHUD hideHUDForView:[[[[UIApplication sharedApplication] keyWindow] subviews] lastObject] animated:YES];
	});
}

- (void)checkLocalStorageToMigration {
	if([Common isLastSessionWithLocalStorage]) {
		[self migrateLocalStoreToICloud];
	}
	[Common lastSessionWithLocalStorage:NO];
	[self removeDuplicates];
}

- (NSPersistentStoreCoordinator*)iCloudpersistentStoreCoordinator {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSURL *iCloud = [fileManager URLForUbiquityContainerIdentifier:nil];
	
	NSURL *iCloudLogsPath = [NSURL fileURLWithPath:[[iCloud path] stringByAppendingPathComponent:iCloudLogsDirectoryName]];
	
	NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
	
	NSLog(@"iCloudEnabledAppID = %@",iCloudEnabledAppID);
	NSLog(@"dataFileName = %@", dataFileName);
	NSLog(@"iCloudDataDirectoryName = %@", iCloudDataDirectoryName);
	NSLog(@"iCloudLogsDirectoryName = %@", iCloudLogsDirectoryName);
	NSLog(@"iCloud = %@", iCloud);
	NSLog(@"iCloudLogsPath = %@", iCloudLogsPath);
	
	if([fileManager fileExistsAtPath:[[iCloud path] stringByAppendingPathComponent:iCloudDataDirectoryName]] == NO) {
		NSError *fileSystemError;
		[fileManager createDirectoryAtPath:[[iCloud path] stringByAppendingPathComponent:iCloudDataDirectoryName]
			   withIntermediateDirectories:YES
								attributes:nil
									 error:&fileSystemError];
		if(fileSystemError != nil) {
			NSLog(@"Error creating database directory %@", fileSystemError);
		}
	}
	
	NSString *iCloudData = [[[iCloud path]
							 stringByAppendingPathComponent:iCloudDataDirectoryName]
							stringByAppendingPathComponent:dataFileName];
	
	NSLog(@"iCloudData = %@", iCloudData);
	
	NSMutableDictionary *options = [NSMutableDictionary dictionary];
	[options setObject:[NSNumber numberWithBool:YES] forKey:NSMigratePersistentStoresAutomaticallyOption];
	[options setObject:[NSNumber numberWithBool:YES] forKey:NSInferMappingModelAutomaticallyOption];
	[options setObject:iCloudEnabledAppID            forKey:NSPersistentStoreUbiquitousContentNameKey];
	
	[psc lock];
	
	NSError *error;
	[psc addPersistentStoreWithType:NSSQLiteStoreType
					  configuration:nil
								URL:[NSURL fileURLWithPath:iCloudData]
							options:options
							  error:&error];
	if(error)
		NSLog(@"Error %@", error);
	
	[psc unlock];
	return psc;
}

- (NSPersistentStoreCoordinator*)localPersistentStoreCoordinator {
	NSURL *localStore = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:dataFileName];
	NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
	NSMutableDictionary *options = [NSMutableDictionary dictionary];
	[options setObject:[NSNumber numberWithBool:YES] forKey:NSMigratePersistentStoresAutomaticallyOption];
	[options setObject:[NSNumber numberWithBool:YES] forKey:NSInferMappingModelAutomaticallyOption];
	
	[psc lock];
	
	[psc addPersistentStoreWithType:NSSQLiteStoreType
					  configuration:nil
								URL:localStore
							options:options
							  error:nil];
	[psc unlock];
	return psc;
}

- (void)migrateICloudToLocaleStore {
	NSURL *localStore = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:dataFileName];
	NSPersistentStoreCoordinator *coordinator = [self iCloudpersistentStoreCoordinator];
	NSPersistentStore *store = [[coordinator persistentStores] firstObject];
	
	[coordinator lock];
	NSMutableDictionary *options = [NSMutableDictionary dictionary];
	[options setObject:[NSNumber numberWithBool:YES] forKey:NSMigratePersistentStoresAutomaticallyOption];
	[options setObject:[NSNumber numberWithBool:YES] forKey:NSInferMappingModelAutomaticallyOption];
	
	NSPersistentStore *newStore =  [coordinator migratePersistentStore:store
																 toURL:localStore
															   options:options
															  withType:NSSQLiteStoreType error:nil];
	[coordinator unlock];
}

- (void)migrateLocalStoreToICloud {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSURL *iCloud = [fileManager URLForUbiquityContainerIdentifier:nil];
	NSString *iCloudData = [[[iCloud path] stringByAppendingPathComponent:iCloudDataDirectoryName] stringByAppendingPathComponent:dataFileName];
	
	NSPersistentStoreCoordinator *coordinator = [self localPersistentStoreCoordinator];
	NSPersistentStore *store = [[coordinator persistentStores] firstObject];
	[coordinator lock];
	NSMutableDictionary *options = [NSMutableDictionary dictionary];
	[options setObject:[NSNumber numberWithBool:YES] forKey:NSMigratePersistentStoresAutomaticallyOption];
	[options setObject:[NSNumber numberWithBool:YES] forKey:NSInferMappingModelAutomaticallyOption];
	[options setObject:iCloudEnabledAppID            forKey:NSPersistentStoreUbiquitousContentNameKey];
	
	NSPersistentStore *newStore =  [coordinator migratePersistentStore:store
																 toURL:[NSURL fileURLWithPath:iCloudData]
															   options:options
															  withType:NSSQLiteStoreType error:nil];
	[coordinator unlock];
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
	return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSString*)pathToTheDocumentsDirectory {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return documentsDirectory;
}

@end
