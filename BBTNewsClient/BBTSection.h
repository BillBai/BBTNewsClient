//
//  BBTSection.h
//  BBTNewsClient
//
//  Created by Bill Bai on 11/19/14.
//  Copyright (c) 2014 BBT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface BBTSection : NSManagedObject

@property (nonatomic, retain) NSNumber * active;
@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) id headerImageURL;
@property (nonatomic, retain) NSString * module;
@property (nonatomic, retain) id sectionIconURL;
@property (nonatomic, retain) NSNumber * sectionID;
@property (nonatomic, retain) NSSet *contents;
@end

@interface BBTSection (CoreDataGeneratedAccessors)

- (void)addContentsObject:(NSManagedObject *)value;
- (void)removeContentsObject:(NSManagedObject *)value;
- (void)addContents:(NSSet *)values;
- (void)removeContents:(NSSet *)values;

@end
