//
//  RHDatabaseManager.m
//  RHParrotDataDemo
//
//  Created by Hanran Liu on 15/1/19.
//  Copyright (c) 2015年 ran. All rights reserved.
//

#import "RHDatabaseManager.h"

static NSString * const RHDatabaseManagerDomain = @"RHDatabaseManagerDomain";

@implementation RHDatabaseManager

@synthesize managedObjectContext = _managedObjectContext;
@synthesize backgroundManagedObjectContext = _backgroundManagedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

#pragma mark - Initilialization
+ (instancetype)databaseManagerWithModelURL:(NSURL *)momdURL storeURL:(NSURL *)storeURL {
  return [[self alloc] initWithModelURL:momdURL storeURL:storeURL];
}

- (instancetype)initWithModelURL:(NSURL *)momdURL storeURL:(NSURL *)storeURL {
  self = [self init];
  if (self) {
    self.momdURL = momdURL;
    self.storeURL = storeURL;
    [self observeContextDidSavingNotification];
  }
  return self;
}

#pragma mark - Stack
- (NSManagedObjectModel *)managedObjectModel {
  if (_managedObjectModel != nil) {
    return _managedObjectModel;
  }
  
  _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:self.momdURL];
  return _managedObjectModel;
}

- (NSManagedObjectContext *)managedObjectContext {
  if (_managedObjectContext != nil) {
    return _managedObjectContext;
  }
  
  _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
  _managedObjectContext.undoManager = [[NSUndoManager alloc] init];
  [_managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
  return _managedObjectContext;
}

- (NSManagedObjectContext *)backgroundManagedObjectContext {
  if (_backgroundManagedObjectContext != nil) {
    return _backgroundManagedObjectContext;
  }
  
  _backgroundManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
  _backgroundManagedObjectContext.undoManager = nil;
  [_backgroundManagedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
  return _backgroundManagedObjectContext;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
  if (_persistentStoreCoordinator != nil) {
    return _persistentStoreCoordinator;
  }
  
  NSError *error = nil;
  _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
  
  NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption: @YES,
                            NSInferMappingModelAutomaticallyOption: @YES };
  if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                 configuration:nil
                                                           URL:self.storeURL
                                                       options:options
                                                         error:&error])
  {
    RLog(@"DBManager: Unresolved error %@, %@", error, [error userInfo]);
  }
  return _persistentStoreCoordinator;
}


#pragma mark - Observe Concurrency Note
- (void)observeContextDidSavingNotification {
  [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextDidSaveNotification
                                                    object:nil
                                                     queue:nil
                                                usingBlock:^(NSNotification *note) {
                                                  NSManagedObjectContext *moc = self.managedObjectContext;
                                                  if (note.object != moc) {
                                                    [moc performBlock:^{
                                                      [moc mergeChangesFromContextDidSaveNotification:note];
                                                    }];
                                                  }
                                                }];
}

#pragma mark - Insert, Update
- (void)commitChangesWithSuccess:(DBOperationSuccessBlock)success failure:(DBOperationFailureBlock)failure {
  [self saveContextWithSuccess:success failure:failure];
}

#pragma mark - Delete
- (void)deleteManagedObject:(id)object success:(DBOperationSuccessBlock)success failure:(DBOperationFailureBlock)failure {
  NSManagedObject *managedObj = object;
  if (managedObj.managedObjectContext == self.managedObjectContext) {
    [self.managedObjectContext deleteObject:managedObj];
    [self saveContextWithSuccess:success failure:failure];
  } else {
    NSError *error = [NSError errorWithDomain:RHDatabaseManagerDomain code:0 userInfo:@{NSLocalizedDescriptionKey: @"DBManager: WARNING! Object in diffrent context!"}];
    if (failure) failure(error);
  }
}

- (void)deleteObjects:(NSArray *)objects success:(DBOperationSuccessBlock)success failure:(DBOperationFailureBlock)failure {
  for (NSManagedObject *modelObj in objects) {
    if (modelObj.managedObjectContext == self.managedObjectContext) {
      [self.managedObjectContext deleteObject:modelObj];
    } else {
      NSError *error = [NSError errorWithDomain:RHDatabaseManagerDomain code:0 userInfo:@{NSLocalizedDescriptionKey: @"DBManager: WARNING! Object in diffrent context!"}];
      if (failure) failure(error);
    }
  }
  
  [self saveContextWithSuccess:success failure:failure];
}

#pragma mark - Update
- (void)updateManagedObject:(id)object success:(DBOperationSuccessBlock)success failure:(DBOperationFailureBlock)failure {
  NSManagedObject *managedObj = object;
  
  if (managedObj.managedObjectContext != self.managedObjectContext) {
    NSError *error = [NSError errorWithDomain:RHDatabaseManagerDomain code:0 userInfo:@{NSLocalizedDescriptionKey: @"DBManager: WARNING! Object in diffrent context!"}];
    if (failure) failure(error);
  }
  
  if ([managedObj hasChanges]) {
    [self saveContextWithSuccess:success failure:failure];
  }
}

- (void)updateObjects:(NSArray *)objects success:(DBOperationSuccessBlock)success failure:(DBOperationFailureBlock)failure {
  NSManagedObject *managedObj = [objects firstObject];
  if (managedObj.managedObjectContext != self.managedObjectContext) {
    NSError *error = [NSError errorWithDomain:RHDatabaseManagerDomain code:0 userInfo:@{NSLocalizedDescriptionKey: @"DBManager: WARNING! Object in diffrent context!"}];
    if (failure) failure(error);
    return;
  }
  
  [self saveContextWithSuccess:success failure:failure];
}

#pragma mark - Query
- (void)queryWithRequest:(NSFetchRequest *)fetchRequest success:(DBQuerySuccessBlock)success failure:(DBOperationFailureBlock)failure {
  NSError *error = nil;
  NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
  if (error) {
    if (failure) failure(error);
  } else {
    if (success) success(results);
  }
}

#pragma mark - Save Context
- (void)saveContextWithSuccess:(DBOperationSuccessBlock)success failure:(DBOperationFailureBlock)failure
{
  NSError *error = nil;
  NSManagedObjectContext *context = self.managedObjectContext;
  if ([context hasChanges] && ![context save:&error]) {
    if (failure) failure(error);
  } else {
    if (success) success();
  }
}

#pragma mark - Undo Management
- (void)undo {
  [self.managedObjectContext undo];
}

- (void)redo {
  [self.managedObjectContext redo];
}

- (void)rollback {
  [self.managedObjectContext rollback];
}

- (void)reset {
  [self.managedObjectContext reset];
}

@end
