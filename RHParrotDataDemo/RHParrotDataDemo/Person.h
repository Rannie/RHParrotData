//
//  Person.h
//  RHParrotDataDemo
//
//  Created by Hanran Liu on 15/1/20.
//  Copyright (c) 2015年 ran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Person : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * age;
@property (nonatomic, retain) NSString * sex;
@property (nonatomic, retain) NSDate * birthday;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * personId;

@end
