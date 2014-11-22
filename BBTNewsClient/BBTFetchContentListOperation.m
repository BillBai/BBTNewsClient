//
//  BBTFetchContentListOperation.m
//  BBTNewsClient
//
//  Created by Bill Bai on 11/22/14.
//  Copyright (c) 2014 BBT. All rights reserved.
//

#import "BBTFetchContentListOperation.h"


typedef void (^success_block_t)(NSArray *result);
typedef void (^error_block_t)(NSError *error);

@interface BBTFetchContentListOperation()

@property (nonatomic, strong) NSManagedObjectContext *privateManagedObjectContext;

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
        self.successBlock = successBlock;
        self.errorBlock = errorBlock;
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
    
}

@end
