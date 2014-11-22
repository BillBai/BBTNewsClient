//
//  BBTImportContentsOperation.h
//  BBTNewsClient
//
//  Created by Bill Bai on 11/22/14.
//  Copyright (c) 2014 BBT. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreData;

@interface BBTImportContentListOperation : NSOperation
@property (nonatomic, strong) NSManagedObjectContext *mainManagedObjectContext;

- (instancetype)initWithContents:(NSArray *)contents // of NSDictionary
                         success:(void (^)(NSArray *results))successBlock;
@end
