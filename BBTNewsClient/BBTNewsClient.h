//
//  BBTNewsClient.h
//  BBTNewsClient
//
//  Created by Bill Bai on 11/21/14.
//  Copyright (c) 2014 BBT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BBTContent.h"

@interface BBTNewsClient : NSObject

// the only managedObjectContext to maintain all the contents on main thread
@property (readonly, strong, nonatomic) NSManagedObjectContext *mainManagedObjectContext;

# pragma mark - Generic get content method
// get content list
- (void)getContentsForSection:(NSNumber *)sectionID
                    Publisher:(NSNumber *)publisherID
                      onFocus:(BOOL)onFocus
                   onTimeline:(BOOL)onTimeline
                  contentType:(BBTContentType)contentType
                      sinceID:(NSNumber *)sinceID
                        maxID:(NSNumber *)maxID
                      success:(void (^)(NSArray *results))successBlock // of BBTContent
                        error:(void (^)(NSError *error))errorBlock;
// get a single content
- (void)getContent:(NSNumber *)contentID
           success:(void (^)(BBTContent *content))successBlock
             error:(void (^)(NSError *error))errorBlock;

// get subcontent list for a content
- (void)getSubcontentsForContent:(NSNumber *)contentID
                         success:(void (^)(NSArray *results))successBlock // of BBTContent
                           error:(void (^)(NSError *error))errorBlock;

@end
