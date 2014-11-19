//
//  BBTContent.h
//  BBTNewsClient
//
//  Created by Bill Bai on 11/19/14.
//  Copyright (c) 2014 BBT. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum : NSUInteger {
    BBTContentStatusDraft,
    BBTContentStatusWatingForReview,
    BBTContentStatusApproved,
    BBTContentStatusRejected,
    BBTContentStatusPublished,
    BBTContentStatusArchived
} BBTContentStatus;

typedef enum : NSUInteger {
    BBTContentTypeArticle,      // primitive
    BBTContentTypeAlbum,        // primitive
    BBTContentTypeVedio,        // primitive
    BBTContentTypeSpecial       // a special will contail some sub contents of type BBTContent
} BBTContentType;


@interface BBTContent : NSObject

@property (nonatomic, strong) NSString              *title;
@property (nonatomic, strong) NSString              *subTitle;
@property (nonatomic, strong) NSString              *contentDescription;
@property (nonatomic, strong) NSString              *headerImageURL;
@property (nonatomic, strong) NSString              *headerImageInfo;
@property (nonatomic)         BBTContentStatus      contentStatus;
@property (nonatomic)         BOOL                  onFocus;
@property (nonatomic)         BOOL                  onTimeline;
@property (nonatomic)         NSString              *bodyHTML;



@end
