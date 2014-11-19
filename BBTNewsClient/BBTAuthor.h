//
//  BBTAuthor.h
//  BBTNewsClient
//
//  Created by Bill Bai on 11/19/14.
//  Copyright (c) 2014 BBT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface BBTAuthor : NSManagedObject

@property (nonatomic, retain) NSNumber * active;
@property (nonatomic, retain) NSNumber * authorID;
@property (nonatomic, retain) id avatarURL;
@property (nonatomic, retain) NSNumber * department;
@property (nonatomic, retain) NSString * displayName;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSOrderedSet *contents;
@end

@interface BBTAuthor (CoreDataGeneratedAccessors)

- (void)insertObject:(NSManagedObject *)value inContentsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromContentsAtIndex:(NSUInteger)idx;
- (void)insertContents:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeContentsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInContentsAtIndex:(NSUInteger)idx withObject:(NSManagedObject *)value;
- (void)replaceContentsAtIndexes:(NSIndexSet *)indexes withContents:(NSArray *)values;
- (void)addContentsObject:(NSManagedObject *)value;
- (void)removeContentsObject:(NSManagedObject *)value;
- (void)addContents:(NSOrderedSet *)values;
- (void)removeContents:(NSOrderedSet *)values;
@end
