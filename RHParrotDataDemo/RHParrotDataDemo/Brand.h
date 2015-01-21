//
//  Brand.h
//  RHParrotDataDemo
//
//  Created by Hanran Liu on 15/1/20.
//  Copyright (c) 2015年 ran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Brand : NSManagedObject

@property (nonatomic, retain) NSString * brandId;
@property (nonatomic, retain) NSString * product;
@property (nonatomic, retain) NSString * country;

@end
