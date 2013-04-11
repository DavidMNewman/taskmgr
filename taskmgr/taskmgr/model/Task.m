//
//  Task.m
//  taskmgr
//
//  Created by David Newman on 3/17/13.
//  Copyright (c) 2013 OBS. All rights reserved.
//

#import "Task.h"
#import "Constants.h"

/*This method is used to convert any NULL results from JSON parsing into nil.*/



@implementation Task

@dynamic id;
@dynamic taskDescription;
@dynamic priority;
@dynamic status;
@dynamic duedate;

+ (void)createOrUpdateTaskFromDictionary:(NSDictionary *)dictionary {
    NSManagedObjectContext *context = [DataManager sharedInstance].mainObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Task" inManagedObjectContext:context];

    Task *task;

    /*We will first check to see if the task already exists in our database. If it already exists, we will update
       the task instead of creating a new one.*/

    if (NULL_TO_NIL([dictionary objectForKey:@"id"]) && [context fetchObjectsForEntityName:@"Task" predicateWithFormat:@"id = %@", NULL_TO_NIL([dictionary objectForKey:@"id"])].count > 0) {
        task = [[context fetchObjectsForEntityName:@"Task" predicateWithFormat:@"id = %@", NULL_TO_NIL([dictionary objectForKey:@"id"])] objectAtIndex:0];
    } else {
        task = [[Task alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
    }

    /*Now we go though each item in the dictionary that needs to be mapped to the task*/
    if ([NULL_TO_NIL([dictionary objectForKey:@"id"]) isKindOfClass:[NSNumber class]]) {
        [task setId:[dictionary objectForKey:@"id"]];
    }

    if ([NULL_TO_NIL([dictionary objectForKey:@"description"]) isKindOfClass:[NSString class]]) {
        [task setTaskDescription:[dictionary objectForKey:@"description"]];
    }

    if ([NULL_TO_NIL([dictionary objectForKey:@"priority"]) isKindOfClass:[NSString class]]) {
        [task setPriority:[dictionary objectForKey:@"priority"]];
    }

    if ([NULL_TO_NIL([dictionary objectForKey:@"status"]) isKindOfClass:[NSString class]]) {
        [task setStatus:[dictionary objectForKey:@"status"]];
    }

    if ([NULL_TO_NIL([dictionary objectForKey:@"duedate"]) isKindOfClass:[NSString class]]) {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"MM-dd-yyyy"];
        [task setDuedate:[df dateFromString:[dictionary objectForKey:@"duedate"]]];
    }


    NSError *error;
    [context save:&error];

    if (error) {
        /* My DataManager has a method for logging more verbose error information*/
        [DataManager errorDetails:error];
    }
}

@end
