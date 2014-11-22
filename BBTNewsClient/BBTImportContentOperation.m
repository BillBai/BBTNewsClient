//
//  BBTImportContentOperation.m
//  BBTNewsClient
//
//  Created by Bill Bai on 11/22/14.
//  Copyright (c) 2014 BBT. All rights reserved.
//

#import "BBTImportContentOperation.h"
#import "BBTContent+BBTImportOperation.h"
#import "BBTPhoto.h"

extern uint64_t dispatch_benchmark(size_t count, void (^block)(void));

typedef void (^success_bloc_t)(NSManagedObjectID *result);

@interface BBTImportContentOperation()
@property (nonatomic, strong) NSManagedObjectContext *privateManagedObjectContext;
@property (copy) success_bloc_t successBlock;
@property (nonatomic, strong) NSDictionary *content;
@end

@implementation BBTImportContentOperation

- (instancetype)initWithContents:(NSDictionary *)content success:(void (^)(NSManagedObjectID *))successBlock
{
    self = [super init];
    if (self) {
        _successBlock = successBlock;
        _content = content;
    }
    
    return self;
}

- (void)main
{
    uint64_t t = dispatch_benchmark(1, ^(void) {
        self.privateManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        self.privateManagedObjectContext.undoManager = nil;
        self.privateManagedObjectContext.parentContext = self.mainManagedObjectContext;
        
        NSMutableArray *contentPhotos;
        if ([BBTContent contentTypeFromString:self.content[@"content_type"]] == BBTContentTypeAlbum) {
            NSUInteger photoCount = [(NSArray *)self.content[@"photos"] count];
            
            // get the photo IDs
            NSMutableArray *photoIDs = [NSMutableArray arrayWithCapacity:photoCount];
            for (NSDictionary *photoDictionary in self.content[@"photos"]) {
                [photoIDs addObject:photoDictionary[@"id"]];
            }
            NSLog(@"photo ids %@", photoIDs);
            
            // fetch the photos within the photo ids
            NSEntityDescription *photoEntity = [NSEntityDescription entityForName:@"BBTPhoto" inManagedObjectContext:self.privateManagedObjectContext];
            NSFetchRequest *photoRequest = [[NSFetchRequest alloc] init];
            [photoRequest setEntity:photoEntity];
            [photoRequest setPredicate:[NSPredicate predicateWithFormat:@"(photoID IN %@)", photoIDs]];
            [photoRequest setSortDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"photoID" ascending:YES] ]];
            
            //execute the fetch
            NSError *error;
            NSArray *fetchedPhotosMetchingIDs = [self.privateManagedObjectContext executeFetchRequest:photoRequest error:&error];
            
            // merge the content[@"photos"] with the fetched photos
            contentPhotos = [NSMutableArray arrayWithCapacity:photoCount];
            if ([fetchedPhotosMetchingIDs count] > 0) {
                NSLog(@"merge photos into core data");
                NSUInteger j = 0; // index for fetchedPhotosMetchingIDs
                NSUInteger i = 0; // index for content.photos
                for (i = 0; i < photoCount && j < [fetchedPhotosMetchingIDs count]; i++) {
                    NSDictionary *thisPhoto = self.content[@"photos"][i];
                    if (![[(BBTPhoto *)(fetchedPhotosMetchingIDs[j]) photoID]  isEqualToNumber:thisPhoto[@"id"]]) {
                        // if the content does not exist, creat one.
                        NSLog(@"photo: %@ not in cache, merging...", thisPhoto[@"id"]);
                        BBTPhoto *newPhoto = [[BBTPhoto alloc] initWithEntity:photoEntity insertIntoManagedObjectContext:self.privateManagedObjectContext];
                        newPhoto.photoDescription = thisPhoto[@"description"];
                        newPhoto.photographer = thisPhoto[@"photographer"];
                        newPhoto.title = thisPhoto[@"title"];
                        newPhoto.imageURL = [NSURL URLWithString:thisPhoto[@"image_url"]];
                        newPhoto.photoID = thisPhoto[@"id"];
                        [contentPhotos addObject:newPhoto];
                    } else {
                        // if exist, update it.
                        NSLog(@"photo: %@  in cache, updating...", self.content[@"photos"][i][@"id"]);
                        [contentPhotos addObject:fetchedPhotosMetchingIDs[j]];
                        j++;
                    }
                }
                if (i < photoCount) {
                    for (; i < photoCount; i++) {
                        NSDictionary *thisPhoto = self.content[@"photos"][i];
                        NSLog(@"photo: %@ not in cache, merging...", thisPhoto[@"id"]);
                        BBTPhoto *newPhoto = [[BBTPhoto alloc] initWithEntity:photoEntity insertIntoManagedObjectContext:self.privateManagedObjectContext];
                        newPhoto.photoDescription = thisPhoto[@"description"];
                        newPhoto.photographer = thisPhoto[@"photographer"];
                        newPhoto.title = thisPhoto[@"title"];
                        newPhoto.imageURL = [NSURL URLWithString:thisPhoto[@"image_url"]];
                        newPhoto.photoID = thisPhoto[@"id"];
                        [contentPhotos addObject:newPhoto];
                    }
                }

            } else {
                NSLog(@"write photos into core data");
                for (NSDictionary *photo in self.content[@"photos"]) {
                    BBTPhoto *newPhoto = [[BBTPhoto alloc] initWithEntity:photoEntity insertIntoManagedObjectContext:self.privateManagedObjectContext];
                    newPhoto.photoDescription = photo[@"description"];
                    newPhoto.photographer = photo[@"photographer"];
                    newPhoto.title = photo[@"title"];
                    newPhoto.imageURL = [NSURL URLWithString:photo[@"image_url"]];
                    newPhoto.photoID = photo[@"id"];
                    [contentPhotos addObject:newPhoto];
                }
            }
        }
        
        
        // fetch the content
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *contentEntity = [NSEntityDescription entityForName:@"BBTContent" inManagedObjectContext:self.privateManagedObjectContext];
        [fetchRequest setEntity:contentEntity];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(contentID = %@)", self.content[@"id"]]];
        
        // execute the fetch
        NSError *error;
        NSArray *fetchedContent = [self.privateManagedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (error) {
            NSLog(@"fetch content ERROR!!!! %@", error.localizedDescription);
        }
        NSLog(@"fetched content %@", fetchedContent);
        
        // set up the photos relationship and update the content
        BBTContent *content;
        if ([fetchedContent count] > 0) {
            NSLog(@"content fetched setting photos relations");
            content = fetchedContent[0];
            [content loadFromFullDictionary:self.content];
            if ([BBTContent contentTypeFromString:self.content[@"content_type"]] == BBTContentTypeAlbum) {
                [content setValue:[NSSet setWithArray:contentPhotos] forKey:@"photos"];
            }
        } else {
            // if not exist, make a new content
            NSLog(@"content not fetched, make a new one and set the photos relations");
            content = [[BBTContent alloc] initWithEntity:contentEntity insertIntoManagedObjectContext:self.privateManagedObjectContext];
            [content loadFromFullDictionary:self.content];
            if ([BBTContent contentTypeFromString:self.content[@"content_type"]] == BBTContentTypeAlbum) {
                [content setValue:[NSSet setWithArray:contentPhotos] forKey:@"photos"];
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
        
        // break the strong reference cycle
        [self.privateManagedObjectContext refreshObject:content mergeChanges:NO];
        
        // call the success callback on main thread.
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            self.successBlock([content objectID]);
        });
    });
    
    NSLog(@"excute import content time: %llu ms", t / 1000000);
}


@end
