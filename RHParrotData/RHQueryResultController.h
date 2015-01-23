//
//  RHQueryResultController.h
//  RHParrotDataDemo
//
//  Created by Hanran Liu on 15/1/23.
//  Copyright (c) 2015年 ran. All rights reserved.
//

#import "RHParrotMacro.h"

@class RHQuery;

@interface RHQueryResultController : NSFetchedResultsController

/**
 *  Create a RHQueryResultController (NSFetchedResultsController's subclass) instance.
 *
 *  @param query              query instance
 *  @param sectionNameKeyPath keypath on resulting objects that returns the section name. This will be used to pre-compute the section information.
 *  @param name               Section info is cached persistently to a private file under this name. Cached sections are checked to see if the time stamp matches the store, but not if you have illegally mutated the readonly fetch request, predicate, or sort descriptor.
 *
 *  @return controller instance
 */
+ (instancetype)queryResultControllerWithQuery:(RHQuery *)query
                            sectionNameKeyPath:(NSString *)sectionNameKeyPath
                                     cacheName:(NSString *)name;

/**
 *  Quick create controller only specify query.
 *
 *  @param query query instance
 *
 *  @return controller instance
 */
+ (instancetype)queryResultControllerWithQuery:(RHQuery *)query;

/**
 *  Perform fetch, log will collect by agent. Also can use 'performFetch:' method directly.
 */
- (void)performQuery;

@end
