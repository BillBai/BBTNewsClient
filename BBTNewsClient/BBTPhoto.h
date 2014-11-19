//
//  BBTPhoto.h
//  BBTNewsClient
//
//  Created by Bill Bai on 11/19/14.
//  Copyright (c) 2014 BBT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface BBTPhoto : NSManagedObject

@property (nonatomic, retain) id imageURL;
@property (nonatomic, retain) NSString * photoDescription;
@property (nonatomic, retain) NSString * photographer;
@property (nonatomic, retain) NSNumber * photoID;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSManagedObject *content;

@end
