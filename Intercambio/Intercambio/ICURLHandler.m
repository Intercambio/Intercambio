//
//  ICURLHandler.m
//  Intercambio
//
//  Created by Tobias Kraentzer on 20.06.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import "ICURLHandler.h"
#import "NSURL+Intercambio.h"

@implementation ICURLHandler

#pragma mark Life-cycle

- (instancetype)initWithAppWireframe:(ICAppWireframe *)appWireframe
{
    self = [super init];
    if (self) {
        _appWireframe = appWireframe;
    }
    return self;
}

#pragma mark Handle URL

- (BOOL)handleURL:(NSURL *)URL
{
    if ([URL hasXMPPNodeComponent]) {
        if ([URL hasXMPPAuthorityComponent]) {
            id<ICAccountViewModel> account = [self.accountProvider accountWithURI:[URL accountURI]];
            if (account != nil) {
                [self.appWireframe presentUserInterfaceForConversationWithURI:URL
                                                           fromViewController:nil];
            }
        } else {
            [self.appWireframe presentUserInterfaceForSelectingAccountFromViewController:nil
                                                                              completion:^(NSURL *accountURI) {
                                                                                  if (accountURI) {
                                                                                      NSURL *conversationURL = [URL URLWithAcountURI:accountURI];
                                                                                      [self.appWireframe presentUserInterfaceForConversationWithURI:conversationURL
                                                                                                                                 fromViewController:nil];
                                                                                  }
                                                                              }];
        }
        return YES;
    }
    return NO;
}

@end
