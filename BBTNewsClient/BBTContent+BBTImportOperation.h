//
//  BBTContent+BBTImportOperation.h
//  BBTNewsClient
//
//  Created by Bill Bai on 11/22/14.
//  Copyright (c) 2014 BBT. All rights reserved.
//

#import "BBTContent.h"

@interface BBTContent (BBTImportOperation)

- (void)loadFromReducedDictionary:(NSDictionary *)dictionary;
- (void)loadFromFullDictionary:(NSDictionary *)dictionary;
@end
