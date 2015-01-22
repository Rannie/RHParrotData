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
  RHEqual,
  RHGreaterThan,
  RHLessThan,
  RHGreaterOrEqual,
  RHLessOrEqual,
  RHNot,
  RHBetween,
  RHBeginsWith,
  RHEndsWith,
  RHContains,
  RHLike,
  RHMatches,
  RHIn
};

typedef NS_ENUM(NSInteger, RHFunction) {
  RHMax = 0,
  RHMin,
  RHAverage,
  RHSum,
  RHCount
};

@interface RHQuery : NSObject <NSCopying>

@property (nonatomic, strong, readonly) NSString    *entity;
@property (nonatomic, strong, readonly) NSPredicate *queryPredicate;
@property (nonatomic, strong, readonly) NSArray     *sortDescriptors;
@property (nonatomic, strong, readonly) NSExpressionDescription *expressionDescription;

@property (nonatomic, assign) NSUInteger limitCount;
@property (nonatomic, assign) NSUInteger batchSize;
@property (nonatomic, assign) NSUInteger queryOffset;

+ (RHQuery *)queryWithEntity:(NSString *)entityName;
- (RHQuery *)same;

- (void)queryKey:(NSString *)key op:(RHOperator)op value:(id)value;
- (void)queryKey:(NSString *)key withFunction:(RHFunction)function;

- (void)sort:(NSString *)key ascending:(BOOL)ascending;
- (void)sort:(NSString *)key ascending:(BOOL)ascending comparator:(NSComparator)comparator;

- (RHQuery *)OR:(RHQuery *)anoQuery;
- (RHQuery *)AND:(RHQuery *)anoQuery;
- (RHQuery *)NOT;

- (id)excute;

@end
