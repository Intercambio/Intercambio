//
//  ICNavigationController.m
//  Intercambio
//
//  Created by Tobias Kraentzer on 31.03.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import "ICNavigationController.h"
#import "ICAppWireframe.h"
#import "ICNavigationBar.h"
#import <IntercambioCore/IntercambioCore.h>

@interface ICNavigationController () <FTDataSourceObserver, ICNavigationBarDelegate>

@end

@implementation ICNavigationController

@synthesize appWireframe = _appWireframe;

#pragma mark Life-cycle

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithNavigationBarClass:[ICNavigationBar class]
                                toolbarClass:nil];
    if (self) {
        self.viewControllers = @[ rootViewController ];
    }
    return self;
}

#pragma mark Data Source

- (void)setAccountDataSource:(id<FTDataSource>)accountDataSource
{
    if (_accountDataSource != accountDataSource) {
        [_accountDataSource removeObserver:self];
        _accountDataSource = accountDataSource;
        [_accountDataSource addObserver:self];
        [self updateConnectionStates];
    }
}

#pragma mark Connection Status

- (void)setShowConnectionStatus:(BOOL)showConnectionStatus
{
    if (_showConnectionStatus != showConnectionStatus) {
        _showConnectionStatus = showConnectionStatus;
        [self updateConnectionStates];
    }
}

#pragma mark Update Connection States

- (void)updateConnectionStates
{
    if ([self.navigationBar isKindOfClass:[ICNavigationBar class]]) {
        ICNavigationBar *navigationBar = (ICNavigationBar *)self.navigationBar;
        if (self.showConnectionStatus && [self.accountDataSource numberOfSections] > 0) {
            NSMutableArray *accounts = [[NSMutableArray alloc] init];
            NSUInteger numberOfItems = [self.accountDataSource numberOfItemsInSection:0];
            for (NSUInteger item = 0; item < numberOfItems; item++) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:0];
                id<ICAccountViewModel> account = [self.accountDataSource itemAtIndexPath:indexPath];
                if (account && [account enabled] == YES && account.connectionState != ICAccountConnectionStateConnected) {
                    [accounts addObject:account];
                }
            }
            navigationBar.accounts = accounts;
        } else {
            navigationBar.accounts = @[];
        }
    }
}

#pragma mark FTDataSourceObserver

- (void)dataSourceDidReset:(id<FTDataSource>)dataSource
{
    [self updateConnectionStates];
}

- (void)dataSourceDidChange:(id<FTDataSource>)dataSource
{
    [self updateConnectionStates];
}

#pragma mark ICNavigationBarDelegate

- (void)navigationBar:(UINavigationBar *)navigationBar didTapAccount:(id<ICAccountViewModel>)account
{
    [self.appWireframe presentUserInterfaceForAccountWithURI:account.accountURI
                                          fromViewController:self];
}

@end
