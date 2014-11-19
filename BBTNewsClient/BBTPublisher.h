//
//  BBTPublisher.h
//  BBTNewsClient
//
//  Created by Bill Bai on 11/19/14.
//  Copyright (c) 2014 BBT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface BBTPublisher : NSManagedObject

@property (nonatomic, retain) NSNumber * active;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * publisherID;
@property (nonatomic, retain) NSSet *contents;
@end

@interface BBTPublisher (CoreDataGeneratedAccessors)

- (void)addContentsObject:(NSManagedObject *)value;
- (void)removeContentsObject:(NSManagedObject *)value;
- (void)addContents:(NSSet *)values;
- (void)removeContents:(NSSet *)values;

@end
