//
//  RHDataImporter.h
//  RHParrotDataDemo
//
//  Created by Hanran Liu on 15/1/17.
//  Copyright (c) 2015年 ran. All rights reserved.
//

#import "RHParrotMacro.h"

typedef void (^RHObjectSerializeHandler)(id oriObj, NSManagedObject *dataObj);

@interface RHDataImporter : NSObject

/**
 *  Defines how often save data to store.
 */
@property (nonatomic, assign) NSUInteger batchCount;      //default 10

/**
 *  Import data method.
 *
 *  @param entity        managed object class name, required
 *  @param primaryKey    primary key, can be nil
 *  @param data          data
 *  @param insertHandler how to insert between data instance and managed object
 *  @param updateHandler how to update between data instance and managed object
 */
- (void)importEntity:(NSString *)entity
          primaryKey:(NSString *)primaryKey
                data:(NSArray *)data
       insertHandler:(RHObjectSerializeHandler)insertHandler
       updateHandler:(RHObjectSerializeHandler)updateHandler;

@end
