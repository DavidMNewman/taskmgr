//
//  TaskMGRViewController.m
//  taskmgr
//
//  Created by David Newman on 3/18/13.
//  Copyright (c) 2013 OBS. All rights reserved.
//

#import "TaskMGRViewController.h"
#import "MBProgressHUD.h"
#import "Constants.h"
#import <QuartzCore/QuartzCore.h>


@interface TaskMGRViewController ()
{
    MBProgressHUD *HUD;
}

@end

@implementation TaskMGRViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [[APIController sharedController] setDelegate:self];
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)applyRoundCornersOnView:(UIView *)view withRadius:(float)radius
{
    view.clipsToBounds = YES;
    view.layer.cornerRadius = radius;
    view.layer.borderWidth = 1.0;
    view.layer.borderColor = [UIColor blackColor].CGColor;
}

#pragma mark - APIController Delegate Methods

-(void)didFinishUploadingTask
{
    
}
-(void)reloadTaskData
{
    
}
- (void)showErrorMessage:(NSString *)message
{
//    [self removeAllMessages];
    
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error.png"]];
    
    HUD.labelText = message;
    HUD.color = [UIColor redColor];
    [HUD hide:YES afterDelay:1.5];
    [HUD show:YES];
}

- (void)showSuccessWithMessage:(NSString *)message
{
//    [self removeAllMessages];
    
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"success.png"]];
    
    HUD.labelText = message;
    HUD.color = [Constants OBSBlue];
    [HUD hide:YES afterDelay:1.5];
    [HUD show:YES];
}

- (void)showStatusWithMessage:(NSString *)message {
    
//    [self removeAllMessages];
    
    HUD.mode = MBProgressHUDModeIndeterminate;
    HUD.labelText = message;
    HUD.color = [Constants OBSBlue];
    [HUD show:YES];
}

- (void)removeAllMessages
{
    [HUD hide:YES];
    //    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
}

@end
