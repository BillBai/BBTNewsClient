//
//  BBTFetchContentListOperation.h
//  BBTNewsClient
//
//  Created by Bill Bai on 11/22/14.
//  Copyright (c) 2014 BBT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBTContent.h"

@import CoreData;

@interface BBTFetchContentListOperation : NSOperation

@property (nonatomic, strong) NSManagedObjectContext *mainManagedObjectContext;

- (instancetype)initWithPublisher:(NSNumber *)publisherID
                          onFocus:(BOOL)onFocus
                       onTimeline:(BOOL)onTimeline
                      contentType:(BBTContentType)contentType
                          sinceID:(NSNumber *)sinceID
                            maxID:(NSNumber *)maxID
                            count:(NSNumber *)count
                          success:(void (^)(NSArray *result))successBlock
                            error:(void (^)(NSError *error))errorBlock;

@end
