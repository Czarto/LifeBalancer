//
//  Deduplicator.m
//

#import "Deduplicator.h"
#import "Faulter.h"
#import "Mission.h"
#import "Role.h"

@implementation Deduplicator

+ (void)checkAndRemoveDublicateswithContext:(NSManagedObjectContext*)context {
	[context performBlock:^{
		NSMutableArray *objectsToDelete = [NSMutableArray new];
		
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"Mission" inManagedObjectContext:context];
		[fetchRequest setEntity:entity];
		
		NSError *error;
		NSArray *missions = [context executeFetchRequest:fetchRequest error:&error];
		if(error) {
			NSLog(@"Error %@", error);
		} else {
			Mission *lastMission;
			for(Mission *mission in missions) {
				if(lastMission) {
					NSDate *date1 = mission.createdDate;
					NSDate *date2 = lastMission.createdDate;
                    if ([date1 compare:date2] == NSOrderedAscending) {
						[objectsToDelete addObject:mission];
                    } else if ([date1 compare:date2] == NSOrderedDescending) {
						[objectsToDelete addObject:lastMission];
						lastMission = mission;
					} else {
						[objectsToDelete addObject:mission];
					}
				} else {
					lastMission = mission;
				}
			}
		}
		
		fetchRequest = [[NSFetchRequest alloc] init];
		[fetchRequest setEntity:[NSEntityDescription entityForName:@"Role"
											inManagedObjectContext:context]];
		NSSortDescriptor *nameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
		[fetchRequest setSortDescriptors:[[NSArray alloc] initWithObjects:nameSortDescriptor, nil]];
		
		NSArray *roles = [context executeFetchRequest:fetchRequest error:&error];
		if(error) {
			NSLog(@"Error %@", error);
		} else {
			Role *lastRole;
			for(Role *role in roles) {
				if([lastRole.name isEqual:role.name]) {
					NSDate *date1 = role.createdDate;
					NSDate *date2 = lastRole.createdDate;
					if ([date1 compare:date2] == NSOrderedAscending) {
						[objectsToDelete addObject:role];
					} else if ([date1 compare:date2] == NSOrderedDescending) {
						[objectsToDelete addObject:lastRole];
						lastRole = role;
					} else {
						[objectsToDelete addObject:role];
					}
				} else {
					lastRole = role;
				}
			}
		}
		
		for(NSManagedObject *object in objectsToDelete) {
			[context deleteObject:object];
		}
		
		[context save:&error];
		if(error)
			NSLog(@"Error %@", error);
	}];
}

+ (NSArray*)duplicatesForEntityWithName:(NSString*)entityName
				withUniqueAttributeName:(NSString*)uniqueAttributeName
							withContext:(NSManagedObjectContext*)context {
	
	// GET UNIQUE ATTRIBUTE
	NSDictionary *allEntities = [[context.persistentStoreCoordinator managedObjectModel] entitiesByName];
	NSAttributeDescription *uniqueAttribute = [[[allEntities objectForKey:entityName] propertiesByName] objectForKey:uniqueAttributeName];
	
	// CREATE COUNT EXPRESSION
	NSExpressionDescription *countExpression = [NSExpressionDescription new];
	[countExpression setName:@"count"];
	[countExpression setExpression:[NSExpression expressionWithFormat:@"count:(%K)",uniqueAttributeName]];
	[countExpression setExpressionResultType:NSInteger64AttributeType];
	
	// CREATE AN ARRAY OF _UNIQUE_ ATTRIBUTE VALUES
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:entityName];
	[fetchRequest setIncludesPendingChanges:NO];
	[fetchRequest setFetchBatchSize:100];
	[fetchRequest setPropertiesToFetch:[NSArray arrayWithObjects:uniqueAttribute, countExpression, nil]];
	[fetchRequest setPropertiesToGroupBy:[NSArray arrayWithObject:uniqueAttribute]];
	[fetchRequest setResultType:NSDictionaryResultType];
	
	NSError *error;
	
	NSArray *instances = [context executeFetchRequest:fetchRequest error:&error];
	if (error) {NSLog(@"Fetch Error: %@", error);}
	
	// RETURN AN ARRAY OF _DUPLICATE_ ATTRIBUTE VALUES
	NSArray *duplicates = [instances filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"count > 1"]];
	return duplicates;
}
+ (void)deDuplicateEntityWithName:(NSString*)entityName
		  withUniqueAttributeName:(NSString*)uniqueAttributeName
				withImportContext:(NSManagedObjectContext*)importContext {
	
	[importContext performBlock:^{
		
		NSArray *duplicates = [Deduplicator duplicatesForEntityWithName:entityName
												withUniqueAttributeName:uniqueAttributeName
															withContext:importContext];
		// FETCH DUPLICATE OBJECTS
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:entityName];
		NSArray *sortDescriptors = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:uniqueAttributeName ascending:YES],nil];
		[fetchRequest setSortDescriptors:sortDescriptors];
		[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"%K IN (%@.%K)", uniqueAttributeName, duplicates, uniqueAttributeName]];
		[fetchRequest setFetchBatchSize:100];
		[fetchRequest setIncludesPendingChanges:NO];
		
		NSError *error;
		NSArray *duplicateObjects = [importContext executeFetchRequest:fetchRequest error:&error];
		if (error) {NSLog(@"Fetch Error: %@", error);}
		
		// DELETE DUPLICATES
		NSManagedObject *lastObject;
		for (NSManagedObject *object in duplicateObjects) {
			if (lastObject) {
				if ([[object valueForKey:uniqueAttributeName] isEqual:[lastObject valueForKey:uniqueAttributeName]]) {
					
					// DELETE OLDEST DUPLICATE...
					//                    NSDate *date1 = [object valueForKey:@"modified"];
					//                    NSDate *date2 = [lastObject valueForKey:@"modified"];
					//                    [importContext deleteObject:lastObject];
					//                    if ([date1 compare:date2] == NSOrderedAscending) {
					//                        [importContext deleteObject:object];
					//                    } else if ([date1 compare:date2] == NSOrderedDescending) {
					//                        [importContext deleteObject:lastObject];
					//                    }
					//
					//                    // ..or.. DELETE DUPLICATE WITH LESS ATTRIBUTE VALUES (if dates match)
					if ([[object committedValuesForKeys:nil] count] > [[lastObject committedValuesForKeys:nil] count]) {
						[importContext deleteObject:lastObject];
					} else {
						[importContext deleteObject:object];
					}
					
					[self saveContextHeirarchy:importContext];
					
					// Save & fault objects
					[Faulter faultObjectWithID:object.objectID inContext:importContext];
					[Faulter faultObjectWithID:lastObject.objectID inContext:importContext];
				}
			}
			lastObject = object;
		}
	}];
}

#pragma mark - SAVING
+ (void)saveContextHeirarchy:(NSManagedObjectContext*)moc {
	[moc performBlockAndWait:^{
		if ([moc hasChanges]) {
			[moc processPendingChanges];
			NSError *error;
			if (![moc save:&error]) {
				NSLog(@"ERROR Saving: %@",error);
			}
		}
		// Save the parent context, if any.
		if ([moc parentContext]) {
			[self saveContextHeirarchy:moc.parentContext];
		}
	}];
}
@end
