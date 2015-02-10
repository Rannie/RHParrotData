//
//  RHQueryResultController.m
//  RHParrotDataDemo
//
//  Created by Hanran Liu on 15/1/23.
//  Copyright (c) 2015年 ran. All rights reserved.
//

#import "RHQueryResultController.h"
#import "RHDataAgent.h"
#import "RHQuery.h"

@implementation RHQueryResultController

+ (instancetype)queryResultControllerWithQuery:(RHQuery *)query
                            sectionNameKeyPath:(NSString *)sectionNameKeyPath
                                     cacheName:(NSString *)name {
  NSParameterAssert(query);
  NSFetchRequest *fetchRequest = [query generateFetchRequest];
  return [[self alloc] initWithFetchRequest:fetchRequest managedObjectContext:RHMainContext sectionNameKeyPath:sectionNameKeyPath cacheName:name];
}

+ (instancetype)queryResultControllerWithQuery:(RHQuery *)query {
  return [self queryResultControllerWithQuery:query sectionNameKeyPath:nil cacheName:nil];
}

- (void)performQuery {
  [[RHDataAgent agent] executeQueryWithController:self];
}

@end
