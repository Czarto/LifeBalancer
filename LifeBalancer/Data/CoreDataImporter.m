//
//  CoreDataImporter.m
//
//  Created by Tim Roadley on 22/07/13.
//  Copyright (c) 2013 Tim Roadley. All rights reserved.
//

#import "CoreDataImporter.h"
@implementation CoreDataImporter
#define debug 0
+ (void)saveContext:(NSManagedObjectContext*)context {
    if (debug==1) {NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));}
    [context performBlockAndWait:^{
        if ([context hasChanges]) {
            NSError *error = nil;
            if ([context save:&error]) {
                NSLog(@"CoreDataImporter SAVED changes from context to persistent store");
            }
            else {
                NSLog(@"CoreDataImporter FAILED to save changes from context to persistent store: %@", error);
            }
        }
        else {
            NSLog(@"CoreDataImporter SKIPPED saving context as there are no changes");
        }
    }];
}

- (CoreDataImporter*)initWithUniqueAttributes:(NSDictionary*)uniqueAttributes {
    if (debug==1) {NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));}
    
    if (self = [super init]) {
        
        self.entitiesWithUniqueAttributes = uniqueAttributes;
        
        if (self.entitiesWithUniqueAttributes) {
            return self;
        } else {
            NSLog(@"FAILED to initialize CoreDataImporter. The entitiesWithUniqueAttributes is nil");
            return nil;
        }
    }
    return nil;
}

- (NSString*)uniqueAttributeForEntity:(NSString*)entity {
    if (debug==1) {NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));}
    return [self.entitiesWithUniqueAttributes valueForKey:entity];
}
- (NSManagedObject*)existingObjectInContext:(NSManagedObjectContext*)context
                                  forEntity:(NSString*)entity
                   withUniqueAttributeValue:(NSString*)uniqueAttributeValue {
    if (debug==1) {NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));}
    NSString *uniqueAttribute = [self uniqueAttributeForEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K==%@", uniqueAttribute, uniqueAttributeValue];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entity];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setFetchLimit:1];
    NSError *error;
    NSArray *fetchRequestResults = [context executeFetchRequest:fetchRequest error:&error];
    if (error) {NSLog(@"Error: %@", error.localizedDescription);}
    if (fetchRequestResults.count == 0) {return nil;}
    return fetchRequestResults.lastObject;
}

- (NSManagedObject*)insertUniqueObjectInTargetEntity:(NSString*)entity
                                uniqueAttributeValue:(NSString*)uniqueAttributeValue
                                     attributeValues:(NSDictionary*)attributeValues
                                           inContext:(NSManagedObjectContext*)context {
    if (debug==1) {NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));}
    NSString *uniqueAttribute = [self uniqueAttributeForEntity:entity];
    if (uniqueAttributeValue.length > 0) {
        NSManagedObject *existingObject = [self existingObjectInContext:context
                                                              forEntity:entity
                                               withUniqueAttributeValue:uniqueAttributeValue];
        if (existingObject) {
            NSLog(@"%@ object with %@ value '%@' already exists",entity, uniqueAttribute, uniqueAttributeValue);
            return existingObject;
        } else {
            NSManagedObject *newObject = [NSEntityDescription insertNewObjectForEntityForName:entity inManagedObjectContext:context];
            [newObject setValuesForKeysWithDictionary:attributeValues];
            NSLog(@"Created %@ object with %@ '%@'", entity, uniqueAttribute, uniqueAttributeValue);
            return newObject;
        }
    } else {
        NSLog(@"Skipped %@ object creation because unique attribute value is 0 length", entity);
    }
    return nil;
}

- (NSManagedObject*)insertBasicObjectInTargetEntity:(NSString*)entity
                              targetEntityAttribute:(NSString*)targetEntityAttribute
                                 sourceXMLAttribute:(NSString*)sourceXMLAttribute
                                      attributeDict:(NSDictionary*)attributeDict
                                            context:(NSManagedObjectContext*)context {
    
    NSArray *attributes = [NSArray arrayWithObject:targetEntityAttribute];
    NSArray *values     = [NSArray arrayWithObject:[attributeDict valueForKey:sourceXMLAttribute]];
    
    NSDictionary *attributeValues = [NSDictionary dictionaryWithObjects:values forKeys:attributes];
    
    return [self insertUniqueObjectInTargetEntity:entity
                             uniqueAttributeValue:[attributeDict valueForKey:sourceXMLAttribute]
                                  attributeValues:attributeValues
                                        inContext:context];
}

#pragma mark – DEEP COPY
- (NSString*)objectInfo:(NSManagedObject*)object {
    
    if (!object) {return nil;}
    
    NSString *entity = object.entity.name;
    NSString *uniqueAttribute = [self uniqueAttributeForEntity:entity];
    NSString *uniqueAttributeValue = [object valueForKey:uniqueAttribute];
    
    return [NSString stringWithFormat:@"%@ '%@'", entity, uniqueAttributeValue];
}

- (NSArray*)arrayForEntity:(NSString*)entity
                 inContext:(NSManagedObjectContext*)context
             withPredicate:(NSPredicate*)predicate {
    if (debug==1) {NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));}
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entity];
    [request setFetchBatchSize:15];
    [request setPredicate:predicate];
    NSError *error;
    NSArray *array = [context executeFetchRequest:request error:&error];
    if (error) {NSLog(@"ERROR fetching objects: %@", error.localizedDescription);}
    return array;
}

- (NSManagedObject*)copyUniqueObject:(NSManagedObject*)object
                           toContext:(NSManagedObjectContext*)targetContext {
    
    if (debug==1) {NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));}
    
    // SKIP copying object with missing info
    if (!object || !targetContext) {
        NSLog(@"FAILED to copy %@ to context %@",[self objectInfo:object], targetContext);
        return nil;
    }
    
    // PREPARE variables
    NSString *entity = object.entity.name;
    NSString *uniqueAttribute = [self uniqueAttributeForEntity:entity];
    NSString *uniqueAttributeValue = [object valueForKey:uniqueAttribute];
    
    if (uniqueAttributeValue.length  > 0) {
        
        // PREPARE attributes to copy
        NSMutableDictionary *attributeValuesToCopy = [NSMutableDictionary new];
        for (NSString *attribute in object.entity.attributesByName) {
            [attributeValuesToCopy setValue:[[object valueForKey:attribute] copy] forKey:attribute];
        }
        
        // COPY object
        NSManagedObject *copiedObject = [self insertUniqueObjectInTargetEntity:entity
                                                          uniqueAttributeValue:uniqueAttributeValue
                                                               attributeValues:attributeValuesToCopy
                                                                     inContext:targetContext];
        // Update modified date as appropriate
        if ([[[copiedObject entity] attributesByName] objectForKey:@"modified"]) {
            [copiedObject setValue:[NSDate date] forKey:@"modified"];
        }
        return copiedObject;
    } else {
        NSLog(@"Skipped copying %@ because the unique attribute value is 0 length", [self objectInfo:object]);
    }
    return nil;
}

- (void)establishToOneRelationship:(NSString*)relationshipName
                        fromObject:(NSManagedObject*)object
                          toObject:(NSManagedObject*)relatedObject {
    
    if (debug==1) {NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));}
    
    // SKIP establishing a relationship with missing info
    if (!relationshipName || !object || !relatedObject) {
        NSLog(@"SKIPPED establishment of To-One relationship '%@' between %@ and %@", relationshipName, [self objectInfo:object], [self objectInfo:relatedObject]);
        return;
    }
    
    // SKIP establishing an existing relationship
    NSManagedObject *existingRelatedObject = [object valueForKey:relationshipName];
    if (existingRelatedObject) {
        NSLog(@"%@ is already related to %@", [self objectInfo:object], [self objectInfo:existingRelatedObject]);
        return;
    }
    
    // SKIP establishing a relationship to the wrong entity
    NSDictionary *relationships = [object.entity relationshipsByName];
    NSRelationshipDescription *relationship = [relationships objectForKey:relationshipName];
    if (![relatedObject.entity isEqual:relationship.destinationEntity]) {
        NSLog(@"%@ is the of wrong entity type to relate to %@", [self objectInfo:object], [self objectInfo:relatedObject]);
        return;
    }
    
    // ESTABLISH the relationship
    [object setValue:relatedObject forKey:relationshipName];
    NSLog(@"ESTABLISHED %@ relationship from %@ to %@", relationshipName, [self objectInfo:object], [self objectInfo:relatedObject]);
    
    // REMOVE the relationship from memory after it is committed to disk
    [CoreDataImporter saveContext:relatedObject.managedObjectContext];
    [CoreDataImporter saveContext:object.managedObjectContext];
    [object.managedObjectContext refreshObject:object mergeChanges:NO];
    [relatedObject.managedObjectContext refreshObject:relatedObject mergeChanges:NO];
}

- (void)establishToManyRelationship:(NSString*)relationshipName
                         fromObject:(NSManagedObject*)object
                      withSourceSet:(NSMutableSet*)sourceSet {
    
    if (!object || !sourceSet || !relationshipName) {
        NSLog(@"SKIPPED establishment of an ordered To-Many relationship from %@", [self objectInfo:object]);
        return;
    }
    
    NSMutableSet *copiedSet = [object mutableSetValueForKey:relationshipName];
    
    for (NSManagedObject *relatedObject in sourceSet) {
        
        NSManagedObject *copiedRelatedObject = [self copyUniqueObject:relatedObject toContext:object.managedObjectContext];
        
        if (copiedRelatedObject) {
            [copiedSet addObject:copiedRelatedObject];
            NSLog(@"A copy of %@ is now related via To-Many '%@' relationship to %@", [self objectInfo:object], relationshipName, [self objectInfo:copiedRelatedObject]);
        } else {
            NSLog(@"SKIPPED nil '%@' relationship copy for %@", relationshipName, [self objectInfo:object]);
        }
    }
    // REMOVE the relationship from memory after it is committed to disk
    [CoreDataImporter saveContext:object.managedObjectContext];
    [object.managedObjectContext refreshObject:object mergeChanges:NO];
}

- (void)establishOrderedToManyRelationship:(NSString*)relationshipName
                                fromObject:(NSManagedObject*)object
                             withSourceSet:(NSMutableOrderedSet*)sourceSet {
    
    if (!object || !sourceSet || !relationshipName) {
        NSLog(@"SKIPPED establishment of an ordered To-Many relationship from %@", [self objectInfo:object]);
        return;
    }
    
    NSMutableOrderedSet *copiedSet = [object mutableOrderedSetValueForKey:relationshipName];
    
    for (NSManagedObject *relatedObject in sourceSet) {
        
        NSManagedObject *copiedRelatedObject = [self copyUniqueObject:relatedObject toContext:object.managedObjectContext];
        
        if (copiedRelatedObject) {
            [copiedSet addObject:copiedRelatedObject];
            NSLog(@"A copy of %@ is now related via ORDERED To-Many '%@' relationship to %@", [self objectInfo:object], relationshipName, [self objectInfo:copiedRelatedObject]);
        } else {
            NSLog(@"SKIPPED nil '%@' relationship copy for %@", relationshipName, [self objectInfo:object]);
        }
    }
    
    // REMOVE the relationship from memory after it is committed to disk
    [CoreDataImporter saveContext:object.managedObjectContext];
    [object.managedObjectContext refreshObject:object mergeChanges:NO];
}

- (void)copyRelationshipsFromObject:(NSManagedObject*)sourceObject
                          toContext:(NSManagedObjectContext*)targetContext {
    
    if (debug==1) {NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));}
    
    // SKIP establishing relationships with missing info
    if (!sourceObject || !targetContext) {
        NSLog(@"FAILED to copy relationships from '%@' to context '%@'", [self objectInfo:sourceObject], targetContext);
        return;
    }
    
    // SKIP establishing relationships from nil objects
    NSManagedObject *copiedObject = [self copyUniqueObject:sourceObject toContext:targetContext];
    if (!copiedObject) {
        NSLog(@"FAILED to copy relationships from %@. Equivalent object in target context is nil !!!!", [self objectInfo:sourceObject]);
        return;
    }
    
    // COPY relationships
    NSDictionary *relationships = [sourceObject.entity relationshipsByName];
    for (NSString *relationshipName in relationships) {
        
        NSRelationshipDescription *relationship = [relationships objectForKey:relationshipName];
        if ([sourceObject valueForKey:relationshipName]) {
            
            if (relationship.isToMany && relationship.isOrdered) {
                
                // COPY To-Many Ordered
                NSMutableOrderedSet *sourceSet = [sourceObject mutableOrderedSetValueForKey:relationshipName];
                [self establishOrderedToManyRelationship:relationshipName fromObject:copiedObject withSourceSet:sourceSet];
                
            } else if (relationship.isToMany && !relationship.isOrdered) {
                
                // COPY To-Many
                NSMutableSet *sourceSet = [sourceObject mutableSetValueForKey:relationshipName];
                [self establishToManyRelationship:relationshipName fromObject:copiedObject withSourceSet:sourceSet];
                
            } else {
                
                // COPY To-One
                NSManagedObject *relatedSourceObject = [sourceObject valueForKey:relationshipName];
                NSManagedObject *relatedCopiedObject = [self copyUniqueObject:relatedSourceObject toContext:targetContext];
                [self establishToOneRelationship:relationshipName fromObject:copiedObject toObject:relatedCopiedObject];
            }
        }
    }
}

- (void)deepCopyEntities:(NSArray*)entities
             fromContext:(NSManagedObjectContext*)sourceContext
               toContext:(NSManagedObjectContext*)targetContext {
    
    if (debug==1) {NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));}
    
    for (NSString *entity in entities) {
        
        NSLog(@"COPYING %@ objects to target context...", entity);
        NSArray *sourceObjects = [self arrayForEntity:entity inContext:sourceContext withPredicate:nil];
        
        for (NSManagedObject *sourceObject in sourceObjects) {
            
            if (sourceObject) {
                @autoreleasepool {
                    [self copyUniqueObject:sourceObject toContext:targetContext];
                    [self copyRelationshipsFromObject:sourceObject toContext:targetContext];
                }
            }
        }
    }
}
@end
