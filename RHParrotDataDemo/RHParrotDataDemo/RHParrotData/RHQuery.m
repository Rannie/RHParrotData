//
//  RHQuery.m
//  RHParrotDataDemo
//
//  Created by Hanran Liu on 15/1/17.
//  Copyright (c) 2015年 ran. All rights reserved.
//

#import "RHQuery.h"
#import "RHDataAgent.h"

static NSString * RHOperatorText(RHOperator op) {
  switch (op) {
    case Equal:
      return @"=";
    case GreaterThan:
      return @">";
    case LessThan:
      return @"<";
    case GreaterOrEqual:
      return @">=";
    case LessOrEqual:
      return @"<=";
    case Not:
      return @"!=";
    case Between:
      return @"BETWEEN";
    case BeginsWith:
      return @"BEGINSWITH";
    case EndsWith:
      return @"ENDSWITH";
    case Contains:
      return @"CONTAINS";
    case Like:
      return @"LIKE";
    case Matches:
      return @"MATCHES";
    case In:
      return @"IN";
    default:
      RLog(@"RHQuery: Unknown operator!");
      break;
  }
  return nil;
}

static NSString * RHFunctionExpression(RHFunction func) {
  switch (func) {
    case Max:
      return @"max:";
    case Min:
      return @"min:";
    case Count:
      return @"count:";
    case Sum:
      return @"sum:";
    case Average:
      return @"average:";
    default:
      RLog(@"RHQuery: Unknown function!");
      break;
  }
  return nil;
}

@interface RHQuery ()
@property (nonatomic, strong, readwrite) NSPredicate  *queryPredicate;
@property (nonatomic, strong, readwrite) NSString     *entity;
@property (nonatomic, strong, readwrite) NSExpressionDescription *expressionDescription;

@property (nonatomic, assign, getter=isCompound) BOOL compound;
@property (nonatomic, strong) NSMutableArray *sortConditions;
@end

@implementation RHQuery

#pragma mark - Initialization
+ (RHQuery *)queryWithEntity:(NSString *)entityName {
  return [[self alloc] initWithQueryEntity:entityName];
}

- (RHQuery *)initWithQueryEntity:(NSString *)entityName {
  NSParameterAssert(entityName);
  
  self = [self init];
  if (self) {
    self.entity = entityName;
    self.sortConditions = [NSMutableArray array];
    self.queryOffset = 0;
    self.batchSize = 0;
    self.limitCount = 0;
  }
  return self;
}

- (RHQuery *)same {
  return [RHQuery queryWithEntity:self.entity];
}

- (id)copyWithZone:(NSZone *)zone {
  RHQuery *query = [[RHQuery allocWithZone:zone] init];
  query.entity = self.entity;
  query.queryPredicate = self.queryPredicate;
  query.expressionDescription = self.expressionDescription;
  query.sortConditions = self.sortConditions;
  query.limitCount = self.limitCount;
  query.batchSize = self.batchSize;
  query.queryOffset = self.queryOffset;
  return query;
}

- (NSArray *)sortDescriptors {
  return [self.sortConditions copy];
}

#pragma mark - Query Condition Methods
- (void)queryKey:(NSString *)key op:(RHOperator)op value:(id)value {
  NSParameterAssert(key);
  NSParameterAssert(value);
  
  if (op == None) { return; }
  if (op == In) {
    if (![value isKindOfClass:NSArray.class]) {
      RLog(@"RHQuery: In value should be a list, if only one value, should use 'Equal'.");
      return;
    }
  }
  
  if (self.isCompound) {
    RLog(@"RHQuery: Query is compound. If want to add a condition, can use 'queryAnd:' method!");
    return;
  }
  
  NSString *operator = RHOperatorText(op);
  NSString *statement = [NSString stringWithFormat:@"%@ %@ \"%@\"", key, operator, value];
  NSPredicate *predicate = [NSPredicate predicateWithFormat:statement];
  self.queryPredicate = predicate;
}

- (void)queryKey:(NSString *)key withFunction:(RHFunction)function {
  NSParameterAssert(key);
  
  NSExpression *keyPathExpression = [NSExpression expressionForKeyPath:key];
  NSExpression *expression = [NSExpression expressionForFunction:RHFunctionExpression(function) arguments:@[keyPathExpression]];
  
  NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
  expressionDescription.name = key;
  expressionDescription.expression = expression;
  expressionDescription.expressionResultType = NSUndefinedAttributeType;
  
  self.expressionDescription = expressionDescription;
}

- (RHQuery *)OR:(RHQuery *)anoQuery {
  NSParameterAssert(anoQuery);
  NSPredicate *comPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[self.queryPredicate, anoQuery.queryPredicate]];
  RHQuery *newQuery = [self copy];
  newQuery.queryPredicate = comPredicate;
  newQuery.compound = YES;
  return newQuery;
}

- (RHQuery *)AND:(RHQuery *)anoQuery {
  NSParameterAssert(anoQuery);
  NSPredicate *comPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[self.queryPredicate, anoQuery.queryPredicate]];
  RHQuery *newQuery = [self copy];
  newQuery.queryPredicate = comPredicate;
  newQuery.compound = YES;
  return newQuery;
}

- (RHQuery *)NOT {
  NSPredicate *comPredicate = [NSCompoundPredicate notPredicateWithSubpredicate:self.queryPredicate];
  RHQuery *newQuery = [self copy];
  newQuery.queryPredicate = comPredicate;
  newQuery.compound = YES;
  return newQuery;
}

- (void)sort:(NSString *)key ascending:(BOOL)ascending {
  NSParameterAssert(key);
  NSSortDescriptor *sortDes = [[NSSortDescriptor alloc] initWithKey:key ascending:ascending];
  [self.sortConditions addObject:sortDes];
}

- (void)sort:(NSString *)key ascending:(BOOL)ascending comparator:(NSComparator)comparator {
  NSParameterAssert(key);
  NSSortDescriptor *sortDes = nil;
  sortDes = [[NSSortDescriptor alloc] initWithKey:key ascending:ascending comparator:comparator];
  [self.sortConditions addObject:sortDes];
}

- (id)excute {
  return [[RHDataAgent agent] excuteQuery:self];
}

#pragma mark - Other
- (NSString *)description {
  return [NSString stringWithFormat:@"<RHQuery: %p entity: %@>", self, self.entity];
}

@end
