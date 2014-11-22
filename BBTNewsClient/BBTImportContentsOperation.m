
//
//  BBTImportContentsOperation.m
//  BBTNewsClient
//
//  Created by Bill Bai on 11/22/14.
//  Copyright (c) 2014 BBT. All rights reserved.
//

#import "BBTImportContentsOperation.h"
#import "BBTContent+BBTImportOperation.h"
#import "BBTPublisher.h"
#import "BBTSection.h"
#import "BBTAuthor.h"

extern uint64_t dispatch_benchmark(size_t count, void (^block)(void));

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
    uint64_t t = dispatch_benchmark(1, ^(void) {
        self.privateManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        self.privateManagedObjectContext.undoManager = nil;
        self.privateManagedObjectContext.parentContext = self.mainManagedObjectContext;
        
        //create the content id array
        NSUInteger count = [self.contents count];
        NSMutableArray *contentIDs = [NSMutableArray arrayWithCapacity:count];
        NSMutableArray *authorIDs = [NSMutableArray arrayWithCapacity:count];
        NSMutableArray *sectionIDs = [NSMutableArray arrayWithCapacity:count];
        NSMutableArray *publisherIDs = [NSMutableArray arrayWithCapacity:count];
        for (NSDictionary *content in self.contents) {
            [contentIDs addObject:content[@"id"]];
            [authorIDs addObject:content[@"author"][@"id"]];
            [sectionIDs addObject:content[@"section"][@"id"]];
            [publisherIDs addObject:content[@"publisher"][@"id"]];
        }
        
        // create the fetch request to get all BBTPublisher matching the IDs
        NSFetchRequest *publisherFetchRequest = [[NSFetchRequest alloc] init];
        [publisherFetchRequest setEntity:
         [NSEntityDescription entityForName:@"BBTPublisher" inManagedObjectContext:self.privateManagedObjectContext]];
        [publisherFetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(publisherID IN %@)", publisherIDs]];
        [publisherFetchRequest setSortDescriptors:@[ [[NSSortDescriptor alloc] initWithKey:@"publisherID" ascending:YES] ]];
        
        // create the fetch request to get all BBTSection matching the IDs
        NSFetchRequest *sectionFetchRequest = [[NSFetchRequest alloc] init];
        [sectionFetchRequest setEntity:
         [NSEntityDescription entityForName:@"BBTSection" inManagedObjectContext:self.privateManagedObjectContext]];
        [sectionFetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(sectionID IN %@)", sectionIDs]];
        [sectionFetchRequest setSortDescriptors:@[ [[NSSortDescriptor alloc] initWithKey:@"sectionID" ascending:YES] ]];
        
        // create the fetch request to get all BBTAuthor matching the IDs
        NSFetchRequest *authorFetchRequest = [[NSFetchRequest alloc] init];
        [authorFetchRequest setEntity:
         [NSEntityDescription entityForName:@"BBTAuthor" inManagedObjectContext:self.privateManagedObjectContext]];
        [authorFetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(authorID IN %@)", authorIDs]];
        [authorFetchRequest setSortDescriptors:@[ [[NSSortDescriptor alloc] initWithKey:@"authorID" ascending:YES] ]];
        
        
        
        // fetch the publisher, section and the author, save them to corresponding cache.
        NSError *error;
        NSArray *publishersMatchingIDs = [self.privateManagedObjectContext executeFetchRequest:publisherFetchRequest error:&error];
        NSMutableDictionary *publisherIDcache = [NSMutableDictionary dictionaryWithCapacity:[publishersMatchingIDs count]];
        for (BBTPublisher *fetchedPublisher in publishersMatchingIDs) {
            publisherIDcache[fetchedPublisher.publisherID] = fetchedPublisher.objectID;
        }
        
        NSArray *sectionsMatchingIDs = [self.privateManagedObjectContext executeFetchRequest:sectionFetchRequest error:&error];
        NSMutableDictionary *sectionIDcache = [NSMutableDictionary dictionaryWithCapacity:[sectionsMatchingIDs count]];
        for (BBTSection *fetchedSection in sectionsMatchingIDs) {
            sectionIDcache[fetchedSection.sectionID] = fetchedSection.objectID;
        }
        
        NSArray *authorsMatchingIDs = [self.privateManagedObjectContext executeFetchRequest:authorFetchRequest error:&error];
        NSMutableDictionary *authorIDcache = [NSMutableDictionary dictionaryWithCapacity:[authorsMatchingIDs count]];
        for (BBTAuthor *fetchedAuthor in authorsMatchingIDs) {
            NSLog(@"%@",fetchedAuthor.authorID);
            authorIDcache[fetchedAuthor.authorID] = fetchedAuthor.objectID;
        }
        
        NSEntityDescription *publisherEntity = [NSEntityDescription entityForName:@"BBTPublisher" inManagedObjectContext:self.privateManagedObjectContext];
        NSEntityDescription *sectionEntity = [NSEntityDescription entityForName:@"BBTSection" inManagedObjectContext:self.privateManagedObjectContext];
        NSEntityDescription *authorEntity = [NSEntityDescription entityForName:@"BBTAuthor" inManagedObjectContext:self.privateManagedObjectContext];
        for (NSDictionary *content in self.contents) {
            if (!publisherIDcache[content[@"publisher"][@"id"]]) {
                NSLog(@"inserting new publisher %@", content[@"publisher"][@"id"]);
                BBTPublisher *newPublisher = [[BBTPublisher alloc] initWithEntity:publisherEntity insertIntoManagedObjectContext:self.privateManagedObjectContext];
                newPublisher.publisherID = content[@"publisher"][@"id"];
                newPublisher.name = content[@"publisher"][@"name"];
                publisherIDcache[newPublisher.publisherID] = newPublisher.objectID;
            }
            if (!sectionIDcache[content[@"section"][@"id"]]) {
                NSLog(@"inserting new section %@", content[@"section"][@"id"]);
                BBTSection *newSection = [[BBTSection alloc] initWithEntity:sectionEntity insertIntoManagedObjectContext:self.privateManagedObjectContext];
                newSection.sectionID = content[@"section"][@"id"];
                newSection.module = content[@"section"][@"module"];
                newSection.category = content[@"section"][@"category"];
                sectionIDcache[newSection.sectionID] = newSection.objectID;
            }
            if (!authorIDcache[content[@"author"][@"id"]]) {
                NSLog(@"inserting new author %@", content[@"author"][@"id"]);
                BBTAuthor *newAuthor = [[BBTAuthor alloc] initWithEntity:authorEntity insertIntoManagedObjectContext:self.privateManagedObjectContext];
                newAuthor.authorID = content[@"author"][@"id"];
                newAuthor.name = content[@"author"][@"name"];
                //newAuthor.displayName = content[@"author"][@"display_name"];
                authorIDcache[newAuthor.authorID] = newAuthor.objectID;
            }
        }
        
        // create the fetch request to get all BBTContent matching the IDs
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:
         [NSEntityDescription entityForName:@"BBTContent" inManagedObjectContext:self.privateManagedObjectContext]];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(contentID IN %@)", contentIDs]];
        [fetchRequest setSortDescriptors:@[ [[NSSortDescriptor alloc] initWithKey:@"contentID" ascending:YES] ]];
        
        // Execute the fetch.
        NSArray *contentsMatchingIDs = [self.privateManagedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        
        // merge fetched content with the content dictionary from API
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
                    NSManagedObjectID *publisherID = publisherIDcache[self.contents[i][@"publisher"][@"id"]];
                    BBTPublisher *thePublisher = (BBTPublisher *)[self.privateManagedObjectContext objectWithID:publisherID];
                    newContent.publisher = thePublisher;
                    NSManagedObjectID *sectionID = sectionIDcache[self.contents[i][@"section"][@"id"]];
                    BBTSection *theSection = (BBTSection *)[self.privateManagedObjectContext objectWithID:sectionID];
                    newContent.section = theSection;
                    NSManagedObjectID *authorID = authorIDcache[self.contents[i][@"author"][@"id"]];
                    BBTAuthor *theAuthor = (BBTAuthor *)[self.privateManagedObjectContext objectWithID:authorID];
                    newContent.author = theAuthor;
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
                    NSManagedObjectID *publisherID = publisherIDcache[self.contents[i][@"publisher"][@"id"]];
                    BBTPublisher *thePublisher = (BBTPublisher *)[self.privateManagedObjectContext objectWithID:publisherID];
                    newContent.publisher = thePublisher;
                    NSManagedObjectID *sectionID = sectionIDcache[self.contents[i][@"section"][@"id"]];
                    BBTSection *theSection = (BBTSection *)[self.privateManagedObjectContext objectWithID:sectionID];
                    newContent.section = theSection;
                    NSManagedObjectID *authorID = authorIDcache[self.contents[i][@"author"][@"id"]];
                    BBTAuthor *theAuthor = (BBTAuthor *)[self.privateManagedObjectContext objectWithID:authorID];
                    newContent.author = theAuthor;
                    [results addObject:[newContent objectID]];
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
        
        // save changes, the changes will automatically merge into the parent object context
        if ([self.privateManagedObjectContext hasChanges]) {
            NSError *error = nil;
            [self.privateManagedObjectContext save:&error];
            if (error) {
                NSLog(@"privateManagedObjectContext save ERROR !!!%@", error.localizedDescription);
            }
        }
        
        // save the main object context on main thread
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            NSError *error;
            [self.mainManagedObjectContext save:&error];
            if (error) {
                NSLog(@"mainManagedObjectContext save gor ERROR !!! %@", error.localizedDescription);
            }
            NSLog(@"mainManagedObjectContext did save");
        });
        
        // break the strong reference cycles
        for (NSManagedObjectID *objectID in results) {
            [self.privateManagedObjectContext refreshObject:[self.privateManagedObjectContext objectWithID:objectID] mergeChanges:NO];
        }
        
        // call the success callback on main thread.
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            self.successBlock(results);
        });
    });
    
    NSLog(@"excute time %llu ms", t / 1000000);
}

@end
