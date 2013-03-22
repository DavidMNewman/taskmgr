//
//  APIController.h
//  taskmgr
//
//  Created by David Newman on 3/16/13.
//  Copyright (c) 2013 OBS. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol APIControllerDelegate;

typedef void (^JSONResponseBlock)(id json);

@interface APIController : NSObject
{
//    id <APIControllerDelegate> delegate;
}

@property (nonatomic, assign) id <APIControllerDelegate> delegate;

+ (id)sharedController;

-(void)getAllTasks;
-(void)postNewTaskWithDescription:(NSString *)description duedate:(NSDate *)duedateUnformatted priority:(NSString *)priority status:(NSString*)status;
-(void)markTaskAsComplete:(Task *)task;

@end

@protocol APIControllerDelegate

- (void)showErrorMessage:(NSString *)message;
- (void)showSuccessWithMessage:(NSString *)message;
- (void)showStatusWithMessage:(NSString *)message;
- (void)removeAllMessages;
- (void)reloadTaskData;
- (void)didFinishUploadingTask;

@end