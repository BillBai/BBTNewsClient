//
//  BBTContent.m
//  BBTNewsClient
//
//  Created by Bill Bai on 11/19/14.
//  Copyright (c) 2014 BBT. All rights reserved.
//

#import "BBTContent.h"
#import "BBTAuthor.h"
#import "BBTContent.h"
#import "BBTPhoto.h"
#import "BBTPublisher.h"
#import "BBTSection.h"


@implementation BBTContent

@dynamic bodyHTML;
@dynamic contentDescription;
@dynamic contentID;
@dynamic contentStatus;
@dynamic contentType;
@dynamic createdAt;
@dynamic headerImageInfo;
@dynamic headerImageURL;
@dynamic onFocus;
@dynamic onTimeline;
@dynamic subTitle;
@dynamic title;
@dynamic updatedAt;
@dynamic vedioURL;
@dynamic author;
@dynamic parentContent;
@dynamic photos;
@dynamic publisher;
@dynamic section;
@dynamic subContents;

// Beacause we use Core Data and out contentType and contentStatus should be enum type,
// I made these fake properties to set and get contentType and contentStatus.
// Always use these method rather than `-(BBTContentType)contentType` and `-(void)setContentType:` .
- (BBTContentType)contentTypeRaw
{
    return (BBTContentType)[[self contentType] integerValue];
}

- (void)setContentTypeRaw:(BBTContentType)contentType
{
    [self setContentType:[NSNumber numberWithInteger:contentType]];
}

- (BBTContentStatus)contentStatusRaw
{
    return (BBTContentStatus)[[self contentStatus] integerValue];
}

- (void)setContentStatusRaw:(BBTContentStatus)contentStatus
{
    [self setContentStatus:[NSNumber numberWithInteger:contentStatus]];
}

+ (NSSet *)keyPathsForValuesAffectingContentTypeRaw
{
    return [NSSet setWithObject:@"contentType"];
}

+ (NSSet *)keyPathsForValuesAffectingContentStatusRaw
{
    return [NSSet setWithObject:@"contentStatus"];
}

@end
