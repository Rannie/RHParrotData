//
//  RHDatabaseManager.h
//  RHParrotDataDemo
//
//  Created by Hanran Liu on 15/1/19.
//  Copyright (c) 2015年 ran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RHParrotMacro.h"

typedef void (^DBOperationSuccessBlock)();
typedef void (^DBQuerySuccessBlock)(id result);
typedef void (^DBOperationFailureBlock)(NSError *error);

/**
 *  The CoreData stack class.
 *  Operate database directly.
 */
@interface RHDatabaseManager : NSObject

@property (nonatomic, strong) NSURL *momdURL;
@property (nonatomic, strong) NSURL *storeURL;

@property (nonatomic, strong, readonly) NSManagedObjectContext       *managedObjectContext;
@property (nonatomic, strong, readonly) NSManagedObjectContext       *backgroundManagedObjectContext;
@property (nonatomic, strong, readonly) NSManagedObjectModel         *managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (instancetype)databaseManagerWithModelURL:(NSURL *)momdURL storeURL:(NSURL *)storeURL;
- (instancetype)initWithModelURL:(NSURL *)momdURL storeURL:(NSURL *)storeURL;

- (void)commitChangesWithSuccess:(DBOperationSuccessBlock)success failure:(DBOperationFailureBlock)failure;

- (void)deleteManagedObject:(id)object success:(DBOperationSuccessBlock)success failure:(DBOperationFailureBlock)failure;
- (void)deleteObjects:(NSArray *)objects success:(DBOperationSuccessBlock)success failure:(DBOperationFailureBlock)failure;

- (void)queryWithRequest:(NSFetchRequest *)fetchRequest success:(DBQuerySuccessBlock)success failure:(DBOperationFailureBlock)failure;

- (void)undo;
- (void)redo;
- (void)rollback;
- (void)reset;

@end
