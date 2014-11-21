//
//  BBTFetchContentListOperation.m
//  BBTNewsClient
//
//  Created by Bill Bai on 11/22/14.
//  Copyright (c) 2014 BBT. All rights reserved.
//

#import "BBTFetchContentListOperation.h"
#import <AFNetworking/AFNetworking.h>
#import "BBTHTTPOperationManager.h"


typedef void (^success_block_t)(NSArray *result);
typedef void (^error_block_t)(NSError *error);

@interface BBTFetchContentListOperation()

@property (nonatomic, strong) NSManagedObjectContext *privateManagedObjectContext;
@property (nonatomic) BOOL online;

@property (nonatomic, strong) NSNumber *sectionID;
@property (nonatomic, strong) NSNumber *publisherID;
@property (nonatomic, strong) NSNumber *sinceID;
@property (nonatomic, strong) NSNumber *maxID;
@property (nonatomic, strong) NSNumber *count;
@property (nonatomic) BOOL onFocus;
@property (nonatomic) BOOL onTimeline;
@property (nonatomic) BBTContentType contentType;
@property (copy) success_block_t successBlock;
@property (copy) error_block_t errorBlock;

@end


@implementation BBTFetchContentListOperation

- (instancetype)initWithMainManagedObjectContext:(NSManagedObjectContext *)mainObjectContext
                                          online:(BOOL)online
                                         Section:(NSNumber *)sectionID
                                       Publisher:(NSNumber *)publisherID
                                         onFocus:(BOOL)onFocus
                                      onTimeline:(BOOL)onTimeline
                                     contentType:(BBTContentType)contentType
                                         sinceID:(NSNumber *)sinceID
                                           maxID:(NSNumber *)maxID
                                           count:(NSNumber *)count
                                         success:(void (^)(NSArray *))successBlock
                                           error:(void (^)(NSError *))errorBlock
{
    self = [super init];
    if (self) {
        self.mainManagedObjectContext = mainObjectContext;
        self.online = online;
        self.successBlock = successBlock;
        self.errorBlock = errorBlock;
        self.sectionID = sectionID;
        self.publisherID = publisherID;
        self.onFocus = onFocus;
        self.onTimeline = onTimeline;
        self.sinceID = sinceID;
        self.maxID = maxID;
        self.count = count;
    }
    
    return self;
}


- (void)main
{
    self.privateManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    
    [self.privateManagedObjectContext setParentContext:self.mainManagedObjectContext];
    
    
    // Detect the network reachability
    if (self.online) { // If online, try to get the content list from the API first
        NSLog(@"getting contents from network");
        BBTHTTPOperationManager *manager = [[BBTHTTPOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://api.bbtnewskit-test.com:3000/v1/"]];
        [manager getContentsForSection:self.sectionID
                             Publisher:self.publisherID
                               onFocus:self.onFocus
                            onTimeline:self.onTimeline
                           contentType:self.contentType
                               sinceID:self.sinceID
                                 maxID:self.maxID
                                 count:self.count
                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                   NSLog(@"log from fetch operation: %@", responseObject);
                                   dispatch_async(dispatch_get_main_queue(), ^(void) {
                                       self.successBlock(responseObject);
                                   });
                               }
                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                   NSLog(@"log from fetch operation: %@", error.localizedDescription);
                                   dispatch_async(dispatch_get_main_queue(), ^(void) {
                                       self.errorBlock(error);
                                   });
                               }];
    } else {    // if thers is no network connection, just get the content list from the core data.
        
    }
    
}

@end
