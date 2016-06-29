//
//  ICAccountSettingsViewController.m
//  Intercambio
//
//  Created by Tobias Kräntzer on 20.02.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import "ICAccountSettingsViewController.h"
#import "ICAccountOptionsViewController.h"
#import <IntercambioCore/IntercambioCore.h>

@interface ICAccountSettingsViewController () <UITableViewDelegate>

#pragma mark Outlets
@property (weak, nonatomic) IBOutlet UITextField *addressField;
@property (weak, nonatomic) IBOutlet UISwitch *suspensionSwitch;

#pragma mark Account
@property (nonatomic, strong) id<ICAccountViewModel> account;

@end

@implementation ICAccountSettingsViewController

@synthesize appWireframe = _appWireframe;
@synthesize accountURI = _accountURI;

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"self.account.identifier"];
    [self removeObserver:self forKeyPath:@"self.account.enabled"];
    [self removeObserver:self forKeyPath:@"self.account.connectionState"];
    [self removeObserver:self forKeyPath:@"self.account.recentError"];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateInterface];

    [self addObserver:self forKeyPath:@"self.account.identifier" options:0 context:nil];
    [self addObserver:self forKeyPath:@"self.account.enabled" options:0 context:nil];
    [self addObserver:self forKeyPath:@"self.account.connectionState" options:0 context:nil];
    [self addObserver:self forKeyPath:@"self.account.recentError" options:0 context:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"options"]) {
        ICAccountOptionsViewController *viewController = (ICAccountOptionsViewController *)segue.destinationViewController;
        viewController.account = self.account;
    }
}

#pragma mark Account

- (void)setAccountURI:(NSURL *)accountURI
{
    if (![_accountURI isEqual:accountURI]) {
        _accountURI = accountURI;
        if (accountURI) {
            self.account = [self.accountProvider accountWithURI:accountURI];
        } else {
            self.account = nil;
        }
    }
}

- (void)setAccount:(id<ICAccountViewModel>)account
{
    if (_account != account) {
        _account = account;

        [self updateInterface];
    }
}

#pragma mark Actions

- (IBAction)done:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES
                             completion:^{

                             }];
}

- (IBAction)connect:(UIButton *)sender
{
    [self.account connect];
}

- (IBAction)toggleSuspension:(UISwitch *)sender
{
    if (self.account) {
        if (self.account.enabled) {
            [self.account disable];
        } else {
            [self.account enable];
        }
    }
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.item == 0) {
        [self connect:nil];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return [NSString stringWithFormat:NSLocalizedString(@"Account (%@)", nil), [self labelForConnectionState:self.account.connectionState]];
    }

    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        if (self.account.recentError) {
            NSString *errorMessage = [self.account.recentError localizedDescription];
            return errorMessage;
        }
    }

    return nil;
}

#pragma mark Update UI

- (void)updateInterface
{
    self.addressField.enabled = NO;
    self.addressField.text = self.account.identifier;
    self.suspensionSwitch.on = self.account.enabled;
    [self.tableView reloadData];
}

#pragma mark KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *, id> *)change
                       context:(void *)context
{
    [self updateInterface];
}

#pragma mark -

- (NSString *)labelForConnectionState:(ICAccountConnectionState)connectionState
{
    switch (connectionState) {
    case ICAccountConnectionStateDisconnected:
        return NSLocalizedString(@"disconnected", nil);
    case ICAccountConnectionStateConnecting:
        return NSLocalizedString(@"connecting", nil);
    case ICAccountConnectionStateConnected:
        return NSLocalizedString(@"connected", nil);
    case ICAccountConnectionStateDisconnecting:
        return NSLocalizedString(@"disconnecting", nil);
    }
}

@end
