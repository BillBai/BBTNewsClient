//
//  BBTNewsClient.m
//  BBTNewsClient
//
//  Created by Bill Bai on 11/21/14.
//  Copyright (c) 2014 BBT. All rights reserved.
//

#import "BBTNewsClient.h"
#import "BBTFetchContentListOperation.h"
#import "BBTImportContentsOperation.h"
#import "BBTHTTPSessionManager.h"


typedef void (^success_block_t)(NSArray *results);
typedef void (^error_block_t)(NSError *error);

@interface BBTNewsClient()

@property (nonatomic) BOOL isOnline;
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@end


@implementation BBTNewsClient


- (NSOperationQueue *)operationQueue
{
    if (!_operationQueue) {
        _operationQueue = [[NSOperationQueue alloc] init];
    }
    
    return _operationQueue;
}


+ (instancetype)sharedNewsClient
{
    static BBTNewsClient *_sharedClient;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[BBTNewsClient alloc] init];
    });
    
    return _sharedClient;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        _isOnline = YES;
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
        [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            NSLog(@"Network Reachability changed: %@", AFStringFromNetworkReachabilityStatus(status));
            self.isOnline = (status == AFNetworkReachabilityStatusNotReachable) ? NO : YES;
        }];
    }
    
    return self;
}


- (void)getContent:(NSNumber *)contentID
           success:(void (^)(BBTContent *))successBlock
             error:(void (^)(NSError *))errorBlock
{
    [[BBTHTTPSessionManager sharedManager] getContent:contentID
                                              succeed:^(NSDictionary *contentDict) {
                                                  NSLog(@"log contentDict news client: success!!! %@", contentDict);
                                                  successBlock(nil);
                                              }
                                                error:^(NSError *error) {
                                                    NSLog(@"log from news client: ERROR!!! %@", error.localizedDescription);
                                                    errorBlock(error);
                                                }];

}


- (void)getContentsForPublisher:(NSNumber *)publisherID
                        onFocus:(BOOL)onFocus
                     onTimeline:(BOOL)onTimeline
                    contentType:(BBTContentType)contentType
                        sinceID:(NSNumber *)sinceID
                          maxID:(NSNumber *)maxID
                          count:(NSNumber *)count
                        success:(void (^)(NSArray *results))successBlock // of BBTContent
                          error:(void (^)(NSError *error))errorBlock;
{
    if (self.isOnline) {
        success_block_t successBlockForNetWork  = ^(NSArray *results) {
            //NSLog(@"log from news client: network success!!! %@", results);
            // import the results (of NSDictionarys) to Core Data
            BBTImportContentsOperation *operation = [[BBTImportContentsOperation alloc] initWithContents:results success:^(NSArray *contentIDs) {
                NSMutableArray *fetchedContents = [NSMutableArray arrayWithCapacity:[contentIDs count]];
                for (NSManagedObjectID *contentID in contentIDs) {
                    [fetchedContents addObject:[self.mainManagedObjectContext objectWithID:contentID]];
                }
                successBlock([fetchedContents copy]);
            }];
            operation.mainManagedObjectContext = self.mainManagedObjectContext;
            [self.operationQueue addOperation:operation];
        };
        
        error_block_t errorBlockForNetWork = ^(NSError *networkError) {
            NSLog(@"log from news client: network ERROR!!! %@", networkError.localizedDescription);
            // cannot get contents from network, try the core data
            BBTFetchContentListOperation *operation =
            [[BBTFetchContentListOperation alloc] initWithPublisher:publisherID
                                                            onFocus:onFocus
                                                         onTimeline:onTimeline
                                                        contentType:contentType
                                                            sinceID:sinceID
                                                              maxID:maxID
                                                              count:count
                                                            success:^(NSArray *contentIDs){
                                                                successBlock(contentIDs); // did get contents from core  data
                                                            }
                                                              error:^(NSError *error){
                                                                  errorBlock(error);    // error happened!
                                                              }];
            operation.mainManagedObjectContext = self.mainManagedObjectContext;
            [self.operationQueue addOperation:operation];
        };
        
        [[BBTHTTPSessionManager sharedManager] getContentsForPublisher:publisherID
                                                               onFocus:onFocus
                                                            onTimeline:onTimeline
                                                           contentType:contentType
                                                               sinceID:sinceID
                                                                 maxID:maxID
                                                                 count:count
                                                               success:successBlockForNetWork
                                                                 error:errorBlockForNetWork];
    } else {
        NSOperation *operation =
        [[BBTFetchContentListOperation alloc] initWithPublisher:publisherID
                                                        onFocus:onFocus
                                                     onTimeline:onTimeline
                                                    contentType:contentType
                                                        sinceID:sinceID
                                                          maxID:maxID
                                                          count:count
                                                        success:^(NSArray *contentIDs){
                                                            successBlock(contentIDs); // did get contents from core  data
                                                        }
                                                          error:^(NSError *error){
                                                              errorBlock(error);    // error happened!
                                                          }];
        [self.operationQueue addOperation:operation];
    }
    
}

- (void)getSubcontentsForContent:(NSNumber *)contentID
                         success:(void (^)(NSArray *))successBlock
                           error:(void (^)(NSError *))errorBlock
{

}

#pragma mark - Core Data stack

@synthesize mainManagedObjectContext = _mainManagedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory
{
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.bbt.BBTNewsClient" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel
{
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"BBTNewsClient" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"BBTNewsClient.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)mainManagedObjectContext
{
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_mainManagedObjectContext != nil) {
        return _mainManagedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _mainManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_mainManagedObjectContext setPersistentStoreCoordinator:coordinator];
    return _mainManagedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext
{
    NSManagedObjectContext *managedObjectContext = self.mainManagedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        NSLog(@"saved");
    }
}

@end
