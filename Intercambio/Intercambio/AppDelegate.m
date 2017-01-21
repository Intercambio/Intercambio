//
//  AppDelegate.m
//  Intercambio
//
//  Created by Tobias Kräntzer on 18.01.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

@import HockeySDK;
@import IntercambioCore;
@import KeyChain;
@import PureXML;

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

static DDLogLevel ddLogLevel = DDLogLevelInfo;

@interface AppDelegate () <CommunicationServiceDelegate, CommunicationServiceDebugDelegate, BITHockeyManagerDelegate> {
    CommunicationService *_communicationService;
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

    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    _communicationService = [[CommunicationService alloc] initWithBaseDirectory:[self documentDirectoryURL]
                                                                    serviceName:[[NSBundle mainBundle] bundleIdentifier]];
    _communicationService.delegate = self;

    _wireframe = [[Wireframe alloc] initWithWindow:self.window service:_communicationService];
    [_wireframe presentLaunchScreen];

    _URLHandler = [[ICURLHandler alloc] initWithWireframe:_wireframe];

    [self setupLogging];

    if ([self didCrashInLastSessionOnStartup] == NO) {
        [self setupUserInterface];
    }

    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *, id> *)options
{
    return [_URLHandler handleURL:url];
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [_communicationService loadRecentMessagesWithCompletion:^(NSError *error) {
        if (completionHandler) {
            if (error) {
                completionHandler(UIBackgroundFetchResultFailed);
            } else {
                completionHandler(UIBackgroundFetchResultNewData);
            }
        }
    }];
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

- (void)setupUserInterface
{
    [_wireframe presentMainScreen];
    
    NSArray *items = [_communicationService.keyChain items:nil];
    BOOL hasAccount = [items count] > 0;
    if (hasAccount == NO) {
        [_wireframe presentNewAccount];
    }
}

#pragma mark ICCommunicationServiceDelegate

- (void)communicationService:(CommunicationService *)communicationService
     needsPasswordForAccount:(NSURL *)accountURI
                  completion:(void (^)(NSString *))completion
{
    [_wireframe presentLoginFor:accountURI completion:completion];
}

#pragma mark ICCommunicationServiceDebugDelegate

- (void)communicationService:(CommunicationService *)communicationService
                  didReceive:(PXDocument *)document
{
#ifdef DEBUG
    NSLog(@"\n<<<<<<<<<< RECEIVED\n%@----------", document);
#endif
}

- (void)communicationService:(CommunicationService *)communicationService
                    willSend:(PXDocument *)document
{
#ifdef DEBUG
    NSLog(@"\n>>>>>>>>>> SENT\n%@----------", document);
#endif
}

#pragma mark BITCrashManagerDelegate

- (void)crashManagerWillCancelSendingCrashReport:(BITCrashManager *)crashManager
{
    if ([self didCrashInLastSessionOnStartup]) {
        [self setupUserInterface];
    }
}

- (void)crashManager:(BITCrashManager *)crashManager didFailWithError:(NSError *)error
{
    if ([self didCrashInLastSessionOnStartup]) {
        [self setupUserInterface];
    }
}

- (void)crashManagerDidFinishSendingCrashReport:(BITCrashManager *)crashManager
{
    if ([self didCrashInLastSessionOnStartup]) {
        [self setupUserInterface];
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
