//
//  RHDataAgent.h
//  RHParrotDataDemo
//
//  Created by Hanran Liu on 15/1/17.
//  Copyright (c) 2015年 ran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RHQuery.h"
#import "RHDatabaseManager.h"

@interface RHDataAgent : NSObject

@property (nonatomic, readonly) RHDatabaseManager *dbManager;
@property (nonatomic, readonly) NSManagedObjectContext *mainManagedObjectContext;
@property (nonatomic, readonly) NSManagedObjectContext *backgroundManagedObjectContext;

@property (nonatomic, assign) BOOL trackLogging;      //default NO;

//create instance;
+ (void)setupAgentWithMomdFile:(NSURL *)momdURL andStoreURL:(NSURL *)storeURL;
//retrive
+ (instancetype)agent;

//C.R.U.D
- (void)commit;

- (void)deleteObject:(NSManagedObject *)object;
- (void)deleteObjects:(NSArray *)objects;

- (id)excuteQuery:(RHQuery *)query;

//Cached Query
- (void)cachedQuery:(RHQuery *)query withKey:(NSString *)queryKey;
- (void)removeCachedQueryForKey:(NSString *)queryKey;
- (RHQuery *)cachedQueryForKey:(NSString *)queryKey;

//Undo Management
- (void)undo;
- (void)redo;
- (void)rollback;
- (void)reset;

//Memory Management
- (void)reduceMemory;

@end
