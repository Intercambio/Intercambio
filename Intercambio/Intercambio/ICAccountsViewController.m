//
//  ICAccountsViewController.m
//  Intercambio
//
//  Created by Tobias Kräntzer on 16.02.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import "ICAccountsViewController.h"
#import "ICAccountCell.h"
#import "ICAppWireframe.h"
#import <Fountain/Fountain.h>
#import <IntercambioCore/IntercambioCore.h>

@interface ICAccountsViewController () <UITableViewDelegate>
@property (nonatomic, readwrite) FTTableViewAdapter *tableViewAdapter;
@end

@implementation ICAccountsViewController

@synthesize appWireframe = _appWireframe;

#pragma mark Life-cycle

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = NSLocalizedString(@"Accounts", nil);
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Accounts", nil)
                                                        image:[UIImage imageNamed:@"779-users"]
                                                selectedImage:[UIImage imageNamed:@"779-users-selected"]];
    }
    return self;
}

#pragma mark UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableViewAdapter = [[FTTableViewAdapter alloc] initWithTableView:self.tableView];
    self.tableViewAdapter.delegate = self;
    self.tableViewAdapter.dataSource = self.dataSource;
    self.tableViewAdapter.reloadMovedItems = YES;

    [self.tableView registerClass:[ICAccountCell class] forCellReuseIdentifier:@"ICAccountCell"];
    [self.tableViewAdapter forRowsMatchingPredicate:[NSPredicate predicateWithValue:YES]
                         useCellWithReuseIdentifier:@"ICAccountCell"
                                       prepareBlock:^(ICAccountCell *cell,
                                                      id<ICAccountViewModel> account,
                                                      NSIndexPath *indexPath,
                                                      id<FTDataSource> dataSource) {
                                           cell.textLabel.text = account.identifier;
                                       }];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                           target:self
                                                                                           action:@selector(addAccount:)];
}

#pragma mark Actions

- (IBAction)addAccount:(id)sender
{
    [self.appWireframe presentUserInterfaceForNewAccountFromViewController:self];
}

#pragma mark Data Source

- (void)setDataSource:(id<FTDataSource>)dataSource
{
    if (_dataSource != dataSource) {
        _dataSource = dataSource;
        self.tableViewAdapter.dataSource = dataSource;
    }
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<ICAccountViewModel> account = [self.dataSource itemAtIndexPath:indexPath];
    NSURL *accountURI = [account accountURI];
    [self.appWireframe presentUserInterfaceForAccountWithURI:accountURI fromViewController:self];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    id<ICAccountViewModel> account = [self.dataSource itemAtIndexPath:indexPath];
    NSURL *accountURI = [account accountURI];
    [self.appWireframe presentShareUserInterfaceForAccountWithURI:accountURI fromViewController:self sender:sender];
}

@end
