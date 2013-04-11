//
//  TaskFormViewController.m
//  taskmgr
//
//  Created by David Newman on 3/17/13.
//  Copyright (c) 2013 OBS. All rights reserved.
//

#import "TaskFormViewController.h"
#import "SVSegmentedControl.h"
#import "SVSegmentedThumb.h"
#import "Constants.h"
#import <QuartzCore/QuartzCore.h>
#import "MBProgressHUD.h"

@interface TaskFormViewController ()
{
    IBOutlet UITextField *textFieldDescription;
    IBOutlet UITextField *textFieldDueDate;
    IBOutlet UIView *viewSegmentedControlContainer;
    IBOutlet UIBarButtonItem *buttonSave;
    MBProgressHUD *HUD;

    SVSegmentedControl *segmentedControlPriority;
    UIDatePicker *datePicker;
}
@end

@implementation TaskFormViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    datePicker = [[UIDatePicker alloc] init];
//    [textFieldDueDate setInputView:datePicker];


    // Do any additional setup after loading the view.
    segmentedControlPriority = [[SVSegmentedControl alloc] initWithSectionTitles:[NSArray arrayWithObjects:kLowPriority, kMediumPriority, kHighPriority, nil]];

    __weak SVSegmentedControl *_segmentedControlPriority = segmentedControlPriority;
    [segmentedControlPriority setSelectedIndex:1];
    [segmentedControlPriority.thumb setTintColor:[UIColor orangeColor]];
    segmentedControlPriority.changeHandler = ^(NSUInteger newIndex) {
        switch (newIndex) {
            case 0:
                _segmentedControlPriority.thumb.tintColor = [UIColor greenColor];
                break;
            case 1:
                _segmentedControlPriority.thumb.tintColor = [UIColor orangeColor];
                break;
            case 2:
                _segmentedControlPriority.thumb.tintColor = [UIColor redColor];
                break;
            default:
                _segmentedControlPriority.thumb.tintColor = [UIColor redColor];
                break;
        }
    };


    [segmentedControlPriority setCornerRadius:16];
    [segmentedControlPriority setCenter:CGPointMake(self.view.frame.size.width / 2, 16)];
    [viewSegmentedControlContainer addSubview:segmentedControlPriority];

    [self applyRoundCornersOnView:textFieldDescription withRadius:15.0];
    [self applyRoundCornersOnView:textFieldDueDate withRadius:15.0];

    NSLog(@"%@", segmentedControlPriority.sectionTitles);
    NSLog(@"%f,%f,%f,%f", segmentedControlPriority.frame.origin.x, segmentedControlPriority.frame.origin.y, segmentedControlPriority.frame.size.width, segmentedControlPriority.frame.size.height);
    NSLog(@"TextField:%f,%f,%f,%f", textFieldDescription.frame.origin.x, textFieldDescription.frame.origin.y, textFieldDescription.frame.size.width, textFieldDescription.frame.size.height);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];

    if (textFieldDescription.text.length > 0) {
        [buttonSave setEnabled:YES];
    } else {
        [buttonSave setEnabled:NO];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - InterfaceBuilder Methods

- (IBAction)saveTask:(id)sender {
    NSDate *duedate;
    if (datePicker.date) {
        duedate = datePicker.date;
    } else {
        duedate = nil;
    }
    NSLog(@"%@", textFieldDescription);
    NSLog(@"%@", textFieldDueDate);

    NSString *priority = (NSString *)[segmentedControlPriority.sectionTitles objectAtIndex:segmentedControlPriority.selectedIndex];
    NSString *pendingStatus = @"pending";

    [[APIController sharedController] postNewTaskWithDescription:textFieldDescription.text duedate:duedate priority:priority status:pendingStatus];
}

- (IBAction)cancelButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)textFieldDescriptionEdited:(UITextField *)sender {
    if (textFieldDescription.text.length > 0) {
        [buttonSave setEnabled:YES];
    } else {
        [buttonSave setEnabled:NO];
    }
}

#pragma mark - UITextView Delegate Methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, 44)];
    toolBar.barStyle = UIBarStyleBlack;
    toolBar.backgroundColor = [Constants OBSDarkGray];
    toolBar.translucent = YES;

    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneWriting:)];

    UIBarButtonItem *clearButton = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStyleBordered target:self action:@selector(clearTextField:)];

    [doneButton setTintColor:[Constants OBSBlue]];
    [clearButton setTintColor:[UIColor redColor]];

    [clearButton setTitle:@"Clear"];

    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];

    [toolBar setItems:[NSArray arrayWithObjects:clearButton, flex, doneButton,
                       nil]];

    textField.inputAccessoryView = toolBar;
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([textField isEqual:textFieldDueDate]) {
        if (datePicker == nil) {
            datePicker = [[UIDatePicker alloc] init];
            datePicker.datePickerMode = UIDatePickerModeDate;
            datePicker.minimumDate = [NSDate date];
            [datePicker addTarget:self action:@selector(incidentDateValueChanged:) forControlEvents:UIControlEventValueChanged];
        }
        textField.inputView = datePicker;
    }
}

- (IBAction)incidentDateValueChanged:(id)sender {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd-yyyy"];
    textFieldDueDate.text = [dateFormatter stringFromDate:[datePicker date]];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)clearTextField:(id)sender {
    if ([textFieldDueDate isFirstResponder]) {
        [datePicker setDate:[NSDate date]];
        [textFieldDueDate setText:nil];
        [textFieldDueDate resignFirstResponder];
    } else if ([textFieldDescription isFirstResponder]) {
        [buttonSave setEnabled:NO];
        [textFieldDescription setText:nil];
    }
}

- (void)doneWriting:(id)sender {
    for (UITextField *textField in self.view.subviews) {
        if ([textField isKindOfClass:[UITextField class]]) [textField resignFirstResponder];
    }
}

#pragma mark - APIController Delegate Methods

- (void)didFinishUploadingTask {
    [super didFinishUploadingTask];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
