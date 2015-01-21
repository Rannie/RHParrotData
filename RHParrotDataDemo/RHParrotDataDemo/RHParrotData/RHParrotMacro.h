//
//  RHParrotMacro.h
//  RHParrotDataDemo
//
//  Created by Hanran Liu on 15/1/17.
//  Copyright (c) 2015年 ran. All rights reserved.
//

#ifndef RHParrotDataDemo_RHParrotMacro_h
#define RHParrotDataDemo_RHParrotMacro_h

#import <CoreData/CoreData.h>

#ifdef DEBUG
#   define RLog(...) NSLog((@"%s [Line %d] %@"), __PRETTY_FUNCTION__, __LINE__, [NSString stringWithFormat:__VA_ARGS__])
#else
#   define RLog(...)
#endif

#endif
