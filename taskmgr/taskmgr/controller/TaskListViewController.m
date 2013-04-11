//
//  TaskListViewController.m
//  taskmgr
//
//  Created by David Newman on 3/16/13.
//  Copyright (c) 2013 OBS. All rights reserved.
//

#import "TaskListViewController.h"
#import "BlockAlertView.h"
#import "MBProgressHUD.h"
#import "Constants.h"
#import <QuartzCore/QuartzCore.h>

@interface TaskListViewController ()
{
    IBOutlet UISearchBar *tasksSearchBar;
    NSArray *allTasks;
    NSMutableArray *filteredTasks;
    IBOutlet UITableView *tableViewTasks;
    BOOL isFiltered;
    NSString *selectedStatus;
}
@end

@implementation TaskListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getAllTasks];

    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [[APIController sharedController] setDelegate:self];
    selectedStatus = kStatusPending;
    [self reloadTaskData];
    
    isFiltered = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getAllTasks {
    [[APIController sharedController] getAllTasks];
}

- (IBAction)taskOptions:(id)sender {
    BlockAlertView *alertView = [BlockAlertView alertWithTitle:@"Options" message:nil];

    [alertView addButtonWithTitle:@"Sort by Due Date" block:^{
        NSSortDescriptor *sortDateDescriptor = [[NSSortDescriptor alloc] initWithKey:@"duedate" ascending:YES];
        allTasks = [allTasks sortedArrayUsingDescriptors:@[sortDateDescriptor]];
        [tableViewTasks reloadData];
    }];

    [alertView addButtonWithTitle:@"Sort By Priority" block:^{
        NSSortDescriptor *sortPriorityDescriptor = [[NSSortDescriptor alloc] initWithKey:@"priority" ascending:YES comparator:^(NSString *obj1, NSString *obj2) {
            if (![obj1 compare:kLowPriority] && ![obj2 compare:kMediumPriority]) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            if (![obj1 compare:kLowPriority] && ![obj2 compare:kHighPriority]) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            if (![obj1 compare:kMediumPriority] && ![obj2 compare:kHighPriority]) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            if (![obj1 compare:kMediumPriority] && ![obj2 compare:kLowPriority]) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            if (![obj1 compare:kHighPriority] && ![obj2 compare:kMediumPriority]) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            if (![obj1 compare:kHighPriority] && ![obj2 compare:kLowPriority]) {
                return (NSComparisonResult)NSOrderedAscending;
            }

            return (NSComparisonResult)NSOrderedSame;
        }];

        allTasks = [allTasks sortedArrayUsingDescriptors:@[sortPriorityDescriptor]];
        [tableViewTasks reloadData];
    }];

    [alertView addButtonWithTitle:@"Pending Tasks" block:^{
        selectedStatus = kStatusPending;
        [self reloadTaskData];
    }];

    [alertView addButtonWithTitle:@"Completed Tasks" block:^{
        selectedStatus = kStatusComplete;
        [self reloadTaskData];
    }];

    [alertView setCancelButtonWithTitle:@"Cancel" block:nil];

    [alertView show];
}

- (void)completeTask:(id)sender {
    UIButton *button = (UIButton *)sender;

    UITableViewCell *cell = (UITableViewCell *)[[button superview] superview];

    Task *taskToComplete = [allTasks objectAtIndex:[tableViewTasks indexPathForCell:cell].row];

    BlockAlertView *blockAlertView = [BlockAlertView alertWithTitle:@"Complete Task?" message:[NSString stringWithFormat:@"Would you like to mark the task %@ as complete?", taskToComplete.taskDescription]];

    [blockAlertView setCancelButtonWithTitle:@"Cancel" block:nil];

    [blockAlertView addButtonWithTitle:@"Yes" block:^{
        [[APIController sharedController] markTaskAsComplete:taskToComplete];
    }];

    [blockAlertView show];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    int rowCount;

    if (isFiltered) rowCount = filteredTasks.count;
    else rowCount = allTasks.count;


    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Task *task;

    if (isFiltered) {
        task = [filteredTasks objectAtIndex:[indexPath row]];
    } else {
        task = [allTasks objectAtIndex:[indexPath row]];
    }

    UITableViewCell *cell;

    if (![task.status compare:kStatusPending]) {
        cell = [tableViewTasks dequeueReusableCellWithIdentifier:@"cellTask"];
        UIButton *buttonCompleteTask = (UIButton *)[cell.contentView viewWithTag:4];
        [buttonCompleteTask addTarget:self action:@selector(completeTask:)
                     forControlEvents:UIControlEventTouchUpInside];
    } else {
        NSLog(@"Task:%@", task);
        cell = [tableViewTasks dequeueReusableCellWithIdentifier:@"cellTaskComplete"];
    }


    UILabel *labelDescription = (UILabel *)[cell.contentView viewWithTag:1];
    UILabel *labelDate = (UILabel *)[cell.contentView viewWithTag:2];
    UILabel *labelPriority = (UILabel *)[cell.contentView viewWithTag:3];



    [labelDescription setText:task.taskDescription];
    [labelPriority setText:task.priority];

    if (![labelPriority.text compare:kHighPriority]) {
        [labelPriority setBackgroundColor:[UIColor redColor]];
    } else if (![labelPriority.text compare:kMediumPriority]) {
        [labelPriority setBackgroundColor:[UIColor orangeColor]];
    } else {
        [labelPriority setBackgroundColor:[UIColor greenColor]];
    }

    [self applyRoundCornersOnView:labelPriority withRadius:10.0];


    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd-yyyy"];

    [labelDate setText:[dateFormatter stringFromDate:task.duedate]];


    UIView *selectedBackgroundView = [[UIView alloc] init];
    UIColor *backgroundColor = [Constants OBSBlue];
    [selectedBackgroundView setBackgroundColor:backgroundColor];
    [cell setSelectedBackgroundView:selectedBackgroundView];


    return cell;
}

#pragma mark - UITableView Delegate Method

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if ([self numberOfSectionsInTableView:tableView] == (section + 1)) {
        return [UIView new];
    }
    return nil;
}

#pragma mark - APIController Delegate Method

- (void)reloadTaskData {
    [super reloadTaskData];

    [filteredTasks removeAllObjects];
    isFiltered = NO;

    allTasks = [[DataManager sharedInstance].mainObjectContext fetchObjectsForEntityName:@"Task" predicateWithFormat:@"status == %@", selectedStatus];
    NSLog(@"SelectedStatus:%@", selectedStatus);
    [tableViewTasks reloadData];
}

- (void)viewDidUnload {
    tasksSearchBar = nil;
    [super viewDidUnload];
}

#pragma mark - UISearchDisplay Delegate Method

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)text {
    if (text.length == 0) {
        isFiltered = FALSE;
    } else {
        isFiltered = true;
        filteredTasks = [[NSMutableArray alloc] init];

        for (Task *task in allTasks) {
            NSRange desriptionRange = [task.taskDescription rangeOfString:text options:NSCaseInsensitiveSearch];
            NSRange priorityRange = [task.priority rangeOfString:text options:NSCaseInsensitiveSearch];

            if (desriptionRange.location != NSNotFound || priorityRange.location != NSNotFound) {
                [filteredTasks addObject:task];
            }
        }
    }
    [tableViewTasks reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    searchBar.text = @"";
    isFiltered = NO;
    [tableViewTasks reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    return YES;
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller {
}

@end
