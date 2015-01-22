//
//  AppDelegate.m
//  RHParrotDataDemo
//
//  Created by Hanran Liu on 15/1/17.
//  Copyright (c) 2015年 ran. All rights reserved.
//

#import "AppDelegate.h"
#import "RHParrotData.h"
#import "Person.h"
#import "Brand.h"

@interface AppDelegate ()
@property (nonatomic, strong) RHDataAgent *dataAgent;
@property (nonatomic, strong) RHDataImporter *importer;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  NSLog(@"path : %@",  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]);
  
  [self setupAgent];
  
//  [self insertCase];
//  [self deleteCase];
//  [self updateCase];
//  [self queryCase];
  [self importCase];
  
  return YES;
}

- (void)setupAgent {
  NSURL *momdURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
  NSURL *appDocumentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
  NSURL *storeURL = [appDocumentsDirectory URLByAppendingPathComponent:@"ParrotData.sqlite"];
  [RHDataAgent setupAgentWithMomdFile:momdURL andStoreURL:storeURL];
  self.dataAgent = [RHDataAgent agent];
}

- (void)queryCase {
  id result;
  
  RHQuery *query = [RHQuery queryWithEntity:@"Person"];
  [query queryKey:@"name" op:RHEqual value:@"Kobe"];
  result = [query excute];
  
  NSLog(@"result : %@", result);
  
  RHQuery *sortQuery = [RHQuery queryWithEntity:@"Person"];
  [sortQuery sort:@"age" ascending:NO];
  result = [sortQuery excute];
  [result enumerateObjectsUsingBlock:^(Person *obj, NSUInteger idx, BOOL *stop) {
    NSLog(@"obj age : %@", obj.age);
  }];
  
  RHQuery *queryAverageAge = [query same];
  [queryAverageAge queryKey:@"age" withFunction:RHAverage];
  result = [queryAverageAge excute];
  
  NSLog(@"result : %@", result);
  
  RHQuery *queryMin = [query same];
  [queryMin queryKey:@"age" withFunction:RHMin];
  result = [queryMin excute];
  
  NSLog(@"result : %@", result);
  
  RHQuery *queryStart = [query same];
  [queryStart queryKey:@"name" op:RHBeginsWith value:@"H"];
  result = [queryStart excute];
  
  NSLog(@"result : %@", result);
  
  RHQuery *orQuery = [queryStart OR:query];
  result = [orQuery excute];
  
  NSLog(@"result : %@", result);
}

- (void)importCase {
  self.importer = [[RHDataImporter alloc] init];
  
  void (^block)(id oriObj, NSManagedObject *managedObj) = ^(id oriObj, NSManagedObject *managedObj) {
    if ([oriObj isKindOfClass:NSDictionary.class]) {
      NSDictionary *dict = oriObj;
      [managedObj setValuesForKeysWithDictionary:dict];
    }
  };
  
  [self.importer importEntity:@"Brand"
                   primaryKey:@"brandId"
                         data:[self unimportData]
                insertHandler:block
                updateHandler:block];
}

- (void)updateCase {
  RHQuery *query = [RHQuery queryWithEntity:@"Person"];
  [query queryKey:@"name" op:RHEqual value:@"Kobe"];
  Person *p = [[query excute] firstObject];
  
  p.birthday = [NSDate date];
  
  [self.dataAgent commit];
}

- (void)deleteCase {
  RHQuery *query = [RHQuery queryWithEntity:@"Person"];
  [query queryKey:@"name" op:RHEqual value:@"hehe"];
  id result = [[query excute] firstObject];
  
  [self.dataAgent deleteObject:result];
}

- (void)insertCase {
  Person *p = [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:self.dataAgent.mainManagedObjectContext];
  p.name = @"Kobe";
  p.age = @38;
  p.sex = @"male";
  p.personId = @"103821";
  [self.dataAgent commit];
}

- (NSArray *)unimportData {
  NSMutableArray *data = [NSMutableArray array];
  for (int i = 0; i < 1000; i++) {
    NSDictionary *dict = @{@"brandId": [NSString stringWithFormat:@"%d", i],
                           @"product": [NSString stringWithFormat:@"product_%d", i]};
    [data addObject:dict];
  }
  return [data copy];
}

@end
