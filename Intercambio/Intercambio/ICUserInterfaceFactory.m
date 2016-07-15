//
//  ICUserInterfaceFactory.m
//  Intercambio
//
//  Created by Tobias Kraentzer on 13.06.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import "ICUserInterfaceFactory.h"
#import "ICAccountSettingsViewController.h"
#import "ICAccountsViewController.h"
#import "ICConversationViewController.h"
#import "ICConversationViewController.h"
#import "ICNavigationController.h"
#import "ICRecentConversationsViewController.h"

@interface ICUserInterfaceFactory ()

@end

@implementation ICUserInterfaceFactory

+ (NSURL *)accountURLFromString:(NSString *)string
{
    static NSRegularExpression *expression;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __unused NSError *error = nil;
        expression = [NSRegularExpression regularExpressionWithPattern:@"^(([^@]+)@)?([^/]+)(/(.*))?$"
                                                               options:NSRegularExpressionCaseInsensitive
                                                                 error:&error];
        NSAssert(expression, [error localizedDescription]);
    });

    NSArray *matches = [expression matchesInString:string
                                           options:NSMatchingReportCompletion
                                             range:NSMakeRange(0, [string length])];

    if ([matches count] == 1) {
        NSTextCheckingResult *match = [matches firstObject];
        NSString *user = [match rangeAtIndex:2].length == 0 ? nil : [string substringWithRange:(NSRange)[match rangeAtIndex:2]];
        NSString *host = [match rangeAtIndex:3].length == 0 ? nil : [string substringWithRange:(NSRange)[match rangeAtIndex:3]];

        NSURLComponents *components = [[NSURLComponents alloc] init];
        components.scheme = @"xmpp";
        components.user = user;
        components.host = host;

        return [components URL];
    } else {
        return nil;
    }
}

#pragma mark Life-cycle

- (instancetype)initWithCommunicationService:(ICCommunicationService *)communicationService
{
    self = [super init];
    if (self) {
        _communicationService = communicationService;
    }
    return self;
}

#pragma mark ICAppWireframeDelegate

- (UIViewController *)viewControllerForRecentConversationsInAppWireframe:(ICAppWireframe *)appWireframe
{
    ICRecentConversationsViewController *recentConversationsViewController = [[ICRecentConversationsViewController alloc] init];
    recentConversationsViewController.dataSource = self.communicationService.conversationDataSource;
    return recentConversationsViewController;
}

- (UIViewController *)viewControllerForAccountsInAppWireframe:(ICAppWireframe *)appWireframe
{
    ICAccountsViewController *accountsViewController = [[ICAccountsViewController alloc] init];
    accountsViewController.dataSource = self.communicationService.accountDataSource;
    return accountsViewController;
}

- (UIViewController<ICConversationUserInterface> *)viewControllerForConversationInAppWireframe:(ICAppWireframe *)appWireframe
{
    ICConversationViewController *viewController = [[ICConversationViewController alloc] init];
    viewController.dataSourceProvider = self.communicationService;
    viewController.accountDataSource = self.communicationService.accountDataSource;
    viewController.conversationProvider = self.communicationService;
    return viewController;
}

- (UINavigationController *)appWireframe:(ICAppWireframe *)appWireframe navigationControllerForPrimaryViewController:(UIViewController *)primaryViewController
{
    ICNavigationController *navigationController = [[ICNavigationController alloc] initWithRootViewController:primaryViewController];
    navigationController.accountDataSource = self.communicationService.accountDataSource;
    navigationController.showConnectionStatus = YES;
    return navigationController;
}

- (UIAlertController *)alertForNewAccountInAppWireframe:(ICAppWireframe *)appWireframe
{
    id<FTMutableDataSource> accountDataSource = self.communicationService.accountDataSource;

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Add Account", nil)
                                                                   message:NSLocalizedString(@"Enter the address of the account you want to use in this App. The server must support Websockets.", nil)
                                                            preferredStyle:UIAlertControllerStyleAlert];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"romeo@example.com", nil);
        textField.keyboardType = UIKeyboardTypeEmailAddress;
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
    }];

    UIAlertAction *addAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Add", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *_Nonnull action) {
                                                          NSString *string = [[alert.textFields firstObject] text];
                                                          NSURL *accountURL = string ? [[self class] accountURLFromString:string] : nil;
                                                          if (accountURL) {
                                                              NSDictionary *properties = @{ ICAccountURIKey : accountURL,
                                                                                            ICAccountEnabledKey : @(YES) };
                                                              [accountDataSource insertItem:properties
                                                                        atProposedIndexPath:nil
                                                                                      error:nil];
                                                          }
                                                      }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *_Nonnull action){

                                                         }];

    [alert addAction:cancelAction];
    [alert addAction:addAction];

    return alert;
}

- (UIAlertController *)alertForSelectingAccountInAppWireframe:(ICAppWireframe *)appWireframe withCompletion:(void (^)(NSURL *accountURI))completion
{
    id<FTDataSource> accountDataSource = self.communicationService.accountDataSource;

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Select an Account", nil)
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];

    NSUInteger numberOfSections = [accountDataSource numberOfSections];
    for (NSUInteger section = 0; section < numberOfSections; section++) {
        NSUInteger numberOfItems = [accountDataSource numberOfItemsInSection:section];
        for (NSUInteger item = 0; item < numberOfItems; item++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            id<ICAccountViewModel> account = [accountDataSource itemAtIndexPath:indexPath];
            UIAlertAction *action = [UIAlertAction actionWithTitle:[account identifier]
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction *_Nonnull action) {
                                                               NSURL *accountURI = [account accountURI];
                                                               if (completion) {
                                                                   completion(accountURI);
                                                               }
                                                           }];
            [alert addAction:action];
        }
    }

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *_Nonnull action) {
                                                             if (completion) {
                                                                 completion(nil);
                                                             }
                                                         }];

    [alert addAction:cancelAction];

    return alert;
}

@end
