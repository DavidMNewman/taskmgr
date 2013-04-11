//
//  APIController.m
//  taskmgr
//
//  Created by David Newman on 3/16/13.
//  Copyright (c) 2013 OBS. All rights reserved.
//

#import "APIController.h"
#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"
#import "Constants.h"
#import "Task.h"






@implementation APIController
{
@private AFHTTPClient *_httpClient;
}
+ (id)sharedController {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
        
    });
    return _sharedObject;
}

-(id)init {
    self = [super init];
    if (self) {
        _httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kAPIURL]];
    }
    return self;
}

-(void)getAllTasks {
    [self.delegate showStatusWithMessage:@"Connecting"];
    
    [self commandWithParams:nil URL:kAPIURL requestMethod:@"GET" attempts:3 onCompletion:^(id json) {
        
        if ([json isKindOfClass:[NSArray class]]) {
            [[DataManager sharedInstance] deleteAllObjectsInEntitityNamed:@"Task"];
            for (NSDictionary *dictionary in json) {
                [Task createOrUpdateTaskFromDictionary:dictionary];
            }
            [self.delegate showSuccessWithMessage:@"Success"];
            [self.delegate reloadTaskData];
        }
        if ([json isKindOfClass:[NSDictionary class]]) {
            
            [self.delegate showErrorMessage:@"Server Error"];

            NSLog(@"JSON ERROR:%@",NULL_TO_NIL([json objectForKey:@"error"]));
        }
        
        
    }];
}

-(void)postNewTaskWithDescription:(NSString *)description duedate:(NSDate *)duedateUnformatted priority:(NSString *)priority status:(NSString *)status{
    
    NSString *duedate;
    
    if (duedateUnformatted) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM-dd-yyyy"];
        duedate = [dateFormatter stringFromDate:duedateUnformatted];
        
    }else{
        duedate = nil;
    }
    
    /*Note that due to the fact that duedate might be nil it will have to be the last item added to the dictionary*/
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:description, @"description", priority, @"priority", status, @"status", duedate, @"duedate", nil];
    NSLog(@"Params:%@",params);
    [self commandWithParams:params URL:kAPIURL requestMethod:@"POST" attempts:0 onCompletion:^(id json) {
        NSLog(@"json:%@",json);
        if (NULL_TO_NIL([json objectForKey:@"id"])) {

            [Task createOrUpdateTaskFromDictionary:json];
            [self.delegate didFinishUploadingTask];
            /*I will add a minor delay so that the TaskFormViewController can be popped for the new status
             HUD gets shown*/
            double delayInSeconds = 0.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self.delegate reloadTaskData];
            });
            
        }else if (NULL_TO_NIL([json objectForKey:@"success"])) {
            [self.delegate didFinishUploadingTask];
            /*I will add a minor delay so that the TaskFormViewController can be popped for the new status
             HUD gets shown*/
            double delayInSeconds = 0.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self getAllTasks];
            });

        }else{
            [self.delegate showErrorMessage:@"Error Creating Task"];
        }
    }];
}

-(void)markTaskAsComplete:(Task *)task
{
    [self.delegate showStatusWithMessage:@"Connecting"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"complete",@"status", nil];
    
    [self commandWithParams:params URL:[NSString stringWithFormat:@"%@/%@",kAPIURL,task.id] requestMethod:@"PUT" attempts:0 onCompletion:^(id json) {
        NSLog(@"json id:%@",[json objectForKey:@"id"]);
        NSLog(@"json:%@",json);

        if (NULL_TO_NIL([json objectForKey:@"id"])) {

            [Task createOrUpdateTaskFromDictionary:json];
            [self.delegate reloadTaskData];
            [self.delegate showSuccessWithMessage:@"Task Completed"];

        }else if (NULL_TO_NIL([json objectForKey:@"success"])) {
            
            [task setStatus:@"complete"];
            NSError *error;
            [[DataManager sharedInstance].mainObjectContext save:&error];
            [self.delegate reloadTaskData];
            [self.delegate showSuccessWithMessage:@"Task Completed"];

        }else{
            
            [self.delegate showErrorMessage:@"Error Creating Task"];
        }

    }];
}

- (void)commandWithParams:(NSMutableDictionary *)params URL:(NSString *)url requestMethod:(NSString *)method attempts:(int)attempts onCompletion:(JSONResponseBlock)completionBlock {
    
    [_httpClient setParameterEncoding:AFJSONParameterEncoding];
    NSMutableURLRequest *apiRequest = [_httpClient requestWithMethod:method path:url parameters:params];
    
    [apiRequest setTimeoutInterval:30.0];
    AFJSONRequestOperation* operation = [[AFJSONRequestOperation alloc] initWithRequest: apiRequest];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        //success!
        
        completionBlock(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //failure
        
        NSLog(@"URL: %@",apiRequest.URL);
        NSLog(@"Response Method: %@",apiRequest.HTTPMethod);
        NSLog(@"Response StatusCode: %i",operation.response.statusCode);

        NSLog(@"Response Headers: %@",operation.response.allHeaderFields);
        NSLog(@"Response: %@",operation.response);
        NSLog(@"Response Errors: %@",[operation error]);
        
        if (operation.responseData) {
                        
            if (attempts > 0) {                
                [self commandWithParams:params URL:url requestMethod:method attempts:(attempts - 1) onCompletion:completionBlock];
            }else{
                
                NSError *jsonParsingError2 = nil;
                NSString *nonJSONString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];

                id responseObject;
                
                /*For a POST/PUT request for a task, the server is returning invalid JSON. This is where we test to
                 see if we are getting that. */
                
                NSLog(@"NONJSONSTRING:%@",nonJSONString);
                if (![nonJSONString compare:@"{success: \"The task was created successfully\"}"] || ![nonJSONString compare:@"{success: \"The task was updated successfully\"}"]) {
                    
                    completionBlock([NSDictionary dictionaryWithObjectsAndKeys:@"The task was created/updated successfully", @"success", nil]);
                    
                }else{
                    
                    responseObject = [NSJSONSerialization JSONObjectWithData:operation.responseData options:0 error:&jsonParsingError2];
                    
                    if (responseObject) {
                        completionBlock(responseObject);
                        
                    }else{
                        
                        completionBlock([NSDictionary dictionaryWithObject:[error localizedDescription] forKey:@"error"]);
                    }
                }
            }
        }else{

            if (attempts > 0) {
                NSLog(@"APIATTEMPT:%d",attempts);
                [self commandWithParams:params URL:url requestMethod:method attempts:(attempts - 1) onCompletion:completionBlock];
                
            }else{
                completionBlock([NSDictionary dictionaryWithObject:[error localizedDescription] forKey:@"error"]);
            }
        }
        
    }];
    
    [operation start];
    
}

@end
