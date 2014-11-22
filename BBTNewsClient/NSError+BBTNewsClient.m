//
//  NSError+BBTNewsClient.m
//  BBTNewsClient
//
//  Created by Bill Bai on 11/22/14.
//  Copyright (c) 2014 BBT. All rights reserved.
//

#import "NSError+BBTNewsClient.h"

@implementation NSError (BBTNewsClient)
+ (NSError *)errorWithMessage:(NSString *)message
{
    return [NSError errorWithDomain:@"com.bbt.bbtnewsclient" code:2 userInfo:@{@"message": message}];
}
@end
