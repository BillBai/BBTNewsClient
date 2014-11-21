//
//  BBTHTTPOperationManager.m
//  BBTNewsClient
//
//  Created by Bill Bai on 11/22/14.
//  Copyright (c) 2014 BBT. All rights reserved.
//

#import "BBTHTTPOperationManager.h"

const NSString* kTestAPIBaseURL = @"http://api.bbtnewskit-test.com:3000/v1/";

@implementation BBTHTTPOperationManager

- (instancetype)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    
    if (self) {
        self.responseSerializer = [[AFJSONResponseSerializer alloc] init];
    }
    
    return self;
}

- (void)getContentsForSection:(NSNumber *)sectionID
                    Publisher:(NSNumber *)publisherID
                      onFocus:(BOOL)onFocus
                   onTimeline:(BOOL)onTimeline
                  contentType:(BBTContentType)contentType
                      sinceID:(NSNumber *)sinceID
                        maxID:(NSNumber *)maxID
                        count:(NSNumber *)count
                      success:(void (^) ( AFHTTPRequestOperation *operation , id responseObject ))success
                        failure:(void (^) ( AFHTTPRequestOperation *operation , NSError *error ))failure
{
    [self GET:@"contents" parameters:@"" success:success failure:failure];
}

@end
