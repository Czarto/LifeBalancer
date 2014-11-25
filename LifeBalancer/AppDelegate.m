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
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
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
		
		[Deduplicator deDuplicateEntityWithName:@"Role" withUniqueAttributeName:@"name" withImportContext:__managedObjectContext];
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

    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    NSPersistentStoreCoordinator *psc = __persistentStoreCoordinator;

	// ** Note: if you adapt this code for your own use, you MUST change this variable:
	NSString *iCloudEnabledAppID = @"75JA9J2CN3.com.lifeaireducators.testdemo1";
	
	// ** Note: if you adapt this code for your own use, you should change this variable:
	NSString *dataFileName = @"lifebalancer.sqlite";
	
	// ** Note: For basic usage you shouldn't need to change anything else
	
	NSString *iCloudDataDirectoryName = @"Data.nosync";
	NSString *iCloudLogsDirectoryName = @"Logs";
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSURL *localStore = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:dataFileName];
	NSURL *iCloud = [fileManager URLForUbiquityContainerIdentifier:nil];
	
	if (iCloud) {
		
		NSLog(@"iCloud is working");
		
		NSURL *iCloudLogsPath = [NSURL fileURLWithPath:[[iCloud path] stringByAppendingPathComponent:iCloudLogsDirectoryName]];
		
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
		[options setObject:iCloudLogsPath                forKey:NSPersistentStoreUbiquitousContentURLKey];
		
		[psc lock];
		
		[psc addPersistentStoreWithType:NSSQLiteStoreType
						  configuration:nil
									URL:[NSURL fileURLWithPath:iCloudData]
								options:options
								  error:nil];
		
		[psc unlock];
		//check weather to load initial data or not
	
		[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(showProgressBar) userInfo:nil repeats:NO];
		[NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(removeDuplicates) userInfo:nil repeats:NO];
	}
	else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"iCloud is not working" message:@"Please enable your iCloud account or enable syncing of Documents/Data in iCloud from Settings -> iCloud. Otherwise data will be stored locally and you may lose your data when delete application." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];
		
		NSLog(@"iCloud is NOT working - using a local store");
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
		[[[DataAdapter alloc] init] initialSetup2];
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
	NSUbiquitousKeyValueStore *kvStore = [NSUbiquitousKeyValueStore defaultStore];
	[kvStore synchronize];
	if (![kvStore boolForKey:@"SEEDED_DATA"])
	{
		//sync data
		[[[DataAdapter alloc] init] initialSetup2];
		
		//seed data
		[kvStore setBool:YES forKey:@"SEEDED_DATA"];
		[kvStore synchronize];
	}
	
	[Deduplicator deDuplicateEntityWithName:@"Role" withUniqueAttributeName:@"name" withImportContext:__managedObjectContext];
	dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:[[[[UIApplication sharedApplication] keyWindow] subviews] lastObject] animated:YES];
    });
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
