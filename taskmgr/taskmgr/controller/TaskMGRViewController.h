//
//  TaskMGRViewController.h
//  taskmgr
//
//  Created by David Newman on 3/18/13.
//  Copyright (c) 2013 OBS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APIController.h"

@interface TaskMGRViewController : UIViewController <APIControllerDelegate>

-(void)applyRoundCornersOnView:(UIView *)view withRadius:(float)radius;

@end
