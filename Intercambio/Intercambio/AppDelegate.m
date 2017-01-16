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
        [self setupUserInterfaceWithError:nil];
    }

    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *, id> *)options
{
    return [_URLHandler handleURL:url];
}

#pragma mark Application Setup

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

        NSArray *items = [_communicationService.keyChain fetchItems:nil];
        BOOL hasAccount = [items count] > 0;
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
        [self setupUserInterfaceWithError:nil];
    }
}

- (void)crashManager:(BITCrashManager *)crashManager didFailWithError:(NSError *)error
{
    if ([self didCrashInLastSessionOnStartup]) {
        [self setupUserInterfaceWithError:nil];
    }
}

- (void)crashManagerDidFinishSendingCrashReport:(BITCrashManager *)crashManager
{
    if ([self didCrashInLastSessionOnStartup]) {
        [self setupUserInterfaceWithError:nil];
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
