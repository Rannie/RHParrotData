//
//  RHDataAgent.h
//  RHParrotDataDemo
//
//  Created by Hanran Liu on 15/1/17.
//  Copyright (c) 2015年 ran. All rights reserved.
//

#import "RHParrotMacro.h"

@class RHQuery;
@class RHDatabaseManager;
@class RHQueryResultController;

#define RHMainContext ([RHDataAgent agent].mainManagedObjectContext)
#define RHBackgroundContext ([RHDataAgent agent].backgroundManagedObjectContext)

@interface RHDataAgent : NSObject

/**
 *  Database manageder. see "RHDatabaseManager.h".
 */
@property (nonatomic, readonly) RHDatabaseManager *dbManager;

/**
 *  MainQueueConcurrencyType NSManagedObjectContext instance.
 */
@property (nonatomic, readonly) NSManagedObjectContext *mainManagedObjectContext;

/**
 *  PrivateQueueConcurrencyType NSManagedObjectContext instance.
 */
@property (nonatomic, readonly) NSManagedObjectContext *backgroundManagedObjectContext;

/**
 *  Track logs. Default is NO.
 */
@property (nonatomic, assign) BOOL trackLogging;

/**
 *  Create a shared instance with database required info.
 *
 *  @param momdURL  xcdatamodeld file path url
 *  @param storeURL sqlite path url
 */
+ (void)setupAgentWithMomdFile:(NSURL *)momdURL andStoreURL:(NSURL *)storeURL;

/**
 *  Singleton retrived.
 *
 *  @return the agent instance
 */
+ (instancetype)agent;

/**
 *  When you insert or update managed objects use this method.
 */
- (void)commit;

/**
 *  Delete a managed object.
 *
 *  @param object object to be deleted
 */
- (void)deleteObject:(NSManagedObject *)object;

/**
 *  Delete managed objects.
 *
 *  @param objects objects to be deleted
 */
- (void)deleteObjects:(NSArray *)objects;

/**
 *  Excute a query. also can use RHQuery method '- excute'.
 *
 *  @param query RHQuery instance
 *
 *  @return query result
 */
- (id)excuteQuery:(RHQuery *)query;

/**
 *  Drive a subclass of 'NSFetchResultController' instance to perfom fetch.
 *
 *  @param controller query result controller
 */
- (void)excuteQueryWithController:(RHQueryResultController *)controller;

/**
 *  Cached a query by a string identifier.
 *
 *  @param query    query want to be cached
 *  @param queryKey cache identifier
 */
- (void)cachedQuery:(RHQuery *)query withKey:(NSString *)queryKey;

/**
 *  Remove the cached query
 *
 *  @param queryKey cache identifier
 */
- (void)removeCachedQueryForKey:(NSString *)queryKey;

/**
 *  Get the cached query.
 *
 *  @param queryKey cache identifier
 *
 *  @return cached query instance
 */
- (RHQuery *)cachedQueryForKey:(NSString *)queryKey;

/**
 *  Undo command.
 */
- (void)undo;

/**
 *  Redo command.
 */
- (void)redo;

/**
 *  Rollback command.
 */
- (void)rollback;

/**
 *  Reset command.
 */
- (void)reset;

/**
 *  Reduce memory by clear query caches, undo stack and so on.
 */
- (void)reduceMemory;

@end
