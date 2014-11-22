//
//  BBTImportContentOperation.h
//  BBTNewsClient
//
//  Created by Bill Bai on 11/22/14.
//  Copyright (c) 2014 BBT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBTContent+BBTImportOperation.h"

@interface BBTImportContentOperation : NSOperation

@property (nonatomic, strong) NSManagedObjectContext *mainManagedObjectContext;

- (instancetype)initWithContents:(NSDictionary *)content
                         success:(void (^)(NSManagedObjectID *result))successBlock;

@end
