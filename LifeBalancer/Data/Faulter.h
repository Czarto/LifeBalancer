//
//  Faulter.h
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Faulter : NSObject

+ (void)faultObjectWithID:(NSManagedObjectID*)objectID
                inContext:(NSManagedObjectContext*)context;

@end
