//
//  RHDataImporter.h
//  RHParrotDataDemo
//
//  Created by Hanran Liu on 15/1/17.
//  Copyright (c) 2015年 ran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RHParrotMacro.h"

typedef void (^RHObjectSerializeHandler)(id oriObj, NSManagedObject *dataObj);

@interface RHDataImporter : NSObject

@property (nonatomic, assign) NSUInteger batchCount;      //default 10

- (void)importEntity:(NSString *)entity
          primaryKey:(NSString *)primaryKey
                data:(NSArray *)data
       insertHandler:(RHObjectSerializeHandler)insertHandler
       updateHandler:(RHObjectSerializeHandler)updateHandler;

@end
