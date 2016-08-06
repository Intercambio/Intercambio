//
//  ICAppWireframe.m
//  Intercambio
//
//  Created by Tobias Kraentzer on 13.06.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import "ICAppWireframe.h"
#import "ICAccountShareActivityItemSource.h"
#import "ICEmptyViewController.h"

@interface ICAppWireframe () <UITabBarControllerDelegate, UISplitViewControllerDelegate>
@property (nonatomic, weak) UISplitViewController *splitViewController;
@property (nonatomic, weak) UITabBarController *tabBarController;

@property (nonatomic, weak) UINavigationController *conversationsNavigationController;
@property (nonatomic, weak) UINavigationController *accountsNavigationController;
@end

@implementation ICAppWireframe

#pragma mark Main User Interface

- (void)presentLaunchScreen
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"LaunchScreen"
                                                         bundle:[NSBundle mainBundle]];
    self.window.rootViewController = [storyboard instantiateInitialViewController];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
}

- (void)presentMainInterface
{
    UINavigationController *conversationsNavigationController = [self navigationControllerForPrimaryViewController:[self recentConversationsViewController]];
    UINavigationController *accountsNavigationController = [self navigationControllerForPrimaryViewController:[self.accountListModule viewController]];

    UITabBarController *tabBar = [[UITabBarController alloc] init];
    tabBar.view.backgroundColor = [UIColor whiteColor];
    tabBar.delegate = self;
    tabBar.viewControllers = @[
        conversationsNavigationController,
        accountsNavigationController
    ];

    UISplitViewController *mainViewController = [[UISplitViewController alloc] init];
    mainViewController.delegate = self;
    mainViewController.viewControllers = @[
        tabBar,
        [[ICEmptyViewController alloc] init]
    ];
    mainViewController.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;

    self.tabBarController = tabBar;
    self.splitViewController = mainViewController;

    self.conversationsNavigationController = conversationsNavigationController;
    self.accountsNavigationController = accountsNavigationController;

    self.window.rootViewController = mainViewController;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
}

- (void)presentUnrecoverableError:(NSError *)error
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Unrecoverable Error", nil)
                                                                   message:NSLocalizedString(@"An error has occured, that can't be resloved. Please contact support.", nil)
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
}

#pragma mark Conversations

- (void)presentUserInterfaceForConversationWithURI:(NSURL *)conversationURI
                                fromViewController:(UIViewController *)sender
{
    UIViewController *viewController = [self viewControllerForConversationWithURI:conversationURI];
    [self.splitViewController showDetailViewController:viewController sender:sender];
}

- (void)presentUserInterfaceForNewConversationFromViewController:(UIViewController *)sender
{
    UIViewController *viewController = [self viewControllerForNewConversation];
    [self.splitViewController showDetailViewController:viewController sender:sender];
}

#pragma mark Accounts

- (void)presentUserInterfaceForAccountWithURI:(NSURL *)accountURI
                           fromViewController:(UIViewController *)sender
{
    [self presentAccountUserInterfaceFor:accountURI];
}

- (void)presentUserInterfaceForNewAccountFromViewController:(UIViewController *)viewController
{
    UIAlertController *alert = [self alertForNewAccount];
    if (alert) {
        [self.splitViewController presentViewController:alert
                                               animated:YES
                                             completion:nil];
    }
}

- (void)presentUserInterfaceForSelectingAccountFromViewController:(UIViewController *)viewController
                                                       completion:(void (^)(NSURL *accountURI))completion
{
    if ([self.delegate respondsToSelector:@selector(alertForSelectingAccountInAppWireframe:withCompletion:)]) {
        UIAlertController *alert = [self.delegate alertForSelectingAccountInAppWireframe:self withCompletion:completion];
        alert.title = NSLocalizedString(@"Choose Account", nil);
        alert.message = NSLocalizedString(@"Choose an account to open the conversation.", nil);
        [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
    } else {
        if (completion) {
            completion(nil);
        }
    }
}

#pragma mark Sharing

- (void)presentShareUserInterfaceForAccountWithURI:(NSURL *)accountURI
                                fromViewController:(UIViewController *)viewController
                                            sender:(id)sender
{
    ICAccountShareActivityItemSource *item = [[ICAccountShareActivityItemSource alloc] initWithURI:accountURI];

    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[ item ]
                                                                             applicationActivities:nil];

    NSArray *excludeActivities = @[ UIActivityTypeAirDrop,
                                    UIActivityTypePrint,
                                    UIActivityTypeAssignToContact,
                                    UIActivityTypeSaveToCameraRoll,
                                    UIActivityTypeAddToReadingList,
                                    UIActivityTypePostToFlickr,
                                    UIActivityTypePostToVimeo ];
    activityVC.excludedActivityTypes = excludeActivities;

    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        activityVC.popoverPresentationController.barButtonItem = sender;
    } else if ([sender isKindOfClass:[UIView class]]) {
        activityVC.popoverPresentationController.sourceView = sender;
        activityVC.popoverPresentationController.sourceRect = [sender bounds];
    }

    [self.splitViewController presentViewController:activityVC
                                           animated:YES
                                         completion:^{

                                         }];
}

#pragma mark UITabBarControllerDelegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if (tabBarController.splitViewController.collapsed == NO &&
        [viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)viewController;
        [navigationController popToRootViewControllerAnimated:NO];
    }
}

#pragma mark UISplitViewControllerDelegate

- (void)collapsViewControllers:(NSArray *)viewControllers ontoTabBarController:(UITabBarController *)tabBarController
{
    // Find the correct tab to collaps the view controllers onto …

    UIViewController *selectedViewController = tabBarController.selectedViewController;

    if ([selectedViewController isKindOfClass:[UINavigationController class]] &&
        [[(UINavigationController *)selectedViewController topViewController] conformsToProtocol:@protocol(ICRecentConversationsUserInterface)]) {
        if ([[viewControllers firstObject] conformsToProtocol:@protocol(ICConversationUserInterface)]) {
            UINavigationController *navigationController = (UINavigationController *)selectedViewController;
            navigationController.viewControllers = [navigationController.viewControllers arrayByAddingObjectsFromArray:viewControllers];
        }
    }
}

- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController
{
    if ([secondaryViewController isKindOfClass:[ICEmptyViewController class]]) {
        return YES;
    }

    if ([secondaryViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)secondaryViewController;
        UITabBarController *tabBarController = (UITabBarController *)primaryViewController;
        [self collapsViewControllers:navigationController.viewControllers ontoTabBarController:tabBarController];
        return YES;
    }

    return NO;
}

- (UIViewController *)splitViewController:(UISplitViewController *)splitViewController separateSecondaryViewControllerFromPrimaryViewController:(UIViewController *)primaryViewController
{
    if ([primaryViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController *)primaryViewController;
        if ([tabBarController.selectedViewController isKindOfClass:[UINavigationController class]]) {

            UINavigationController *navigationController = (UINavigationController *)tabBarController.selectedViewController;
            NSMutableArray *viewControllers = [navigationController.viewControllers mutableCopy];

            if ([viewControllers count] > 0) {
                navigationController.viewControllers = @[ [viewControllers firstObject] ];

                if ([viewControllers count] > 1) {
                    [viewControllers removeObjectAtIndex:0];
                    UINavigationController *navigationController = [[UINavigationController alloc] init];
                    navigationController.viewControllers = viewControllers;
                    return navigationController;
                } else {
                    return [[ICEmptyViewController alloc] init];
                }
            }
        }
    }
    return nil;
}

- (BOOL)splitViewController:(UISplitViewController *)splitViewController showDetailViewController:(UIViewController *)vc sender:(nullable id)sender
{
    if (splitViewController.collapsed) {
        UINavigationController *navigationController = [self.tabBarController.viewControllers firstObject];
        [navigationController pushViewController:vc animated:YES];
        return YES;
    } else {
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
        splitViewController.viewControllers = @[
            [splitViewController.viewControllers firstObject],
            navigationController
        ];
        return YES;
    }
}

#pragma mark AccountRouter, AccountListRouter

- (void)presentNewAccountUserInterface
{
    UIAlertController *alert = [self alertForNewAccount];
    if (alert) {
        [self.splitViewController presentViewController:alert
                                               animated:YES
                                             completion:nil];
    }
}

- (void)presentAccountUserInterfaceFor:(NSURL *)accountURI
{
    BOOL accountsNavigationVisible = self.tabBarController.selectedViewController == self.accountsNavigationController;

    UIViewController *viewController = [self.accountModule viewControllerWithUri:accountURI];
    if ([self.accountsNavigationController.viewControllers count] > 1) {
        [self.accountsNavigationController popToRootViewControllerAnimated:NO];
        [self.accountsNavigationController pushViewController:viewController animated:NO];
    } else {
        [self.accountsNavigationController pushViewController:viewController animated:accountsNavigationVisible];
    }

    if (!accountsNavigationVisible) {
        self.tabBarController.selectedViewController = self.accountsNavigationController;
    }
}

- (void)presentSettingsUserInterfaceFor:(NSURL *_Nonnull)accountURI
{
    UIViewController *viewController = [self.settingsModule viewControllerWithUri:accountURI
                                                                       completion:^(BOOL saved, UIViewController *_Nonnull controller) {
                                                                           [controller dismissViewControllerAnimated:YES completion:nil];
                                                                       }];

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;

    [self.splitViewController presentViewController:navigationController
                                           animated:YES
                                         completion:nil];
}

#pragma mark -

- (UIViewController *)recentConversationsViewController
{
    UIViewController *viewController = nil;
    if ([self.delegate respondsToSelector:@selector(viewControllerForRecentConversationsInAppWireframe:)]) {
        viewController = [self.delegate viewControllerForRecentConversationsInAppWireframe:self];
    }
    [self prepareViewController:viewController];
    return viewController ?: [[ICEmptyViewController alloc] init];
}

- (UIViewController *)viewControllerForConversationWithURI:(NSURL *)conversationURI
{
    UIViewController *viewController = nil;
    if ([self.delegate respondsToSelector:@selector(viewControllerForConversationInAppWireframe:)]) {
        UIViewController<ICConversationUserInterface> *conversationViewController = [self.delegate viewControllerForConversationInAppWireframe:self];
        conversationViewController.conversationURI = conversationURI;
        viewController = conversationViewController;
    }
    [self prepareViewController:viewController];
    return viewController ?: [[ICEmptyViewController alloc] init];
}

- (UIViewController *)viewControllerForNewConversation
{
    UIViewController *viewController = nil;
    if ([self.delegate respondsToSelector:@selector(viewControllerForConversationInAppWireframe:)]) {
        viewController = [self.delegate viewControllerForConversationInAppWireframe:self];
    }
    [self prepareViewController:viewController];
    return viewController ?: [[ICEmptyViewController alloc] init];
}

- (UINavigationController *)navigationControllerForPrimaryViewController:(UIViewController *)primaryViewController
{
    UINavigationController *navigationController = nil;
    if ([self.delegate respondsToSelector:@selector(appWireframe:navigationControllerForPrimaryViewController:)]) {
        navigationController = [self.delegate appWireframe:self navigationControllerForPrimaryViewController:primaryViewController];
    }
    [self prepareViewController:navigationController];
    return navigationController ?: [[UINavigationController alloc] initWithRootViewController:primaryViewController];
}

- (UIAlertController *)alertForNewAccount
{
    UIAlertController *alert = nil;
    if ([self.delegate alertForNewAccountInAppWireframe:self]) {
        alert = [self.delegate alertForNewAccountInAppWireframe:self];
    }
    return alert;
}

#pragma mark -

- (void)prepareViewController:(UIViewController *)viewController
{
    if ([viewController conformsToProtocol:@protocol(ICUserInterface)]) {
        UIViewController<ICUserInterface> *userInterfaceViewController = (UIViewController<ICUserInterface> *)viewController;
        userInterfaceViewController.appWireframe = self;
    }
}

@end
