//
//  AppDelegate.h
//  LifeBalancer
//
//  Created by Pradeep Kumara on 3/20/13.
//  Copyright (c) 2013 EFutures. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate> 

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, assign) BOOL	isICloud;

@property(nonatomic,assign)BOOL isGoalEditing;
@property (nonatomic,assign)CGPoint lastGoalScrollPosition;

- (NSURL *)applicationDocumentsDirectory;

@end
