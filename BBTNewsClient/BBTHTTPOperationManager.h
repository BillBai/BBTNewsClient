//
//  BBTHTTPOperationManager.h
//  BBTNewsClient
//
//  Created by Bill Bai on 11/22/14.
//  Copyright (c) 2014 BBT. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"
#import "BBTContent.h"

@interface BBTHTTPOperationManager : AFHTTPRequestOperationManager

// get content list
- (void)getContentsForSection:(NSNumber *)sectionID
                    Publisher:(NSNumber *)publisherID
                      onFocus:(BOOL)onFocus
                   onTimeline:(BOOL)onTimeline
                  contentType:(BBTContentType)contentType
                      sinceID:(NSNumber *)sinceID
                        maxID:(NSNumber *)maxID
                        count:(NSNumber *)count
                      success:(void ( ^ ) ( AFHTTPRequestOperation *operation , id responseObject ))success
                      failure:(void ( ^ ) ( AFHTTPRequestOperation *operation , NSError *error ))failure;

@end
