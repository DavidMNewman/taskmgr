//
//  Task.h
//  taskmgr
//
//  Created by David Newman on 3/17/13.
//  Copyright (c) 2013 OBS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define NULL_TO_NIL(obj) ({ __typeof__ (obj) __obj = (obj); __obj == [NSNull null] ? nil : obj; })


@interface Task : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * taskDescription;
@property (nonatomic, retain) NSString * priority;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSDate * duedate;


+(void)createOrUpdateTaskFromDictionary:(NSDictionary *)dictionary;

@end
