//
//  BBTHTTPSessionManager.m
//  BBTNewsClient
//
//  Created by Bill Bai on 11/22/14.
//  Copyright (c) 2014 BBT. All rights reserved.
//

#import "BBTHTTPSessionManager.h"
#import "NSError+BBTNewsClient.h"

@implementation BBTHTTPSessionManager

+ (instancetype)sharedManager
{
    static BBTHTTPSessionManager *_sharedManager;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[BBTHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://api.bbtnewskit-test.com:3000/v1/"]
                                                   sessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    });
    
    return _sharedManager;
}

- (instancetype)initWithBaseURL:(NSURL *)url sessionConfiguration:(NSURLSessionConfiguration *)configuration
{
    self = [super initWithBaseURL:url sessionConfiguration:configuration];
    if (self) {
        self.responseSerializer = [[AFJSONResponseSerializer alloc] init];
    }
    
    return self;
}

- (void)getContentsForPublisher:(NSNumber *)publisherID
                        onFocus:(BOOL)onFocus
                     onTimeline:(BOOL)onTimeline
                    contentType:(BBTContentType)contentType
                        sinceID:(NSNumber *)sinceID
                          maxID:(NSNumber *)maxID
                          count:(NSNumber *)count
                        success:(void (^) (NSArray *result))successBlock
                          error:(void (^) (NSError *error ))errorBlock;
{
    [self GET:publisherID ? [NSString stringWithFormat:@"publishers/%@/contents", publisherID] : @"contents"
   parameters:[BBTHTTPSessionManager GETParametersForSinceID:sinceID
                                                       maxID:maxID
                                                       count:count
                                                     onFocus:onFocus
                                                  onTimeline:onTimeline
                                                 contentType:contentType]
      success:^(NSURLSessionDataTask *dataTask, id responseObject) {
          NSLog(@"log from HTTP session manager: Success!!! data task: %@", dataTask);
          if ([responseObject isKindOfClass:[NSDictionary class]]) {
              if ([responseObject[@"status"] isEqualToNumber:@(0)]) {
                  successBlock(responseObject[@"list"]);
              } else {
                  errorBlock([NSError errorWithMessage:responseObject[@"message"]]);
              }
          }
      }
      failure:^(NSURLSessionDataTask *dataTast, NSError *error) {
          NSLog(@"log from HTTP session manager: ERROR!!! data task: %@", dataTast);
          errorBlock(error);

      }];
}

- (void)getContent:(NSNumber *)contentID
           succeed:(void (^)(NSDictionary *))successBlock
             error:(void (^)(NSError *))errorBlock
{
    [self GET:[NSString stringWithFormat:@"contents/%@", contentID]
   parameters:nil
      success:^(NSURLSessionDataTask *dataTask, id responseObject) {
          NSLog(@"log from HTTP session manager: Success!!! data task: %@", dataTask);
          if ([responseObject isKindOfClass:[NSDictionary class]]) {
                successBlock(responseObject);
          }
          successBlock(@{});
      }
      failure:^(NSURLSessionDataTask *dataTask, NSError *error) {
          NSLog(@"log from HTTP session manager: ERROR!!! data task: %@", dataTask);
          errorBlock(error);
      }];
}

+ (NSDictionary *)GETParametersForSinceID:(NSNumber *)sinceID
                                    maxID:(NSNumber *)maxID
                                    count:(NSNumber *)count
                                  onFocus:(BOOL)onFocus
                               onTimeline:(BOOL)onTimeline
                              contentType:(BBTContentType)contentType
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (sinceID) { params[@"since_id"] = [sinceID stringValue]; }
    if (maxID) { params[@"max_id"] = [maxID stringValue]; }
    if (count) { params[@"count"] = [count stringValue]; }
    params[@"on_focus"] = onFocus ? @"true" : @"false";
    params[@"on_timeline"] = onTimeline ? @"true" : @"false";
    if (contentType != BBTContentTypeNone) {
        params[@"content_type"] = [BBTContent contentTypeString:contentType];
    }
    return [params copy];
}

@end
