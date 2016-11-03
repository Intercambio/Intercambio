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
#import "ICURLHandler.h"
#import "Intercambio-Swift.h"
#import <CocoaLumberjack/CocoaLumberjack.h>
#import <IntercambioCore/IntercambioCore.h>

static DDLogLevel ddLogLevel = DDLogLevelInfo;

@interface AppDelegate () <ICCommunicationServiceDelegate, BITHockeyManagerDelegate> {
    ICCommunicationService *_communicationService;
    Wireframe *_wireframe;
    
    ICURLHandler *_URLHandler;
    NSURL *_pendingURLToHandle;
    BOOL _isSetup;
}

@end

@implementation AppDelegate

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

    _wireframe = [[Wireframe alloc] initWithWindow:self.window service:_communicationService];
    [_wireframe presentLaunchScreen];

    _URLHandler = [[ICURLHandler alloc] initWithWireframe:_wireframe];

    [self setupLogging];

    if ([self didCrashInLastSessionOnStartup] == NO) {
        [self setupApplicationWithCompletion:^(BOOL success, NSError *error) {
            [self setupUserInterfaceWithError:success ? nil : error];
        }];
    }

    return YES;
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
        [_wireframe present:error unrecoverable:YES];
    } else {
        [_wireframe presentMainScreen];
        BOOL hasAccount = [[_communicationService accountDataSource] numberOfSections] > 0 &&
                          [[_communicationService accountDataSource] numberOfItemsInSection:0] > 0;
        if (hasAccount == NO) {
            [_wireframe presentNewAccount];
        }
    }
}

#pragma mark ICCommunicationServiceDelegate

- (void)communicationService:(ICCommunicationService *)communicationService
     needsPasswordForAccount:(NSURL *)accountURI
                  completion:(void (^)(NSString *))completion
{
    [_wireframe presentLoginFor:accountURI completion:completion];
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
