//
//  Deduplicator.h
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h> 

@interface Deduplicator : NSObject

+ (void)checkAndRemoveDublicateswithContext:(NSManagedObjectContext*)context;
+ (void)deDuplicateEntityWithName:(NSString*)entityName
          withUniqueAttributeName:(NSString*)uniqueAttributeName
                withImportContext:(NSManagedObjectContext*)importContext;

@end
