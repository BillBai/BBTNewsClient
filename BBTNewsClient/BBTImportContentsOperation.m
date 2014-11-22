
//
//  BBTImportContentsOperation.m
//  BBTNewsClient
//
//  Created by Bill Bai on 11/22/14.
//  Copyright (c) 2014 BBT. All rights reserved.
//

#import "BBTImportContentsOperation.h"
#import "BBTContent+BBTImportOperation.h"

typedef void (^success_block_t)(NSArray *results);

@interface BBTImportContentsOperation()
@property (nonatomic, strong) NSManagedObjectContext *privateManagedObjectContext;
@property (copy) success_block_t successBlock;
@property (nonatomic, strong) NSArray *contents; // of NSDictionary
@end

@implementation BBTImportContentsOperation
- (instancetype)initWithContents:(NSArray *)contents // of NSDictionary
                         success:(void (^)(NSArray *results))successBlock
{
    self = [super init];
    
    if (self) {
        _contents = contents;
        _successBlock = successBlock;
    }
    
    return self;
}

- (void)main
{
    self.privateManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    self.privateManagedObjectContext.undoManager = nil;
    self.privateManagedObjectContext.parentContext = self.mainManagedObjectContext;
    
    //create the content id array
    NSMutableArray *contentIDs = [NSMutableArray arrayWithCapacity:[self.contents count]];
    for (NSDictionary *content in self.contents) {
        [contentIDs addObject:content[@"id"]];
    }
    
    // create the fetch request to get all BBTContent matching the IDs
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:
     [NSEntityDescription entityForName:@"BBTContent" inManagedObjectContext:self.privateManagedObjectContext]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(contentID IN %@)", contentIDs]];
    [fetchRequest setSortDescriptors:@[ [[NSSortDescriptor alloc] initWithKey:@"contentID" ascending:YES] ]];
    
    // Execute the fetch.
    NSError *error;
    NSArray *contentsMatchingIDs = [self.privateManagedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    NSEntityDescription *contentEntity = [NSEntityDescription entityForName:@"BBTContent" inManagedObjectContext:self.privateManagedObjectContext];
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:[self.contents count]];
    if ([contentsMatchingIDs count] > 0) {
        NSLog(@"merge content into core data");
        NSUInteger j = 0; // index for contentsMatchingIDs
        NSUInteger i = 0; // index for self.contents
        for (i = 0; i < [self.contents count] && j < [contentsMatchingIDs count]; i++) {
            if (![[(BBTContent *)(contentsMatchingIDs[j]) contentID]  isEqualToNumber:self.contents[i][@"id"]]) {
                // if the content does not exist, creat one.
                NSLog(@"content: %@ not in cache, merging...", self.contents[i][@"id"]);
                BBTContent *newContent = [[BBTContent alloc] initWithEntity:contentEntity insertIntoManagedObjectContext:self.privateManagedObjectContext];
                [newContent loadFromDictionary:self.contents[i]];
                [results addObject:[newContent objectID]];
            } else {
                // if exist, update it.
                NSLog(@"content: %@  in cache, updating...", self.contents[i][@"id"]);
                [(BBTContent *)contentsMatchingIDs[j] loadFromDictionary:self.contents[i]];
                [results addObject:[(BBTContent *)contentsMatchingIDs[j] objectID]];
                j++;
            }
        }
        
        if (i < [self.contents count]) {
            for (; i < [self.contents count]; i++) {
                NSLog(@"content: %@ not in cache, merging...", self.contents[i][@"id"]);
                BBTContent *newContent = [[BBTContent alloc] initWithEntity:contentEntity insertIntoManagedObjectContext:self.privateManagedObjectContext];
                [newContent loadFromDictionary:self.contents[i]];
                [results addObject:[newContent objectID]];
            }
        }
    } else {
        NSLog(@"write content into core data");
        for (NSDictionary *content in self.contents) {
            BBTContent *newContent = [[BBTContent alloc] initWithEntity:contentEntity insertIntoManagedObjectContext:self.privateManagedObjectContext];
            [newContent loadFromDictionary:content];
            [results addObject:[newContent objectID]];
        }
    }
    
    
    if ([self.privateManagedObjectContext hasChanges]) {
        NSError *error = nil;
        [self.privateManagedObjectContext save:&error];
        if (error) {
            NSLog(@"privateManagedObjectContext save ERROR !!!%@", error.localizedDescription);
        }
    }
    
    // break the strong trference cycles
    for (NSManagedObjectID *objectID in results) {
        [self.privateManagedObjectContext refreshObject:[self.privateManagedObjectContext objectWithID:objectID] mergeChanges:NO];
    }
    
    self.successBlock(results);
}

@end
