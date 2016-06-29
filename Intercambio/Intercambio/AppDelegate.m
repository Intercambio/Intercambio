//
//  AppDelegate.m
//  Intercambio
//
//  Created by Tobias Kräntzer on 18.01.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

@import HockeySDK;

#if __has_include("Secrets.h")
#import "Secrets.h"
#endif

#ifndef ICApplicationHockeyIdentifier
#define ICApplicationHockeyIdentifier @"<add an identifier>"
#endif

#import "AppDelegate.h"
#import "ICAppWireframe.h"
#import "ICURLHandler.h"
#import "ICUserInterfaceFactory.h"
#import <CocoaLumberjack/CocoaLumberjack.h>
#import <IntercambioCore/IntercambioCore.h>

static DDLogLevel ddLogLevel = DDLogLevelInfo;

@interface AppDelegate () <ICCommunicationServiceDelegate,
                           BITHockeyManagerDelegate> {
    ICCommunicationService *_communicationService;
    ICUserInterfaceFactory *_userInterfaceFactory;
    ICAppWireframe *_appWireframe;
    ICURLHandler *_URLHandler;
    UIBackgroundTaskIdentifier _accountManagerBackgroundTaskIdentifier;
    BOOL _isPerformingFetch;
    BOOL _isSetup;
    NSURL *_documentDirectoryURL;
    NSURL *_pendingURLToHandle;
}

@end

@implementation AppDelegate

+ (void)initialize
{
    [DDLog setLevel:DDLogLevelDebug forClassWithName:@"XMPPAccountManager"];
    [DDLog setLevel:DDLogLevelDebug forClassWithName:@"XMPPClient"];
    [DDLog setLevel:DDLogLevelDebug forClassWithName:@"XMPPWebsocketStream"];
    [DDLog setLevel:DDLogLevelDebug forClassWithName:@"XMPPStreamFeatureStreamManagement"];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    DDLogInfo(@"Application did finish launching.");

    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:ICApplicationHockeyIdentifier delegate:self];
    [[BITHockeyManager sharedHockeyManager] startManager];
    [[BITHockeyManager sharedHockeyManager].authenticator authenticateInstallation];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    NSDictionary *options = @{};
    _communicationService = [[ICCommunicationService alloc] initWithOptions:options];
    _communicationService.delegate = self;

    _userInterfaceFactory = [[ICUserInterfaceFactory alloc] initWithCommunicationService:_communicationService];
    _appWireframe = [[ICAppWireframe alloc] init];
    _appWireframe.delegate = _userInterfaceFactory;
    _appWireframe.window = self.window;
    [_appWireframe presentLaunchScreen];

    _URLHandler = [[ICURLHandler alloc] initWithAppWireframe:_appWireframe];
    _URLHandler.accountProvider = _communicationService;

    [self setupLogging];

    if ([self didCrashInLastSessionOnStartup] == NO) {
        [self setupApplicationWithCompletion:^(BOOL success, NSError *error) {
            [self setupUserInterfaceWithError:success ? nil : error];
        }];
    }

    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    DDLogInfo(@"Application will enter background.");
    _accountManagerBackgroundTaskIdentifier = UIBackgroundTaskInvalid;

    _accountManagerBackgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithName:@"Account Manager"
                                                                                           expirationHandler:^{
                                                                                               DDLogInfo(@"Background task expired.");
                                                                                               [[UIApplication sharedApplication] endBackgroundTask:_accountManagerBackgroundTaskIdentifier];
                                                                                               _accountManagerBackgroundTaskIdentifier = UIBackgroundTaskInvalid;
                                                                                               [DDLog flushLog];
                                                                                           }];

    if (_accountManagerBackgroundTaskIdentifier == UIBackgroundTaskInvalid) {
        DDLogInfo(@"Entering the background.");
        [DDLog flushLog];
    } else {
        DDLogInfo(@"Continue account manager with a long running task (%lu) in the background.", (unsigned long)_accountManagerBackgroundTaskIdentifier);
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    DDLogInfo(@"Application will enter foreground.");

    [_communicationService exchangeAcknowledgements];

    if (_accountManagerBackgroundTaskIdentifier != UIBackgroundTaskInvalid) {
        DDLogInfo(@"Canceling background task (%lu) for account manager.", (unsigned long)_accountManagerBackgroundTaskIdentifier);
        [[UIApplication sharedApplication] endBackgroundTask:_accountManagerBackgroundTaskIdentifier];
        _accountManagerBackgroundTaskIdentifier = UIBackgroundTaskInvalid;
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    DDLogInfo(@"Application will terminate.");
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *, id> *)options
{
    if (_isSetup) {
        return [_URLHandler handleURL:url];
    } else {
        _pendingURLToHandle = url;
        return YES;
    }
}

#pragma mark Application Setup

- (void)setupApplicationWithCompletion:(void (^)(BOOL success, NSError *error))completion
{
    __weak typeof(self) _self = self;
    [_communicationService setUpWithCompletion:^(BOOL success, NSError *error) {
        _isSetup = success;
        if (completion) {
            completion(success, error);
        }
        [_self handlePendingOpenURL];
    }];
}

- (void)handlePendingOpenURL
{
    if (_pendingURLToHandle) {
        [_URLHandler handleURL:_pendingURLToHandle];
        _pendingURLToHandle = nil;
    }
}

- (void)setupLogging
{
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [DDLog addLogger:[DDASLLogger sharedInstance]];

    DDLogFileManagerDefault *documentsFileManager = [[DDLogFileManagerDefault alloc] initWithLogsDirectory:[[self documentDirectoryURL] path]];
    DDFileLogger *fileLogger = [[DDFileLogger alloc] initWithLogFileManager:documentsFileManager];
    fileLogger.rollingFrequency = 60 * 60 * 24;
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    [DDLog addLogger:fileLogger];
}

- (void)setupUserInterfaceWithError:(NSError *)error
{
    if (error) {
        [_appWireframe presentUnrecoverableError:error];
    } else {
        [_appWireframe presentMainInterface];
        BOOL hasAccount = [[_communicationService accountDataSource] numberOfSections] > 0 &&
                          [[_communicationService accountDataSource] numberOfItemsInSection:0] > 0;
        if (hasAccount == NO) {
            [_appWireframe presentUserInterfaceForNewAccountFromViewController:nil];
        }
    }
}

#pragma mark ICCommunicationServiceDelegate

- (void)communicationService:(ICCommunicationService *)communicationService
     needsPasswordForAccount:(NSURL *)accountURI
                  completion:(void (^)(NSString *))completion
{
    UIAlertController *passwordController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Login", nil)
                                                                                message:[NSString stringWithFormat:NSLocalizedString(@"Please enter the password for '%@'.", nil), [accountURI absoluteString]]
                                                                         preferredStyle:UIAlertControllerStyleAlert];

    [passwordController addTextFieldWithConfigurationHandler:^(UITextField *_Nonnull textField) {
        textField.placeholder = NSLocalizedString(@"Password", nil);
        textField.secureTextEntry = YES;
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
    }];

    UIAlertAction *authenticate = [UIAlertAction actionWithTitle:NSLocalizedString(@"Login", nil)
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *_Nonnull action) {
                                                             NSString *password = [[passwordController.textFields firstObject] text];
                                                             completion(password);
                                                         }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *action) {
                                                             completion(nil);
                                                         }];

    [passwordController addAction:authenticate];
    [passwordController addAction:cancelAction];

    if (self.window.rootViewController.presentedViewController != nil) {
        [self.window.rootViewController.presentedViewController presentViewController:passwordController animated:YES completion:nil];
    } else {
        [self.window.rootViewController presentViewController:passwordController animated:YES completion:nil];
    }
}

#pragma mark BITCrashManagerDelegate

- (void)crashManagerWillCancelSendingCrashReport:(BITCrashManager *)crashManager
{
    if ([self didCrashInLastSessionOnStartup]) {
        [self setupApplicationWithCompletion:^(BOOL success, NSError *error) {
            [self setupUserInterfaceWithError:success ? nil : error];
        }];
    }
}

- (void)crashManager:(BITCrashManager *)crashManager didFailWithError:(NSError *)error
{
    if ([self didCrashInLastSessionOnStartup]) {
        [self setupApplicationWithCompletion:^(BOOL success, NSError *error) {
            [self setupUserInterfaceWithError:success ? nil : error];
        }];
    }
}

- (void)crashManagerDidFinishSendingCrashReport:(BITCrashManager *)crashManager
{
    if ([self didCrashInLastSessionOnStartup]) {
        [self setupApplicationWithCompletion:^(BOOL success, NSError *error) {
            [self setupUserInterfaceWithError:success ? nil : error];
        }];
    }
}

#pragma mark -

- (BOOL)didCrashInLastSessionOnStartup
{
    return ([[BITHockeyManager sharedHockeyManager].crashManager didCrashInLastSession] &&
            [[BITHockeyManager sharedHockeyManager].crashManager timeIntervalCrashInLastSessionOccurred] < 5);
}

- (NSURL *)documentDirectoryURL
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
