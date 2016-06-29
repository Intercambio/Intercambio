//
//  ICURLHandlerTests.m
//  Intercambio
//
//  Created by Tobias Kraentzer on 20.06.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

#import "ICAppWireframe.h"
#import "ICURLHandler.h"
#import <IntercambioCore/IntercambioCore.h>
#import <XCTest/XCTest.h>

@interface ICURLHandlerTests : XCTestCase <ICAccountProvider>
@property (nonatomic, readwrite) ICAppWireframe *appWireframe;
@property (nonatomic, readwrite) ICURLHandler *URLHandler;
@end

@implementation ICURLHandlerTests

- (void)setUp
{
    [super setUp];
    self.appWireframe = mock([ICAppWireframe class]);
    self.URLHandler = [[ICURLHandler alloc] initWithAppWireframe:self.appWireframe];
    self.URLHandler.accountProvider = self;
}

#pragma mark Tests

- (void)testConversationURLWithAccount
{
    NSURL *URL = [NSURL URLWithString:@"xmpp://guest@example.com/support@example.com"];

    BOOL handled = [self.URLHandler handleURL:URL];
    XCTAssertTrue(handled);

    [verify(self.appWireframe) presentUserInterfaceForConversationWithURI:equalTo(URL)
                                                       fromViewController:nilValue()];
}

- (void)testConversationWithUnsupportedAccount
{
    NSURL *URL = [NSURL URLWithString:@"xmpp://foo@example.com/support@example.com"];

    BOOL handled = [self.URLHandler handleURL:URL];
    XCTAssertTrue(handled);

    [verifyCount(self.appWireframe, never()) presentUserInterfaceForConversationWithURI:anything()
                                                                     fromViewController:anything()];
}

- (void)testConversationURLWithoutAccount
{
    [givenVoid([self.appWireframe presentUserInterfaceForSelectingAccountFromViewController:anything()
                                                                                 completion:anything()]) willDo:^id(NSInvocation *invocation) {
        void (^completion)(NSURL *URL) = [[invocation mkt_arguments] lastObject];
        if (completion) {
            completion([NSURL URLWithString:@"xmpp://guest@example.com"]);
        }
        return nil;
    }];

    NSURL *URL = [NSURL URLWithString:@"xmpp:///support@example.com"];

    BOOL handled = [self.URLHandler handleURL:URL];
    XCTAssertTrue(handled);

    [[verify(self.appWireframe) withMatcher:anything() forArgument:1] presentUserInterfaceForSelectingAccountFromViewController:anything()
                                                                                                                     completion:nil];
    [verify(self.appWireframe) presentUserInterfaceForConversationWithURI:equalTo([NSURL URLWithString:@"xmpp://guest@example.com/support@example.com"])
                                                       fromViewController:anything()];
}

#pragma mark ICAccountProvider

- (id<ICAccountViewModel>)accountWithURI:(NSURL *)accountURI
{
    if ([accountURI.host isEqualToString:@"example.com"] &&
        [accountURI.user isEqualToString:@"guest"]) {
        id<ICAccountViewModel> account = mockProtocol(@protocol(ICAccountViewModel));
        return account;
    } else {
        return nil;
    }
}

@end
