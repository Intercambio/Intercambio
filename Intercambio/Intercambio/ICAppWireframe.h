//
//  ICAppWireframe.h
//  Intercambio
//
//  Created by Tobias Kraentzer on 13.06.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import "ICAccountSettingsUserInterface.h"
#import "ICAccountsUserInterface.h"
#import "ICConversationUserInterface.h"
#import "ICRecentConversationsUserInterface.h"
#import "Intercambio-Swift.h"
#import <UIKit/UIKit.h>

@class ICAppWireframe;

@protocol ICAppWireframeDelegate <NSObject>
@optional
- (UIViewController<ICRecentConversationsUserInterface> *)viewControllerForRecentConversationsInAppWireframe:(ICAppWireframe *)appWireframe;
- (UIViewController<ICConversationUserInterface> *)viewControllerForConversationInAppWireframe:(ICAppWireframe *)appWireframe;

- (UIAlertController *)alertForNewAccountInAppWireframe:(ICAppWireframe *)appWireframe;
- (UIAlertController *)alertForSelectingAccountInAppWireframe:(ICAppWireframe *)appWireframe withCompletion:(void (^)(NSURL *accountURI))completion;
@end

@interface ICAppWireframe : NSObject <AccountRouter, AccountListRouter, NavigationControllerRouter>

@property (nonatomic, weak) id<ICAppWireframeDelegate> delegate;
@property (nonatomic, strong) UIWindow *window;

@property (nonatomic, strong) NavigationControllerModule *navigationControllerModule;
@property (nonatomic, strong) AccountListModule *accountListModule;
@property (nonatomic, strong) AccountModule *accountModule;
@property (nonatomic, strong) SettingsModule *settingsModule;
@property (nonatomic, strong) RecentConversationsModule *recentConversationsModule;

#pragma mark Main User Interface
- (void)presentLaunchScreen;
- (void)presentMainInterface;
- (void)presentUnrecoverableError:(NSError *)error;

#pragma mark Conversations
- (void)presentUserInterfaceForConversationWithURI:(NSURL *)conversationURI
                                fromViewController:(UIViewController *)viewController;
- (void)presentUserInterfaceForNewConversationFromViewController:(UIViewController *)viewController;

#pragma mark Accounts
- (void)presentUserInterfaceForAccountWithURI:(NSURL *)accountURI
                           fromViewController:(UIViewController *)viewController;
- (void)presentUserInterfaceForNewAccountFromViewController:(UIViewController *)viewController;
- (void)presentUserInterfaceForSelectingAccountFromViewController:(UIViewController *)viewController
                                                       completion:(void (^)(NSURL *accountURI))completion;

#pragma mark Sharing
- (void)presentShareUserInterfaceForAccountWithURI:(NSURL *)accountURI
                                fromViewController:(UIViewController *)viewController
                                            sender:(id)sender;

@end
