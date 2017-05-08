//
//  AppDelegate.m
//  Intercambio
//
//  Created by Tobias Kräntzer on 18.01.16.
//  Copyright © 2016, 2017 Tobias Kräntzer.
//
//  This file is part of Intercambio.
//
//  Intercambio is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option)
//  any later version.
//
//  Intercambio is distributed in the hope that it will be useful, but WITHOUT
//  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
//  FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License along with
//  Intercambio. If not, see <http://www.gnu.org/licenses/>.
//
//  Linking this library statically or dynamically with other modules is making
//  a combined work based on this library. Thus, the terms and conditions of the
//  GNU General Public License cover the whole combination.
//
//  As a special exception, the copyright holders of this library give you
//  permission to link this library with independent modules to produce an
//  executable, regardless of the license terms of these independent modules,
//  and to copy and distribute the resulting executable under terms of your
//  choice, provided that you also meet, for each linked independent module, the
//  terms and conditions of the license of that module. An independent module is
//  a module which is not derived from or based on this library. If you modify
//  this library, you must extend this exception to your version of the library.
//

@import IntercambioCore;
@import IntercambioUI;
@import KeyChain;
@import PureXML;

#import "AppDelegate.h"
#import "ICURLHandler.h"

@interface AppDelegate () <CommunicationServiceDelegate, CommunicationServiceDebugDelegate> {
    CommunicationService *_communicationService;
    Wireframe *_wireframe;
    ICURLHandler *_URLHandler;
}

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"Application did finish launching.");

    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    _communicationService = [[CommunicationService alloc] initWithBaseDirectory:[self documentDirectoryURL]
                                                                    serviceName:[[NSBundle mainBundle] bundleIdentifier]];
    _communicationService.delegate = self;

    _wireframe = [[Wireframe alloc] initWithWindow:self.window service:_communicationService];
    [_wireframe presentLaunchScreen];

    _URLHandler = [[ICURLHandler alloc] initWithWireframe:_wireframe];

    [self setupLogging];
    [self setupUserInterface];

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

- (NSURL *)documentDirectoryURL
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
