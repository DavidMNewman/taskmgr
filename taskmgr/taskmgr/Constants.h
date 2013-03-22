//
//  Constants.h
//  taskmgr
//
//  Created by David Newman on 3/16/13.
//  Copyright (c) 2013 OBS. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* const kAPIURL;
extern NSString* const kLowPriority;
extern NSString* const kMediumPriority;
extern NSString* const kHighPriority;
extern NSString* const kStatusPending;
extern NSString* const kStatusComplete;




@interface Constants : NSObject

+(UIColor*) OBSBlue;
+(UIColor*) OBSDarkGray;
+(UIColor*) OBSLightGray;

@end
