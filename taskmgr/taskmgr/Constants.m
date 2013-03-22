//
//  Constants.m
//  taskmgr
//
//  Created by David Newman on 3/16/13.
//  Copyright (c) 2013 OBS. All rights reserved.
//

#import "Constants.h"


NSString* const kAPIURL = @"http://taskmgr.cloudfoundry.com/tasks";
NSString* const kLowPriority = @"LOW";
NSString* const kMediumPriority = @"MEDIUM";
NSString* const kHighPriority = @"HIGH";
NSString* const kStatusComplete = @"complete";
NSString* const kStatusPending = @"pending";




@implementation Constants

+(UIColor*) OBSBlue
{
    return [UIColor colorWithRed:117/255.0f green:206/255.0f blue:222/255.0f alpha:1];
}

+(UIColor*) OBSDarkGray
{
    return [UIColor colorWithRed:158/255.0f green:159/255.0f blue:158/255.0f alpha:1];
}

+(UIColor*) OBSLightGray
{
    return [UIColor colorWithRed:229/255.0f green:229/255.0f blue:229/255.0f alpha:1];
}

@end
