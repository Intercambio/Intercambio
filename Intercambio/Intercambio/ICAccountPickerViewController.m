//
//  ICAccountPickerViewController.m
//  Intercambio
//
//  Created by Tobias Kraentzer on 14.06.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import "ICAccountPickerViewController.h"

@interface ICAccountPickerViewController () <UITableViewDelegate>
@property (nonatomic, readwrite) FTTableViewAdapter *tableViewAdapter;
@end

@implementation ICAccountPickerViewController

#pragma mark Life-cycle

- (instancetype)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
    }
    return self;
}

#pragma mark UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.allowsSelection = YES;
    self.tableView.allowsMultipleSelection = NO;

    self.tableViewAdapter = [[FTTableViewAdapter alloc] initWithTableView:self.tableView];
    self.tableViewAdapter.delegate = self;
    self.tableViewAdapter.dataSource = self.dataSource;
    self.tableViewAdapter.reloadMovedItems = YES;

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    [self.tableViewAdapter forRowsMatchingPredicate:[NSPredicate predicateWithValue:YES]
                         useCellWithReuseIdentifier:@"UITableViewCell"
                                       prepareBlock:^(UITableViewCell *cell,
                                                      id<ICAccountViewModel> account,
                                                      NSIndexPath *indexPath,
                                                      id<FTDataSource> dataSource) {
                                           cell.textLabel.text = [account identifier];
                                       }];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(cancel:)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateSelection:NO];
}

#pragma mark Actions

- (IBAction)cancel:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(accountPickerDidCancel:)]) {
        [self.delegate accountPickerDidCancel:self];
    }
}

#pragma mark Properties

- (void)setDataSource:(id<FTDataSource, FTReverseDataSource>)dataSource
{
    if (_dataSource != dataSource) {
        _dataSource = dataSource;
        self.tableViewAdapter.dataSource = dataSource;
    }
}

- (void)setSelectedAccount:(id<ICAccountViewModel>)selectedAccount
{
    if (_selectedAccount != selectedAccount) {
        _selectedAccount = selectedAccount;
        [self updateSelection:NO];
    }
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<ICAccountViewModel> account = [self.dataSource itemAtIndexPath:indexPath];
    if ([self.delegate respondsToSelector:@selector(accountPicker:didPickAccount:)]) {
        [self.delegate accountPicker:self didPickAccount:account];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView.indexPathForSelectedRow isEqual:indexPath]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

#pragma mark -

- (void)updateSelection:(BOOL)animated
{
    NSIndexPath *indexPath = nil;
    if (self.selectedAccount) {
        indexPath = [[self.dataSource indexPathsOfItem:self.selectedAccount] firstObject];
    }

    if (indexPath) {
        [self.tableView selectRowAtIndexPath:indexPath animated:animated scrollPosition:UITableViewScrollPositionNone];
    } else {
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    }
}

@end
