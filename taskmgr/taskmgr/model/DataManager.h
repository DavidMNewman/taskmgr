//
//  DataManager.h
//  taskmgr
//
//  Created by David Newman on 3/16/13.
//  Copyright (c) 2012 David Newman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSManagedObjectContext-EasyFetch.h"

extern NSString * const DataManagerDidSaveNotification;
extern NSString * const DataManagerDidSaveFailedNotification;


@interface DataManager : NSObject

@property (nonatomic, readonly, retain) NSManagedObjectModel *objectModel;
@property (nonatomic, readonly, retain) NSManagedObjectContext *mainObjectContext;
@property (nonatomic, readonly, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (DataManager*)sharedInstance;

- (BOOL)save;

- (void)deleteAllObjectsInEntitityNamed:(NSString *)entityName;

+ (void)errorDetails:(NSError *)error;


@end
