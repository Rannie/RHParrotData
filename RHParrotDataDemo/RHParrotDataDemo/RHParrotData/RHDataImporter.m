//
//  RHDataImporter.m
//  RHParrotDataDemo
//
//  Created by Hanran Liu on 15/1/17.
//  Copyright (c) 2015年 ran. All rights reserved.
//

#import "RHDataImporter.h"
#import "RHDataAgent.h"

@implementation RHDataImporter

- (instancetype)init {
  self = [super init];
  if (self) {
    self.batchCount = 10;
  }
  return self;
}

- (void)importEntity:(NSString *)entity primaryKey:(NSString *)primaryKey data:(NSArray *)data insertHandler:(RHObjectSerializeHandler)insertHandler updateHandler:(RHObjectSerializeHandler)updateHandler {
  NSParameterAssert(entity);
  
  __block NSUInteger count = 0;
  
  NSManagedObjectContext *moc = [RHDataAgent agent].backgroundManagedObjectContext;
  [moc performBlock:^{
    for (id obj in data) {
      NSManagedObject *managedObj;
      if (primaryKey != nil) {
        id primaryValue = [obj valueForKey:primaryKey];
        RHQuery *query = [RHQuery queryWithEntity:entity];
        [query queryKey:primaryKey op:Equal value:primaryValue];
        managedObj = [[query excute] firstObject];
      }
      
      if (managedObj) {
        if (updateHandler) updateHandler(obj, managedObj);
      } else {
        managedObj = [NSEntityDescription insertNewObjectForEntityForName:entity inManagedObjectContext:moc];
        if (insertHandler) insertHandler(obj, managedObj);
      }
      
      count++;
      if (count % _batchCount == 0 || count == data.count) {
        NSError *error = nil;
        [moc save:&error];
        if (error) {
          RLog(@"RHDataImporter: Import data occurs error(%@)!", error.localizedDescription);
        }
      }
    }
  }];
}

@end
