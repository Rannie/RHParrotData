//
//  RHQuery.h
//  RHParrotDataDemo
//
//  Created by Hanran Liu on 15/1/17.
//  Copyright (c) 2015年 ran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RHParrotMacro.h"

typedef NS_ENUM(NSInteger, RHOperator) {
  RHNone = 0,
  // ==
  RHEqual,
  // >
  RHGreaterThan,
  // <
  RHLessThan,
  // >=
  RHGreaterOrEqual,
  // <=
  RHLessOrEqual,
  // !=
  RHNot,
  // < lhs <
  RHBetween,
  // BEGINSWITH
  RHBeginsWith,
  // ENDSWITH
  RHEndsWith,
  // CONTAINS
  RHContains,
  // LIKE[CD]
  RHLike,
  // MATCHES
  RHMatches,
  // IN
  RHIn
};

typedef NS_ENUM(NSInteger, RHFunction) {
  // MAX
  RHMax = 0,
  // MIN
  RHMin,
  // AVERAGE
  RHAverage,
  // SUM
  RHSum,
  // COUNT
  RHCount
};

@interface RHQuery : NSObject <NSCopying>

/**
 *  The managed object class name of query.
 */
@property (nonatomic, strong, readonly) NSString    *entity;

/**
 *  Query condition.
 */
@property (nonatomic, strong, readonly) NSPredicate *queryPredicate;

/**
 *  Sort condition.
 */
@property (nonatomic, strong, readonly) NSArray     *sortDescriptors;

/**
 *  When call 'queryKey:withFunction:', will generate a expression description.
 */
@property (nonatomic, strong, readonly) NSExpressionDescription *expressionDescription;

/**
 *  Query result limit count. Default is 0, means have no limit.
 */
@property (nonatomic, assign) NSUInteger limitCount;

/**
 *  Query batch size. Default is 0.
 */
@property (nonatomic, assign) NSUInteger batchSize;

/**
 *  Query offset. Default is 0.
 */
@property (nonatomic, assign) NSUInteger queryOffset;

/**
 *  Create a RHQuery instance.
 *
 *  @param entityName The class name of the query managed object.
 *
 *  @return query instance
 */
+ (RHQuery *)queryWithEntity:(NSString *)entityName;

/**
 *  Create a query has same entity name.
 *
 *  @return query instance
 */
- (RHQuery *)same;

/**
 *  Simple query with key-operator-value pattern.
 *
 *  @param key   managed object's property keypath
 *  @param op    operator see enum 'RHOperator'
 *  @param value rhs
 */
- (void)queryKey:(NSString *)key op:(RHOperator)op value:(id)value;

/**
 *  Query with function.
 *
 *  @param key      managed object's property keypath
 *  @param function function to caculate. functions see enum 'RHFunction'
 */
- (void)queryKey:(NSString *)key function:(RHFunction)function;

/**
 *  Query with sort result.
 *
 *  @param key       managed object's property keypath
 *  @param ascending YES means ascending, or descending
 */
- (void)sort:(NSString *)key ascending:(BOOL)ascending;

/**
 *  Query with sort result by custom comparator.
 *
 *  @param key        managed object's property keypath
 *  @param ascending  YES means ascending, or descending
 *  @param comparator custom compare method
 */
- (void)sort:(NSString *)key ascending:(BOOL)ascending comparator:(NSComparator)comparator;

/**
 *  Create a new query by combining two 'or' relations queries.
 *
 *  @param anoQuery another query instance
 *
 *  @return new query instance
 */
- (RHQuery *)OR:(RHQuery *)anoQuery;

/**
 *  Create a new query by combining two 'and' relations queries.
 *
 *  @param anoQuery another query instance
 *
 *  @return new query instance
 */
- (RHQuery *)AND:(RHQuery *)anoQuery;

/**
 *  Create a new query that is in contrast with its own query conditions.
 *
 *  @return new query instance
 */
- (RHQuery *)NOT;

/**
 *  generate a fetch request contains all condition.
 *
 *  @return the fetch request
 */
- (NSFetchRequest *)generateFetchRequest;

/**
 *  Execute the query.
 *
 *  @return query result
 */
- (id)execute;

@end
