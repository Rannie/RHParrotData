//
//  RHDataAgent.m
//  RHParrotDataDemo
//
//  Created by Hanran Liu on 15/1/17.
//  Copyright (c) 2015年 ran. All rights reserved.
//

#import "RHDataAgent.h"

@interface RHDataAgent ()
@property (nonatomic, readwrite) RHDatabaseManager  *dbManager;
@property (nonatomic, strong) NSMutableDictionary   *queryCache;
@property (nonatomic, strong) NSMutableString       *logText;
@end

@implementation RHDataAgent

#pragma mark - Initialization
static RHDataAgent *instance = nil;

+ (void)setupAgentWithMomdFile:(NSURL *)momdURL andStoreURL:(NSURL *)storeURL {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[self alloc] initWithMomdURL:momdURL storeURL:storeURL];
  });
}

+ (instancetype)agent {
  return instance;
}

- (instancetype)initWithMomdURL:(NSURL *)momdURL storeURL:(NSURL *)storeURL {
  NSParameterAssert(momdURL);
  NSParameterAssert(storeURL);
  
  self = [super init];
  if (self) {
    self.dbManager = [RHDatabaseManager databaseManagerWithModelURL:momdURL storeURL:storeURL];
    self.queryCache = [NSMutableDictionary dictionary];
    self.logText = [NSMutableString string];
    self.trackLogging = NO;
  }
  return self;
}

- (instancetype)init {
  RLog(@"RHDataAgent: Warning! This is a singleton class, please use 'agent'");
  return nil;
}

- (NSManagedObjectContext *)mainManagedObjectContext {
  return self.dbManager.managedObjectContext;
}

- (NSManagedObjectContext *)backgroundManagedObjectContext {
  return self.dbManager.backgroundManagedObjectContext;
}

#pragma mark - Insert, Update, Delete
- (void)commit {
  [self.dbManager commitChangesWithSuccess:^{
    [self RHLogging:@"RHDataAgent: Insert or update object success"];
  } failure:^(NSError *error) {
    [self RHLogging:[NSString stringWithFormat:@"RHDataAgent: Insert or update object failed. error(%@)", error.localizedDescription]];
  }];
}

- (void)deleteObject:(NSManagedObject *)object {
  [self.dbManager deleteManagedObject:object success:^{
    [self RHLogging:[NSString stringWithFormat:@"RHDataAgent: Delete obj(%@) success", object]];
  } failure:^(NSError *error) {
    [self RHLogging:[NSString stringWithFormat:@"RHDataAgent: Delete obj(%@) failed. error(%@)", object, error.localizedDescription]];
  }];
}

- (void)deleteObjects:(NSArray *)objects {
  [self.dbManager deleteObjects:objects success:^{
    [self RHLogging:[NSString stringWithFormat:@"RHDataAgent: Delete objs(%@) success", objects]];
  } failure:^(NSError *error) {
    [self RHLogging:[NSString stringWithFormat:@"RHDataAgent: Delete objs(%@) failed! error(%@)", objects, error.localizedDescription]];
  }];
}

#pragma mark - Query
- (id)excuteQuery:(RHQuery *)query {
  NSParameterAssert(query);
  
  __block id ret = nil;
  
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  
  NSEntityDescription *entityDes = [NSEntityDescription entityForName:query.entity inManagedObjectContext:self.dbManager.managedObjectContext];
  fetchRequest.entity = entityDes;
  
  fetchRequest.predicate = query.queryPredicate;
  fetchRequest.sortDescriptors = query.sortDescriptors;
  fetchRequest.fetchBatchSize = query.batchSize;
  fetchRequest.fetchOffset = query.queryOffset;
  fetchRequest.fetchLimit = query.limitCount;
  
  if (query.expressionDescription) {
    [fetchRequest setPropertiesToFetch:@[query.expressionDescription]];
    [fetchRequest setResultType:NSDictionaryResultType];
  }
  
  [self.dbManager queryWithRequest:fetchRequest success:^(NSArray *result) {
    if (query.expressionDescription == nil) {
      ret = result;
    } else {
      NSDictionary *dict = [result firstObject];
      ret = dict[query.expressionDescription.name];
    }
  } failure:^(NSError *error) {
    [self RHLogging:[NSString stringWithFormat:@"RHDataAgent: Query(%@) excute failed! error(%@)", query, error.localizedDescription]];
  }];
  
  return ret;
}

- (void)cachedQuery:(RHQuery *)query withKey:(NSString *)queryKey {
  [self.queryCache setObject:query forKey:queryKey];
}

- (void)removeCachedQueryForKey:(NSString *)queryKey {
  [self.queryCache removeObjectForKey:queryKey];
}

- (RHQuery *)cachedQueryForKey:(NSString *)queryKey {
  return self.queryCache[queryKey];
}

#pragma mark - Undo Management
- (void)undo {
  [self.dbManager undo];
}

- (void)redo {
  [self.dbManager redo];
}

- (void)rollback {
  [self.dbManager rollback];
}

- (void)reset {
  [self.dbManager reset];
}

#pragma mark - Memory
- (void)reduceMemory {
  //Clear cached queries
  [self.queryCache removeAllObjects];
  //Clear undo manager track stack
  [self.mainManagedObjectContext.undoManager removeAllActions];
  //Clear log
  self.logText = nil;
  self.logText = [NSMutableString string];
}

#pragma mark - Logging Util
- (void)RHLogging:(NSString *)log {
  if (self.trackLogging) {
    [self.logText appendFormat:@"%@\n", log];
  } else {
    RLog(@"%@", log);
  }
}

@end
