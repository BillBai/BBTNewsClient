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
                                         success:(void (^)(NSArray *result))successBlock // of NSManagedObjectID
                                           error:(void (^)(NSError *error))errorBlock;

@end
