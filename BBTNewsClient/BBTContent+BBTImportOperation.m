//
//  BBTContent+BBTImportOperation.m
//  BBTNewsClient
//
//  Created by Bill Bai on 11/22/14.
//  Copyright (c) 2014 BBT. All rights reserved.
//

#import "BBTContent+BBTImportOperation.h"

@implementation BBTContent (BBTImportOperation)

+ (NSDateFormatter *)dateFormatter
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZ";
    return dateFormatter;
}

- (void)loadFromDictionary:(NSDictionary *)dictionary
{
    self.contentID = dictionary[@"id"];
    [self setContentTypeRaw:[BBTContent contentTypeFromString:dictionary[@"content_type"]]];
    [self setContentStatusRaw:BBTContentStatusPublished];
    self.onFocus = dictionary[@"on_focus"];
    self.onTimeline = dictionary[@"display_on_timeline"];
    self.title = dictionary[@"title"];
    self.thumbImageURL = [NSURL URLWithString:(NSString *)dictionary[@"trumb_image_url"]];
    self.contentDescription = dictionary[@"description"];
    self.createdAt = [[BBTContent dateFormatter] dateFromString:dictionary[@"created_at"]];
    self.updatedAt = [[BBTContent dateFormatter] dateFromString:dictionary[@"updated_at"]];
}


@end
