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
    case RHEqual:
      return @"=";
    case RHGreaterThan:
      return @">";
    case RHLessThan:
      return @"<";
    case RHGreaterOrEqual:
      return @">=";
    case RHLessOrEqual:
      return @"<=";
    case RHNot:
      return @"!=";
    case RHBetween:
      return @"BETWEEN";
    case RHBeginsWith:
      return @"BEGINSWITH";
    case RHEndsWith:
      return @"ENDSWITH";
    case RHContains:
      return @"CONTAINS";
    case RHLike:
      return @"LIKE[cd]";
    case RHMatches:
      return @"MATCHES";
    case RHIn:
      return @"IN";
    default:
      RLog(@"RHQuery: Unknown operator!");
      break;
  }
  return nil;
}

static NSString * RHFunctionExpression(RHFunction func) {
  switch (func) {
    case RHMax:
      return @"max:";
    case RHMin:
      return @"min:";
    case RHCount:
      return @"count:";
    case RHSum:
      return @"sum:";
    case RHAverage:
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
  
  if (op == RHNone) { return; }
  if (op == RHIn) {
    if (![value isKindOfClass:NSArray.class]) {
      RLog(@"RHQuery: In value should be a list, if only one value, should use 'RHEqual'.");
      return;
    }
  }
  
  if (self.isCompound) {
    RLog(@"RHQuery: Query is compound. If want to add a condition, can use 'AND:' method!");
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
- (NSFetchRequest *)generateFetchRequest {
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  
  NSEntityDescription *entityDes = [NSEntityDescription entityForName:self.entity inManagedObjectContext:RHMainContext];
  fetchRequest.entity = entityDes;
  
  fetchRequest.predicate = self.queryPredicate;
  fetchRequest.sortDescriptors = self.sortDescriptors;
  fetchRequest.fetchBatchSize = self.batchSize;
  fetchRequest.fetchOffset = self.queryOffset;
  fetchRequest.fetchLimit = self.limitCount;
  
  if (self.expressionDescription) {
    [fetchRequest setPropertiesToFetch:@[self.expressionDescription]];
    [fetchRequest setResultType:NSDictionaryResultType];
  }
  
  return fetchRequest;
}

- (NSString *)description {
  return [NSString stringWithFormat:@"<RHQuery: %p entity: %@ predicate: %@>", self, self.entity, self.queryPredicate.predicateFormat];
}

@end
