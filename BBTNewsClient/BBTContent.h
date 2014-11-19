//
//  BBTContent.h
//  BBTNewsClient
//
//  Created by Bill Bai on 11/19/14.
//  Copyright (c) 2014 BBT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BBTAuthor, BBTContent, BBTPhoto, BBTPublisher, BBTSection;

@interface BBTContent : NSManagedObject

@property (nonatomic, retain) NSString * bodyHTML;
@property (nonatomic, retain) NSString * contentDescription;
@property (nonatomic, retain) NSNumber * contentID;
@property (nonatomic, retain) NSNumber * contentStatus;
@property (nonatomic, retain) NSNumber * contentType;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * headerImageInfo;
@property (nonatomic, retain) id headerImageURL;
@property (nonatomic, retain) NSNumber * onFocus;
@property (nonatomic, retain) NSNumber * onTimeline;
@property (nonatomic, retain) NSString * subTitle;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) id vedioURL;
@property (nonatomic, retain) BBTAuthor *author;
@property (nonatomic, retain) BBTContent *parentContent;
@property (nonatomic, retain) NSSet *photos;
@property (nonatomic, retain) BBTPublisher *publisher;
@property (nonatomic, retain) BBTSection *section;
@property (nonatomic, retain) NSSet *subContents;
@end

@interface BBTContent (CoreDataGeneratedAccessors)

- (void)addPhotosObject:(BBTPhoto *)value;
- (void)removePhotosObject:(BBTPhoto *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;

- (void)addSubContentsObject:(BBTContent *)value;
- (void)removeSubContentsObject:(BBTContent *)value;
- (void)addSubContents:(NSSet *)values;
- (void)removeSubContents:(NSSet *)values;

@end
